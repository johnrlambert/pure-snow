#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

SSH_PORT="${SSH_PORT:-2223}"
HA_PORT="${HA_PORT:-8123}"
ZWAVE_UI_PORT="${ZWAVE_UI_PORT:-8091}"
ZWAVE_WS_PORT="${ZWAVE_WS_PORT:-3000}"
MEMORY_MIB="${MEMORY_MIB:-2048}"
CORES="${CORES:-4}"
DISK_IMAGE="${DISK_IMAGE:-${REPO_ROOT}/malacabeza-vm.qcow2}"
EFI_VARS_FILE="${EFI_VARS_FILE:-${REPO_ROOT}/malacabeza-vm-efi-vars.fd}"
QEMU_BIN="${QEMU_BIN:-qemu-system-aarch64}"
QEMU_SHARE_ROOT="${QEMU_SHARE_ROOT:-${REPO_ROOT}/.qemu/malacabeza-vm}"
XCHG_DIR="${XCHG_DIR:-${QEMU_SHARE_ROOT}/xchg}"
SHARED_DIR="${SHARED_DIR:-${XCHG_DIR}}"
PID_FILE="${PID_FILE:-${QEMU_SHARE_ROOT}/qemu.pid}"

cd "${REPO_ROOT}"

if [[ ! -e "${DISK_IMAGE}" ]]; then
  echo "Missing writable VM disk: ${DISK_IMAGE}" >&2
  echo "Build it first with: ./systems/aarch64-linux/malacabeza-vm/build-image.sh" >&2
  exit 1
fi

echo "Realizing EFI firmware files..."
nix build .#nixosConfigurations.malacabeza-vm.config.virtualisation.efi.OVMF --no-link >/dev/null

FIRMWARE="$(nix eval --raw .#nixosConfigurations.malacabeza-vm.config.virtualisation.efi.firmware)"
VARS_TEMPLATE="$(nix eval --raw .#nixosConfigurations.malacabeza-vm.config.virtualisation.efi.variables)"

if [[ ! -e "${EFI_VARS_FILE}" ]]; then
  cp "${VARS_TEMPLATE}" "${EFI_VARS_FILE}"
fi

mkdir -p "${QEMU_SHARE_ROOT}" "${XCHG_DIR}" "${SHARED_DIR}"
rm -f "${PID_FILE}"

echo "Disk image: ${DISK_IMAGE}"
echo "Firmware: ${FIRMWARE}"
echo "EFI vars: ${EFI_VARS_FILE}"
echo "xchg share: ${XCHG_DIR}"
echo "shared share: ${SHARED_DIR}"
echo "pid file: ${PID_FILE}"
echo "SSH: ssh -p ${SSH_PORT} john@127.0.0.1"
echo "Home Assistant: http://127.0.0.1:${HA_PORT}"
echo "Z-Wave JS UI: http://127.0.0.1:${ZWAVE_UI_PORT}"

action_message='Stop QEMU with Ctrl-a x if stdio is captured.'
echo "${action_message}"

exec "${QEMU_BIN}" \
  -machine virt,gic-version=max,accel=tcg \
  -cpu max \
  -smp "${CORES}" \
  -m "${MEMORY_MIB}" \
  -device virtio-rng-pci \
  -display none \
  -pidfile "${PID_FILE}" \
  -serial mon:stdio \
  -drive if=pflash,format=raw,unit=0,readonly=on,file="${FIRMWARE}" \
  -drive if=pflash,format=raw,unit=1,file="${EFI_VARS_FILE}" \
  -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::${HA_PORT}-:8123,hostfwd=tcp::${ZWAVE_UI_PORT}-:8091,hostfwd=tcp::${ZWAVE_WS_PORT}-:3000 \
  -device virtio-net-pci,netdev=net0 \
  -virtfs "local,path=${XCHG_DIR},security_model=none,mount_tag=xchg" \
  -virtfs "local,path=${SHARED_DIR},security_model=none,mount_tag=shared" \
  -drive if=none,file="${DISK_IMAGE}",format=qcow2,id=hd0 \
  -device virtio-blk-pci,drive=hd0,bootindex=1
