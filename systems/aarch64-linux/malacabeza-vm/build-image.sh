#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

IMAGE_LINK="${IMAGE_LINK:-${REPO_ROOT}/result-malacabeza-vm-image}"
DISK_IMAGE="${DISK_IMAGE:-${REPO_ROOT}/malacabeza-vm.qcow2}"

cd "${REPO_ROOT}"

echo "Building malacabeza-vm qcow2 image..."
nix build .#nixosConfigurations.malacabeza-vm.config.system.build.image --out-link "${IMAGE_LINK}"

IMAGE="$(readlink -f "${IMAGE_LINK}")"
if [[ -d "${IMAGE}" ]]; then
  IMAGE_FILE="$(find "${IMAGE}" -maxdepth 1 -type f -name '*.qcow2' | head -n 1)"
  if [[ -z "${IMAGE_FILE}" ]]; then
    echo "Could not find a qcow2 image inside ${IMAGE}" >&2
    exit 1
  fi
  IMAGE="${IMAGE_FILE}"
fi

echo "Copying image to writable disk: ${DISK_IMAGE}"
cp --reflink=auto --sparse=always "${IMAGE}" "${DISK_IMAGE}.tmp"
mv "${DISK_IMAGE}.tmp" "${DISK_IMAGE}"

echo "Image link: ${IMAGE_LINK}"
echo "Store image: ${IMAGE}"
echo "Writable disk: ${DISK_IMAGE}"
