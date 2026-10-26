#!/usr/bin/env bash
set -euo pipefail
TASK_ID=git-01
. "$(dirname "$0")/../../../lib/common.sh"

R=/srv/git/billing
rm -rf "$R"
mkdir -p "$R"
cd "$R"
git init -q -b main
git config user.name "Billing Team"
git config user.email billing@example.com

authors=("Anna Petrova <anna@example.com>" "Ivan Sidorov <ivan@example.com>" "Olga Kim <olga@example.com>" "Max Orlov <max@example.com>")
ts=$(date -d '-40 days' +%s)
commit() {
  ts=$((ts + 86400 + RANDOM % 7200))
  local a=${authors[$((RANDOM % 4))]}
  GIT_AUTHOR_DATE="@$ts" GIT_COMMITTER_DATE="@$ts" git -c "user.name=${a% <*}" -c "user.email=$(sed 's/.*<\(.*\)>/\1/' <<<"$a")" \
    commit -q -m "$1"
}

cat > calc.py <<'EOF'
def total(items):
    """Сумма заказа с НДС 20%, округлённая до копеек."""
    return round(sum(items) * 1.2, 2)
EOF
cat > run-tests.sh <<'EOF'
#!/bin/bash
# Тесты биллинга
cd "$(dirname "$0")"
export PYTHONDONTWRITEBYTECODE=1
python3 - <<'PY'
from calc import total
cases = [([10, 20.5], 36.6), ([0.1, 0.2], 0.36), ([99.99], 119.99), ([], 0)]
for items, want in cases:
    got = total(items)
    assert got == want, f"total({items}) = {got}, want {want}"
print("tests passed")
PY
EOF
chmod +x run-tests.sh
echo "# Billing" > README.md
printf '__pycache__/\n*.pyc\n' > .gitignore
printf '# Changelog\n' > CHANGELOG.md
printf 'def fmt(v):\n    return f"{v:.2f}"\n' > utils.py
git add -A
commit "initial billing module"

msgs=("add changelog entry" "docs: describe API" "utils: add currency formatter" "ci: add pipeline stub"
      "docs: fix typo" "utils: add percent helper" "chore: bump version" "docs: add examples"
      "utils: add rounding docs" "chore: update gitignore" "docs: deployment notes" "refactor: speed up total() calculation"
      "utils: add discount helper" "docs: FAQ" "chore: lint fixes" "docs: changelog for 1.1"
      "utils: add tax helper" "docs: update README" "chore: cleanup" "utils: add parse_amount"
      "docs: add contributing guide" "chore: bump version to 1.2" "docs: runbook" "utils: logging helper")
i=0
for m in "${msgs[@]}"; do
  i=$((i + 1))
  case $m in
    "refactor: speed up total() calculation")
      sed -i 's/return round(sum(items) \* 1.2, 2)/return int(sum(items) * 1.2 * 100) \/ 100/' calc.py ;;
    utils:*) printf '\n\ndef helper_%s(v):\n    return v\n' "$i" >> utils.py ;;
    docs:*) mkdir -p docs; echo "$m" > "docs/note-$i.md" ;;
    *) echo "- $m" >> CHANGELOG.md ;;
  esac
  git add -A
  commit "$m"
  [[ $i -eq 3 ]] && git tag v1.0
  [[ $m == "refactor: speed up total() calculation" ]] && git rev-parse HEAD > "$TASK_VAR/bad"
done
git rev-parse HEAD > "$TASK_VAR/orig"
