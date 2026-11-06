#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-61
. "$(dirname "$0")/../../../lib/common.sh"

C=/etc/ssh/trainer-2222
remove_unit mirror-sync trainer-sshd
remove_user syncer gitmirror
rm -rf "$C" /root/trainer-notes/linux-61.txt
port_listening 2222 && die "Порт 2222 уже занят — задаче нужен свободный 127.0.0.1:2222"
useradd --create-home --shell /bin/bash syncer
useradd --create-home --shell /bin/bash gitmirror
mkdir -p "$C"
ssh-keygen -q -t ed25519 -N '' -f "$C/ssh_host_ed25519_key"
cat > "$C/sshd_config" <<EOF
# Учебный sshd для linux-61 (не основной!)
Port 2222
ListenAddress 127.0.0.1
HostKey $C/ssh_host_ed25519_key
PidFile /run/sshd-trainer-2222.pid
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM yes
AllowUsers gitmirror
EOF
sshd -t -f "$C/sshd_config"
write_unit trainer-sshd <<EOF
[Unit]
Description=devops-trainer linux-61: mirror sshd on 127.0.0.1:2222
After=network.target

[Service]
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -f $C/sshd_config
Restart=on-failure
EOF
systemctl start trainer-sshd
wait_for_port 2222

sudo -u syncer ssh-keygen -q -t ed25519 -N '' -f /home/syncer/.ssh/id_ed25519
install -d -m 0700 -o gitmirror -g gitmirror /home/gitmirror/.ssh
install -m 0600 -o gitmirror -g gitmirror /home/syncer/.ssh/id_ed25519.pub /home/gitmirror/.ssh/authorized_keys
ssh-keyscan -p 2222 -t ed25519 127.0.0.1 2>/dev/null | sudo -u syncer tee /home/syncer/.ssh/known_hosts >/dev/null
cut -d' ' -f2 "$C/ssh_host_ed25519_key.pub" > "$TASK_VAR/old-key"

# «Переустановка» зеркала: новый ключ хоста
rm -f "$C"/ssh_host_ed25519_key*
ssh-keygen -q -t ed25519 -N '' -f "$C/ssh_host_ed25519_key"
systemctl restart trainer-sshd
wait_for_port 2222
cut -d' ' -f2 "$C/ssh_host_ed25519_key.pub" > "$TASK_VAR/new-key"
mkdir -p /root/trainer-notes
{
  echo "Зеркало gitmirror (127.0.0.1:2222) переустановлено. Новый ключ хоста:"
  ssh-keygen -lf "$C/ssh_host_ed25519_key.pub"
} > /root/trainer-notes/linux-61.txt

mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/mirror-sync.sh" <<'EOF'
#!/bin/bash
# Синхронизация с зеркалом по SSH
while true; do
  if ssh -p 2222 -o BatchMode=yes -o ConnectTimeout=5 gitmirror@127.0.0.1 true; then
    echo "sync ok"
  else
    echo "sync failed"
  fi
  sleep 3
done
EOF
chmod 0755 "$TRAINER_LIB/mirror-sync.sh"
write_unit mirror-sync <<EOF
[Unit]
Description=Mirror sync
After=trainer-sshd.service

[Service]
User=syncer
ExecStart=$TRAINER_LIB/mirror-sync.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now mirror-sync >/dev/null 2>&1
