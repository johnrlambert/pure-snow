# malacabeza

`malacabeza` is the Raspberry Pi 4 host in this Snowfall config.

At the moment this host is intentionally minimal. The current goal is not "full Home Assistant appliance" yet; the current goal is:

- produce a bootable Pi 4 SD image
- boot a minimal `aarch64-linux` NixOS system
- get on the network
- SSH in as `john`
- run `ls` like a civilized person

After that, the more interesting Home Assistant / Docker / secrets / service layering can be added back in.

---

## Current shape

This host currently lives at:

- `systems/aarch64-linux/malacabeza/default.nix`
- `homes/aarch64-linux/john@malacabeza/default.nix`

There is now also a generic QEMU-oriented sibling host:

- `systems/aarch64-linux/malacabeza-vm/default.nix`
- `homes/aarch64-linux/john@malacabeza-vm/default.nix`
- `systems/aarch64-linux/malacabeza-vm/run-qemu-system-aarch64.sh`

It currently uses:

- the NixOS `sd-image-aarch64` module for image generation
- `pkgs.linuxPackages_rpi4`
- a very small initrd module set
- OpenSSH
- a `john` user with the existing authorized key from the rest of the repo

This is deliberately much smaller than the eventual target system.

---

## Why this host is weird compared to the x86 hosts

The x86 hosts in this repo mostly care about:

- evaluation
- package composition
- system roles

`malacabeza` also has to care about:

- Pi firmware
- SD card partition layout
- boot files
- initrd module selection
- board-specific kernel behavior

So there are really two separate problems:

1. **generic aarch64 system behavior**
2. **Raspberry Pi boot/image behavior**

Those should eventually be separated more cleanly.

---

## Current build workflow

### 1. Build from IvyMike

`IvyMike` has been given the `arm_builder` role so it can realize `aarch64-linux` derivations through binfmt/QEMU.

Build the image from the repo root:

```bash
nix build .#nixosConfigurations.malacabeza.config.system.build.sdImage
```

If successful, you should get a `result` symlink pointing at a compressed SD image in the store.

---

### 2. Why the first build failed

The first attempt used the generic `sd-image-aarch64` defaults plus the Pi 4 kernel.

That pulled in a broad "all hardware" initrd module list intended for generic installer-like media. One of those modules was `dw-hdmi`, and the `linuxPackages_rpi4` kernel package did not provide it as a loadable module in the way the initrd shrinking step expected.

That failure was fixed by making this host more Pi-specific:

- `hardware.enableAllHardware = lib.mkForce false;`
- explicitly setting a minimal `boot.initrd.availableKernelModules`

This keeps the image focused on what the Pi 4 actually needs for minimal boot.

---

## Current minimal boot assumptions

The current image is trying to be the smallest useful thing:

- root on ext4
- SD card boot
- SSH enabled
- fish available
- `john` user exists
- enough USB support to not be miserable if a keyboard is involved

It is **not** yet trying to be:

- Home Assistant host
- Docker host
- Tailscale node
- secret-bearing appliance
- polished headless product

That comes later.

---

## About testing with QEMU

### The annoying truth

A Raspberry Pi SD image is not the same thing as a generic ARM virtual machine image.

This image is Pi-flavored. It depends on:

- Pi firmware files
- Pi DTBs
- Pi-oriented boot flow
- board-specific kernel assumptions

A generic QEMU ARM VM usually emulates `virt`, not "Raspberry Pi 4 booted from its native firmware path".

So:

- **mounting and inspecting the image is useful**
- **chrooting can be useful for userspace sanity checks**
- **QEMU is not a perfect proof that the Pi image will boot on real hardware**

### What QEMU *is* good for here

A generic ARM VM is still worth having as a **development target**.

That split now starts with `malacabeza-vm`, a separate generic `aarch64-linux` host for QEMU.

That host lets you test things like:

- Home Assistant role composition
- Docker/container behavior
- user/service configuration
- package availability on ARM
- general `aarch64-linux` runtime behavior

without needing to flash an SD card for every change.

### `malacabeza-vm` workflow

Build the VM disk image from the repo root:

```bash
nix build .#nixosConfigurations.malacabeza-vm.config.system.build.image
```

