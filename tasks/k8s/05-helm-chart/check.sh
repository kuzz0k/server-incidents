#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-05
. "$(dirname "$0")/../../../lib/check.sh"

C=/opt/trainer-k8s/charts/hello
deployed() { helm status hello -n k05 2>/dev/null | grep -q 'STATUS: deployed'; }
three_ready() { kc -n k05 rollout status deploy/hello --timeout=120s >/dev/null && [[ $(kc -n k05 get deploy hello -o jsonpath='{.status.readyReplicas}') == 3 ]]; }
page() { kc -n k05 exec deploy/hello -- wget -qO- http://127.0.0.1/ 2>/dev/null | grep -q 'hello from helm'; }
no_user_values() { [[ $(helm get values hello -n k05 -o json 2>/dev/null) =~ ^(null|\{\})$ ]]; }

check "helm lint без ошибок" helm lint "$C"
check "релиз hello в статусе deployed" deployed
check "3 готовые реплики" three_ready
check "под отдаёт hello from helm" page
check "нет пользовательских values (--set/-f)" no_user_values
finish
