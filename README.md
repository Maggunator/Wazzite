# wazzite

A custom [bootc](https://github.com/bootc-dev/bootc) image based on [Universal Blue](https://universal-blue.org/) projects (Bazzite, Bluefin). It extends those images with additional packages, Flatpaks, a Sway WM stack, and a Wazuh security agent.

# Community

If you have questions about this template after following the instructions, try the following spaces:
- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions)

# Repository Structure

## How the Build Works

The build pipeline looks like this:

```
build-desktop.yml        ← defines which image flavors to build (Bazzite, Bluefin, ...)
    └─> build-image.yml  ← orchestrates build, rechunk, tag, sign, and push per image
          └─> get-images/action.yml  ← resolves image flavor to concrete image names
                └─> Justfile (just build <image>)
                      └─> Containerfile
                            └─> build_files/build.sh  ← installs packages, flatpaks, etc.
```

## Which Images Get Built

**[.github/workflows/build-desktop.yml](.github/workflows/build-desktop.yml)** — top-level entry point.

The `matrix.image_flavor` list controls which image families are built:

```yaml
matrix:
  image_flavor: ["Bazzite"]          # currently only Bazzite
  # image_flavor: ["Bazzite", "Bluefin"]  # add Bluefin here to build it too
```

**[.github/actions/get-images/action.yml](.github/actions/get-images/action.yml)** — maps each flavor to concrete image names:

| Flavor | Images built |
|--------|-------------|
| `Bazzite` | `bazzite`, `bazzite-nvidia` |
| `Bluefin` | `bluefin`, `bluefin-nvidia` |
| `Server` | `ucore-minimal`, `ucore`, `ucore-nvidia`, `ucore-hci`, `ucore-hci-nvidia` |

**[Justfile](./Justfile)** — the `images` map at the top defines which upstream ublue-os base image and tag each image name resolves to (e.g. `bazzite` → `bazzite-dx-gnome:stable`, `bluefin` → `bluefin-dx:stable-daily`).

## Adding or Removing Packages

### RPM Packages

**[build_files/desktop_packages.sh](./build_files/desktop_packages.sh)** — the primary place to add/remove RPM packages. Uses `dnf install`. Example:

```bash
dnf install --setopt=install_weak_deps=False -y \
    your-package-name
```

**[build_files/build.sh](./build_files/build.sh)** — called first by the Containerfile. Contains top-level orchestration and any packages that must be installed before the other scripts run (currently `tmux`). Also enables systemd services.

**[build_files/desktop_changes.sh](./build_files/desktop_changes.sh)** — for system configuration changes (GSettings overrides, file modifications, etc.) rather than package installs.

### Flatpak Applications

**[build_files/install_flatpaks.sh](./build_files/install_flatpaks.sh)** — add or remove Flatpaks baked into the image. Example:

```bash
flatpak install -y flathub \
    org.example.App
```

> **Note:** Flatpaks installed here are baked into the OCI image layer. Users can still install additional Flatpaks at runtime via GNOME Software or the `flatpak` CLI.

### System Files

**[build_files/system_files/](./build_files/system_files/)** — static files copied into the image. The directory structure mirrors the root filesystem. Currently contains:
- Sway configuration (`/etc/sway/sway_config`)
- Inter fonts (`/usr/share/fonts/inter/`)
- GSettings overrides (`/usr/share/glib-2.0/schemas/`)

## Containerfile

**[Containerfile](./Containerfile)** — defines which upstream base image to pull and passes build arguments to `build.sh`. The `BASE_IMAGE` and `TAG_VERSION` are set dynamically by the Justfile based on the target image name.

## When Does the Image Get Published to GHCR?

The push to `ghcr.io/maggunator/wazzite` only happens when:

1. **Manual trigger** — go to the Actions tab on GitHub, select the workflow, and click **"Run workflow"**. This triggers `workflow_dispatch` and will push the result.
2. **Merge Queue** — when a PR enters the merge group (`merge_group` event).
3. **Scheduled build** — every Sunday at 6:41 UTC (cron: `41 6 * * 0`).

Regular pushes to `main` and pull requests will build the image to verify it compiles, but will **not** push the result to the registry.

# Initial Setup

## Step 1: Creating a Cosign Key

Container signing is required. Install [cosign](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/#installing-cosign-with-the-cosign-binary) and run inside the repo folder:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

> [!WARNING]
> Never commit `cosign.key` into git. Add it to `.gitignore` immediately.

Add the key to GitHub:
- Go to repository **Settings → Secrets and Variables → Actions**
- Add a secret named `SIGNING_SECRET` with the contents of `cosign.key`

## Step 2: Switch to Your Image

From your bootc system:

```bash
sudo bootc switch ghcr.io/maggunator/wazzite:bazzite
# or
sudo bootc switch ghcr.io/maggunator/wazzite:bluefin
```

# Building Locally

Requires [just](https://just.systems/man/en/introduction.html) and `podman`.

```bash
# Build a specific image variant
just build bazzite
just build bazzite-nvidia
just build bluefin
just build bluefin-nvidia

# Build and run an ISO
just build-iso bazzite

# Clean build artifacts
just clean
```

# Building Disk Images

The [build-disk.yml](./.github/workflows/build-disk.yml) workflow creates ISO, qcow2, or raw images using [bootc-image-builder](https://osbuild.org/docs/bootc/). Disk images are available as workflow artifacts, or can be uploaded to S3 via [rclone](https://rclone.org/).

Required S3 secrets (optional): `S3_PROVIDER`, `S3_BUCKET_NAME`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_REGION`, `S3_ENDPOINT`.
