#!/usr/bin/env bash
set -euo pipefail
TASK_ID=terraform-01
. "$(dirname "$0")/../../../lib/common.sh"

P=/opt/trainer-tf/site
remove_unit tf-apply-stuck
pkill -f 'terraform apply' 2>/dev/null || true
rm -rf "$P" /srv/tf-site
mkdir -p "$P" /srv/tf-site
cat > "$P/main.tf" <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "env" {
  type    = string
  default = "prod"
}

resource "local_file" "app_conf" {
  filename        = "/srv/tf-site/app.conf"
  file_permission = "0644"
  content         = <<-EOT
    env=${var.env}
    workers=4
    log_level=info
  EOT
}

resource "local_file" "motd" {
  filename        = "/srv/tf-site/motd"
  file_permission = "0644"
  content         = "Managed by Terraform (${var.env})\n"
}
EOF
cd "$P"
export TF_IN_AUTOMATION=1
info "terraform init (скачивается провайдер)…"
terraform init -input=false >/dev/null
terraform apply -input=false -auto-approve >/dev/null
python3 -c 'import json; print(json.load(open("terraform.tfstate"))["lineage"])' > "$TASK_VAR/lineage"
cp /srv/tf-site/app.conf "$TASK_VAR/app.conf.expected"

# Ручная правка на сервере
sed -i 's/^workers=4$/workers=16/; s/^log_level=info$/log_level=debug/' /srv/tf-site/app.conf

# Забытый apply, который ждёт подтверждения и держит блокировку
write_unit tf-apply-stuck <<EOF
[Unit]
Description=terraform apply (started by colleague)
After=network-online.target

[Service]
WorkingDirectory=$P
ExecStart=/bin/bash -c 'sleep infinity | /usr/local/bin/terraform apply -var env=staging'

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now tf-apply-stuck >/dev/null 2>&1
wait_until 60 bash -c "! terraform plan -input=false -lock-timeout=1s >/dev/null 2>&1" || warn "Не удалось дождаться блокировки state"
