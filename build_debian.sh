#!/bin/bash
set -euo pipefail

# Upstream Linux architectures for k9s (https://github.com/derailed/k9s):
#   amd64    -> k9s_Linux_amd64.tar.gz
#   arm64    -> k9s_Linux_arm64.tar.gz
#   armhf    -> k9s_Linux_armv7.tar.gz
#   ppc64el  -> k9s_Linux_ppc64le.tar.gz
#   s390x    -> k9s_Linux_s390x.tar.gz
#
# amd64, arm64, armhf (armv7), ppc64el and s390x (widest coverage of the batch; upstream also ships its own .deb/.rpm/.apk per architecture). No riscv64 or i386.
# TODO: implement k9s build

k9s_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$k9s_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <k9s_version> <build_version> [architecture]"
    echo "Example: $0 1.2.3 1 arm64"
    echo "Example: $0 1.2.3 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, ppc64el, s390x, all"
    exit 1
fi

echo "build_debian.sh for k9s is not implemented yet."
exit 1
