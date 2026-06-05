# AGENTS.md

This repository is John Lambert's Nix/Home Manager setup built with Snowfall.

## Big picture

- Repo root: `~/pure-snow`
- Primary notes/live knowledge base: `~/chronofile`
- User prefers **Org mode** and keeps substantial personal/project notes there.
- This repo manages both system and home configuration.
- Current active machine appears to be `IvyMike` (`x86_64-linux`), with home config at `homes/x86_64-linux/john@IvyMike/default.nix`.

## Important preferences

- Prefer solutions that fit a **Nix** workflow rather than ad-hoc manual setup.
- Prefer changes that are reproducible through Home Manager / NixOS modules.
- When documenting workflows, mention the Org/Emacs angle when relevant.
- Assume `~/chronofile` is the canonical place for notes, drafts, journals, and personal knowledge management.

## Repo structure

- `flake.nix` - top-level flake inputs/outputs
- `homes/<system>/<user@host>/default.nix` - per-user Home Manager entrypoints
- `systems/<system>/<host>/default.nix` - host system configs
- `modules/home/*` - reusable Home Manager modules
- `modules/nixos/*` - reusable NixOS modules
- `modules/home/emacs/` - Emacs package list and literate `init.org`
- `modules/home/pi/` - pi agent config deployed into `~/.pi/agent/`
- `secrets/` - separate secrets repo used as a flake input; treat as sensitive

## Emacs / Org notes

- Emacs config lives in `modules/home/emacs/init.org`.
- Home Manager wiring for Emacs lives in `modules/home/emacs/default.nix`.
- `org-directory` is set to `~/chronofile` in the Emacs init.
- Emacs now also installs `eat` and the `dnouri/pi-coding-agent` frontend declaratively via Nix.
- If adding tools related to capture, journaling, or AI workflows, consider whether they should integrate with Org mode.

## pi notes

- pi is configured through `modules/home/pi/default.nix`.
- That module symlinks files from `modules/home/pi/` into `~/.pi/agent/`.
- If editing pi settings, prompts, models, keybindings, or themes, change the files in `modules/home/pi/`, not just `~/.pi/agent/`.

## Secrets and safety

- Do **not** commit decrypted secrets.
- Secrets are managed with `sops-nix` and a separate `secrets` flake input.
- If changing secret-backed configuration, remember that the parent flake may need `nix flake lock --update-input secrets`.

## Useful commands

### Apply Home Manager changes on this machine

```bash
home-manager switch --flake ~/pure-snow#john@IvyMike -b backup
```

### Rebuild the system on this machine

```bash
sudo nixos-rebuild switch --flake ~/pure-snow#IvyMike
```

### Inspect the flake

```bash
nix flake show ~/pure-snow
```

## Guidance for coding agents

- Read the relevant module before editing.
- Keep edits small and idiomatic to existing Nix/Emacs style.
- Prefer declarative Nix changes over imperative one-off instructions.
- When changes affect Emacs, Home Manager, or pi, mention the exact file paths touched.
- If a task relates to notes, journaling, planning, or knowledge capture, consider whether `~/chronofile` should be referenced or updated.
