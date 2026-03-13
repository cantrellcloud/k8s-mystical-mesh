#!/usr/bin/env bash
#clear
set -euo pipefail
echo
echo
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongodb"
export DST_POD="opsmanager-0"
export SRC_DIR="/srv/mongodb-releases"
export DST_DIR="/mongodb-ops-manager/mongodb-releases"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo "Copy all .tgz files to ${DST_POD}:${DST_DIR}"
echo
echo
for file in "${SRC_DIR}"/*.tgz; do
  [[ -e "${file}" ]] || continue
  echo "File:  ${file}"
  kubectl cp --namespace "${NAMESPACE}" "${file}" "${DST_POD}:${DST_DIR}/"
done
echo
echo "All .tgz files copied to ${DST_POD}:${DST_DIR}"
echo
