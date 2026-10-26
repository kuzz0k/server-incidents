#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-10
. "$(dirname "$0")/../../../lib/check.sh"

D=/srv/projects
run_as() { local u=$1; shift; (cd / && sudo -u "$u" bash -c "umask 022; $*"); }
rm -rf "$D"/chk-* 2>/dev/null

check "dev1 создаёт файл" run_as dev1 "echo one > $D/chk-dev1.txt"
check "файл принадлежит группе devteam" bash -c "[[ \$(stat -c %G $D/chk-dev1.txt) == devteam ]]"
check "dev1 создаёт каталог проекта с файлом" run_as dev1 "mkdir $D/chk-proj && echo plan > $D/chk-proj/plan.txt"
check "файл в проекте принадлежит группе devteam" bash -c "[[ \$(stat -c %G $D/chk-proj/plan.txt) == devteam ]]"
check "dev2 редактирует файл dev1 в каталоге проекта" run_as dev2 "echo more >> $D/chk-proj/plan.txt"
check "dev2 не может удалить каталог проекта dev1 в корне" bash -c "! (cd / && sudo -u dev2 rm -rf $D/chk-proj) ; [[ -d $D/chk-proj ]]"
check "dev2 не может удалить файл dev1" bash -c "! (cd / && sudo -u dev2 rm -f $D/chk-dev1.txt) && [[ -e $D/chk-dev1.txt ]]"
check "dev3 не видит содержимое каталога" bash -c "! (cd / && sudo -u dev3 ls $D)"
check "у каталога нет прав для прочих" bash -c "(( (8#\$(stat -c %a $D) & 8#007) == 0 ))"
rm -rf "$D"/chk-* 2>/dev/null
finish