That produces a QEMU-friendly qcow2 image rather than a Pi SD image.

To build and boot it with the helper script:

```bash
./systems/aarch64-linux/malacabeza-vm/run-qemu-system-aarch64.sh
```

The script will:

- build `.#nixosConfigurations.malacabeza-vm.config.system.build.image`
- create a writable local EFI vars file on first run
- boot the image with `qemu-system-aarch64` on the generic `virt` machine
- forward host port `2222` to guest SSH on port `22`

Once the guest is up:

```bash
ssh -p 2222 john@127.0.0.1
```

Useful environment overrides for the script:

- `SSH_PORT=2223`
- `MEMORY_MIB=4096`
- `CORES=8`
- `EFI_VARS_FILE=/some/path/malacabeza-vm-efi-vars.fd`
- `QEMU_BIN=/path/to/qemu-system-aarch64`

### The right split long-term

A good long-term shape is probably:

- **shared module**: common ARM/Home-Assistant appliance behavior
- **generic ARM VM host**: boots in QEMU for fast iteration
- **Pi host (`malacabeza`)**: imports the shared module plus Pi-specific SD-image/boot settings

That way the Pi host becomes the hardware target, not the only place where the system logic lives.

---

## Suggested future refactor

Something like this is probably where this wants to go:

### Shared module
Create a module for the logical appliance role, for example somewhere under:

- `modules/nixos/roles/...`
- or a host-support module if it feels more host-specific than role-specific

That shared module would eventually contain things like:

- SSH
- Docker / OCI container runtime
- Home Assistant service wiring
- Z-Wave / whisper container logic
- common packages / user setup
- maybe Tailscale and secrets integration

### Generic ARM VM test host
The first pass of that host now exists as:

- `systems/aarch64-linux/malacabeza-vm/default.nix`

It targets a QEMU-friendly `virt` machine rather than a Pi SD image.

That host should continue to be the place for:

- evaluation and runtime iteration
- service testing
- generic ARM debugging

### Pi hardware host
Keep `malacabeza` for:

- Pi 4 boot specifics
- SD image generation
- firmware / DTB / kernel / initrd concerns
- final deployment target

---

## Flashing the image

Once the image is built, the output will be a compressed `.img.zst`.

Typical workflow:

```bash
readlink -f result
```

Then write it to an SD card carefully, using the correct device.

Example shape:

```bash
zstd -d --stdout $(readlink -f result) | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the actual SD card device, not a partition.

You may prefer a tool like `bmaptool` or a graphical flasher later, but `dd` is enough for bring-up if you are careful.

---

## First boot expectations

If first boot works, the minimum success condition is:

- the Pi gets a DHCP lease
- SSH is reachable
- `john` can log in
- the authorized key works
- basic shell access works

The current SSH configuration is the direct `services.openssh` setup in `malacabeza`, not the repo's `homelab.roles.ssh` role.

That was intentional for the first minimal pass.

---

## Temporary rough edges

### Temporary password
The current host config includes:

```nix
users.users.john.initialPassword = "changeme";
```

That is just for first-boot recovery during bring-up.

It should be removed once SSH access is confirmed.

### Minimal home-manager config
The Home Manager config is intentionally a stub right now. It only sets `home.stateVersion`.

That keeps the first boot path simple.

---

## Repo lore / Snowfall gotcha

Because this is a Snowfall repo, **new files need to be in git** before the flake sees them properly.

If you create new host files or modules, remember to:

```bash
git add .
```

before assuming Snowfall is broken.

---

## Practical next milestones

In order:

1. boot the SD image on the real Pi 4
2. confirm SSH access
3. remove the temporary password
4. decide what logic belongs in a shared ARM appliance module
5. move Home Assistant / Docker functionality into shared modules
6. re-import that shared logic into `malacabeza`
7. keep using `malacabeza-vm` as the fast QEMU iteration target

---

## Summary

Right now, `malacabeza` is a **hardware bring-up target**.

Later, it should become a **thin Pi-specific wrapper** around more reusable ARM system logic.

That split should make development much less tedious:

- QEMU/generic ARM for fast iteration
- Pi SD image for final hardware validation
