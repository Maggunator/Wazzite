# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A custom [bootc](https://github.com/bootc-dev/bootc) OCI image (`ghcr.io/maggunator/wazzite`) built on top of [Universal Blue](https://universal-blue.org/) images (Bazzite, Bluefin). It adds a Sway WM stack, RPM packages, and Flatpak applications on top of those upstream bases.

## Common commands

Requires `just` and `podman`.

```bash
# Build a specific image locally
just build bazzite
just build bazzite-nvidia
just build bluefin
just build bluefin-nvidia

# Lint everything (shellcheck, yamllint, justcheck)
just lint

# Auto-format everything (shfmt, yamlfmt, just fmt)
just format

# Build and run an ISO
just build-iso bazzite

# Clean local build artifacts
just clean
```

## Build pipeline

```
build-desktop.yml          ← triggers builds for each image_flavor in the matrix
    └─> build-image.yml    ← build → rechunk → tag → push → sign per image
          └─> Justfile (just build <image>)
                └─> Containerfile
                      └─> build_files/build.sh  ← entry point inside container
```

The Containerfile just mounts `build_files/` as `/ctx` and calls `/ctx/build.sh`. All real logic lives in the shell scripts.

## Where to make changes

| Goal | File |
|------|------|
| Add/remove RPM packages | `build_files/desktop_packages.sh` |
| System config (GSettings, file overrides, service masking) | `build_files/desktop_changes.sh` |
| Add/remove Flatpaks baked into the image | `build_files/install_flatpaks.sh` |
| Packages needed before other scripts run | `build_files/build.sh` |
| Static files copied into the image (mirrors root FS layout) | `build_files/system_files/silverblue/` |
| Which image flavors get built in CI | `.github/workflows/build-desktop.yml` (`matrix.image_flavor`) |
| Mapping of flavor name → upstream base image | `Justfile` (`images` map at the top) |

## Publishing

Images are pushed to `ghcr.io/maggunator/wazzite` **only** on:
- Manual `workflow_dispatch`
- Merge queue (`merge_group`)
- Sunday cron (`41 6 * * 0`)

Regular pushes to `main` and PRs build but do **not** push.

## Signing

Container signing uses cosign. The private key must be stored as the `SIGNING_SECRET` GitHub Actions secret. `cosign.pub` is the public key committed in the repo. Never commit `cosign.key`.

## Switching to the image

```bash
sudo bootc switch ghcr.io/maggunator/wazzite:bazzite
```
