#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-31
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /opt/deploy
mkdir -p /opt/deploy/artifacts "/opt/deploy/release store"
for v in 1.2.2 1.2.3; do
  tmp=$(mktemp -d)
  echo "$v" > "$tmp/VERSION"
  echo "echo app $v" > "$tmp/run.sh"
  tar -czf "/opt/deploy/artifacts/app-$v.tar.gz" -C "$tmp" .
  rm -rf "$tmp"
done
mkdir -p "/opt/deploy/release store/1.2.2"
tar -xzf /opt/deploy/artifacts/app-1.2.2.tar.gz -C "/opt/deploy/release store/1.2.2"
ln -sfn "/opt/deploy/release store/1.2.2" /opt/deploy/current
cp -a "/opt/deploy/release store/1.2.2" "$TASK_VAR/release-1.2.2"

cat > /opt/deploy/deploy.sh <<'EOF'
#!/bin/bash
# Деплой релиза: deploy.sh <version>
VERSION=$1
BASE=/opt/deploy
RELEASES="$BASE/release store"
ARTIFACT=$BASE/artifacts/app-$VERSION.tar.gz

if [ $VERSION == "" ]; then
  echo "usage: deploy.sh <version>"
  exit 1
fi

mkdir -p $RELEASES/$VERSION
tar xzf $ARTIFACT -C $RELEASES/$VERSION
ln -sfn $RELEASES/$VERSION $BASE/current
echo "deployed $VERSION"
EOF
sed -i 's/$/\r/' /opt/deploy/deploy.sh
chmod 0755 /opt/deploy/deploy.sh
