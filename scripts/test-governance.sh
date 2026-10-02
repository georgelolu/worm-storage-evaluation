#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${WORM_BUCKET:-}" ]]; then
  echo "ERROR: WORM_BUCKET is not set."
  exit 1
fi

KEY="governance/test-object.txt"

echo "WORM GOVERNANCE TEST"
echo "===================="

echo "Creating test object..."

echo "Governance WORM test" > /tmp/governance-test.txt

aws s3 cp \
  /tmp/governance-test.txt \
  "s3://$WORM_BUCKET/$KEY"

VERSION_ID=$(aws s3api list-object-versions \
  --bucket "$WORM_BUCKET" \
  --prefix "$KEY" \
  --query 'Versions[0].VersionId' \
  --output text)

echo
echo "Version ID:"
echo "$VERSION_ID"

echo
echo "Attempting normal deletion..."

if aws s3api delete-object \
  --bucket "$WORM_BUCKET" \
  --key "$KEY" \
  --version-id "$VERSION_ID"; then

  echo "WARNING: Delete succeeded."
  echo "Check whether the current identity has bypass permission."

else

  echo "PASS: Governance retention blocked deletion."

fi
