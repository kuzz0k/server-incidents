#!/usr/bin/env bash
# Виртуальные диски для задач: loop-образы в /var/lib/devops-trainer/disks.
# trainer-disks.service подключает их при загрузке раньше local-fs, поэтому
# записи fstab по UUID и LVM на них переживают ребут.

DISK_DIR=$TRAINER_VAR/disks

install_disk_service() {
  [[ -f /etc/systemd/system/trainer-disks.service ]] && return 0
  mkdir -p "$TRAINER_LIB"
  cat > "$TRAINER_LIB/attach-disks.sh" <<'EOF'
#!/bin/bash
# Подключает loop-образы тренажёра (devops-trainer)
for img in /var/lib/devops-trainer/disks/*.img; do
  [ -e "$img" ] || continue
  losetup -j "$img" | grep -q . || losetup -f "$img"
done
EOF
  chmod 0755 "$TRAINER_LIB/attach-disks.sh"
  cat > /etc/systemd/system/trainer-disks.service <<EOF
[Unit]
Description=devops-trainer: attach loop disk images
DefaultDependencies=no
After=systemd-udevd.service
Before=local-fs-pre.target
Wants=local-fs-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$TRAINER_LIB/attach-disks.sh

[Install]
WantedBy=local-fs-pre.target
EOF
  systemctl daemon-reload
  systemctl enable trainer-disks.service >/dev/null 2>&1
}

disk_dev() { losetup -j "$DISK_DIR/$1.img" | head -1 | cut -d: -f1; }

# make_disk <name> <sizeMB> — создаёт образ, подключает и печатает /dev/loopN
make_disk() {
  local name=$1 size=$2
  remove_disk "$name"
  mkdir -p "$DISK_DIR"
  truncate -s "${size}M" "$DISK_DIR/$name.img"
  install_disk_service
  losetup -f --show "$DISK_DIR/$name.img"
}

remove_disk() {
  local img=$DISK_DIR/$1.img dev t
  [[ -e $img ]] || return 0
  while read -r dev; do
    [[ -n $dev ]] || continue
    while read -r t; do
      [[ -n $t ]] && { umount "$t" 2>/dev/null || umount -l "$t" 2>/dev/null; }
    done < <(findmnt -rn -S "$dev" -o TARGET 2>/dev/null)
    losetup -d "$dev" 2>/dev/null || true
  done < <(losetup -j "$img" | cut -d: -f1)
  rm -f "$img"
}

disk_uuid() { blkid -p -s UUID -o value "$1"; }

# mount_disk <task-id> <dev> <mountpoint> — монтирует и прописывает в fstab (nofail)
mount_disk() {
  local id=$1 dev=$2 mp=$3
  mkdir -p "$mp"
  fstab_clear "$id"
  fstab_add "$id" "UUID=$(disk_uuid "$dev") $mp ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2"
  mount "$mp"
}

# unmount_task <task-id> <mountpoint...> — снимает монтирование и запись fstab
unmount_task() {
  local id=$1 mp; shift
  for mp in "$@"; do
    mountpoint -q "$mp" && { umount "$mp" 2>/dev/null || umount -l "$mp"; }
  done
  fstab_clear "$id"
  systemctl daemon-reload
}
