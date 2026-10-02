#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${WORM_BUCKET:-}" ]]; then
  echo "ERROR: WORM_BUCKET is not set."
  exit 1
fi

KEY="${1:-test-data/test-data.txt}"

echo "========================================"
echo " WORM OBJECT INSPECTION"
echo "========================================"
echo "Bucket: $WORM_BUCKET"
echo "Key:    $KEY"
echo

aws s3api list-object-versions \
  --bucket "$WORM_BUCKET" \
  --prefix "$KEY"

echo
echo "========================================"
echo " Object Metadata"
echo "========================================"

VERSION_ID=$(aws s3api list-object-versions \
  --bucket "$WORM_BUCKET" \
  --prefix "$KEY" \
  --query 'Versions[0].VersionId' \
  --output text)

echo "Version: $VERSION_ID"

aws s3api head-object \
  --bucket "$WORM_BUCKET" \
  --key "$KEY" \
  --version-id "$VERSION_ID"
