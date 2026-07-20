![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/k9s-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/k9s-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/k9s-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/k9s-debian?display_date=published_at)

# k9s for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [k9s](https://github.com/derailed/k9s) hosted at [deb.griffo.io](https://deb.griffo.io)

<p align="center">
⭐⭐⭐ Love using k9s on Debian? Show your support by starring this repo or [subscribing](https://buy.stripe.com/aFa28q8hr0lRdlm4a2enS01) — from 1 October 2026, apt access requires a yearly subscription. ⭐⭐⭐
</p>

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

**Upstream architectures:** amd64, arm64, armhf (armv7), ppc64el and s390x (widest coverage of the batch; upstream also ships its own .deb/.rpm/.apk per architecture). No riscv64 or i386.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the k9s source code, see
[k9s](https://github.com/derailed/k9s).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-k9s-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-k9s-in-ubuntu.html)

### The Debian way

> ⚠️ **From 1 October 2026, apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/k9s-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y k9s
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/k9s-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <k9s_version> <build_version> <architecture>
# Example: ./build.sh 1.2.3 1 arm64
```

### Build for all architectures
```sh
./build.sh <k9s_version> <build_version> all
# Example: ./build.sh 1.2.3 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64, armhf, ppc64el, s390x)

## Disclaimer

- This repo is not open for issues related to k9s. This repo is only for _unofficial_ Debian packaging.
