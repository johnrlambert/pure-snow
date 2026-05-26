#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

SSH_PORT="${SSH_PORT:-2222}"
MEMORY_MIB="${MEMORY_MIB:-2048}"
CORES="${CORES:-4}"
IMAGE_LINK="${IMAGE_LINK:-${REPO_ROOT}/result-malacabeza-vm-image}"
EFI_VARS_FILE="${EFI_VARS_FILE:-${REPO_ROOT}/malacabeza-vm-efi-vars.fd}"
QEMU_BIN="${QEMU_BIN:-qemu-system-aarch64}"

cd "${REPO_ROOT}"

echo "Building malacabeza-vm qcow2 image..."
nix build .#nixosConfigurations.malacabeza-vm.config.system.build.image --out-link "${IMAGE_LINK}"

IMAGE="$(readlink -f "${IMAGE_LINK}")"
FIRMWARE="$(nix eval --raw .#nixosConfigurations.malacabeza-vm.config.virtualisation.efi.firmware)"
VARS_TEMPLATE="$(nix eval --raw .#nixosConfigurations.malacabeza-vm.config.virtualisation.efi.variables)"

if [[ ! -e "${EFI_VARS_FILE}" ]]; then
  cp "${VARS_TEMPLATE}" "${EFI_VARS_FILE}"
fi

echo "Image: ${IMAGE}"
echo "Firmware: ${FIRMWARE}"
echo "EFI vars: ${EFI_VARS_FILE}"
echo "SSH: ssh -p ${SSH_PORT} john@127.0.0.1"

action_message='Stop QEMU with Ctrl-a x if stdio is captured.'
echo "${action_message}"

exec "${QEMU_BIN}" \
  -machine virt,gic-version=max,accel=tcg \
  -cpu max \
  -smp "${CORES}" \
  -m "${MEMORY_MIB}" \
  -device virtio-rng-pci \
  -display none \
  -serial mon:stdio \
  -drive if=pflash,format=raw,unit=0,readonly=on,file="${FIRMWARE}" \
  -drive if=pflash,format=raw,unit=1,file="${EFI_VARS_FILE}" \
  -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
  -device virtio-net-pci,netdev=net0 \
  -drive if=none,file="${IMAGE}",format=qcow2,id=hd0 \
  -device virtio-blk-pci,drive=hd0,bootindex=1
