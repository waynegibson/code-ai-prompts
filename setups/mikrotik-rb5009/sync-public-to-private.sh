#!/usr/bin/env zsh
set -euo pipefail

# Sync sanitized RB5009 templates from this public repo to a private repo.
# Excludes environment-specific and sensitive paths by design.
#
# Usage:
#   ./sync-public-to-private.sh \
#     /path/to/public-repo \
#     /path/to/private-repo \
#     cape-town
#
# Optional env vars:
#   DRY_RUN=1   # show what would change without writing

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <public_repo_root> <private_repo_root> <site_name>"
  exit 1
fi

PUBLIC_REPO_ROOT="$1"
PRIVATE_REPO_ROOT="$2"
SITE_NAME="$3"

SRC_DIR="$PUBLIC_REPO_ROOT/setups/mikrotik-rb5009"
DST_DIR="$PRIVATE_REPO_ROOT/sites/$SITE_NAME/rb5009/staged"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source directory not found: $SRC_DIR"
  exit 1
fi

mkdir -p "$DST_DIR"

RSYNC_FLAGS=(
  -av
  --delete
  --exclude ".DS_Store"
  --exclude "*.local.rsc"
  --exclude "*.secrets.rsc"
  --exclude "*.backup"
  --exclude "*.auto.rsc"
  --exclude "*.npk"
  --exclude "overlays/"
  --exclude "secrets/"
  --exclude "backups/"
  --exclude "exports/"
)

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  RSYNC_FLAGS+=(--dry-run --itemize-changes)
  echo "Running in DRY_RUN mode"
fi

echo "Syncing from: $SRC_DIR/"
echo "Syncing to:   $DST_DIR/"

rsync "${RSYNC_FLAGS[@]}" "$SRC_DIR/" "$DST_DIR/"

echo "Sync complete."

echo "Suggested next steps in private repo:"
echo "  cd $PRIVATE_REPO_ROOT"
echo "  git status"
echo "  git add sites/$SITE_NAME/rb5009/staged"
echo "  git commit -m 'Sync RB5009 staged templates from public repo'"
