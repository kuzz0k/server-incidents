#!/usr/bin/env bash
# Эталонное решение linux-10 (для tests/selftest.sh)
set -euo pipefail
chgrp devteam /srv/projects
chmod 3770 /srv/projects
setfacl -m g:devteam:rwx -m d:g:devteam:rwx /srv/projects
