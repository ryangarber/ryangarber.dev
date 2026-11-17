#!/usr/bin/env bash
set -euo pipefail

: "${SSH_HOST:?Set the production SSH_HOST secret}"
: "${SSH_USER:?Set the production SSH_USER secret}"
: "${SSH_PRIVATE_KEY:?Set the production SSH_PRIVATE_KEY secret}"
: "${SSH_KNOWN_HOSTS:?Set the production SSH_KNOWN_HOSTS variable to the verified host key}"
SSH_PORT="${SSH_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/ryangarber.dev}"

# Restrict values that become remote shell arguments, and prevent root syncs.
[[ "$SSH_HOST" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || { echo 'Invalid SSH_HOST' >&2; exit 1; }
[[ "$SSH_USER" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]] || { echo 'Invalid SSH_USER' >&2; exit 1; }
[[ "$SSH_PORT" =~ ^[0-9]+$ ]] && (( 10#$SSH_PORT > 0 && 10#$SSH_PORT <= 65535 )) || { echo 'Invalid SSH_PORT' >&2; exit 1; }
[[ "$DEPLOY_PATH" =~ ^/([a-zA-Z0-9_-]+/)*[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)?$ && "$DEPLOY_PATH" == /*/* ]] || { echo 'DEPLOY_PATH must be a dedicated absolute directory without spaces or traversal' >&2; exit 1; }
[[ -s dist/index.html ]] || { echo 'Build dist/ before deploying' >&2; exit 1; }

ssh_dir="$(mktemp -d)"
trap 'rm -rf "$ssh_dir"' EXIT
chmod 700 "$ssh_dir"
printf '%s\n' "$SSH_PRIVATE_KEY" > "$ssh_dir/key"
printf '%s\n' "$SSH_KNOWN_HOSTS" > "$ssh_dir/known_hosts"
chmod 600 "$ssh_dir/key" "$ssh_dir/known_hosts"
unset SSH_PRIVATE_KEY

export RSYNC_RSH="ssh -i $ssh_dir/key -p $SSH_PORT -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$ssh_dir/known_hosts"
ssh -i "$ssh_dir/key" -p "$SSH_PORT" \
  -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes \
  -o "UserKnownHostsFile=$ssh_dir/known_hosts" \
  "$SSH_USER@$SSH_HOST" "mkdir -p -- '$DEPLOY_PATH'"

# Transfer changed assets first. Keep old hashed assets for already-open pages.
# index.html is renamed into place by rsync only after its new assets exist.
rsync -az --checksum --itemize-changes --exclude='/index.html' \
  dist/ "$SSH_USER@$SSH_HOST:$DEPLOY_PATH/"
rsync -az --checksum --itemize-changes \
  dist/index.html "$SSH_USER@$SSH_HOST:$DEPLOY_PATH/index.html"
