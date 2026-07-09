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

k9s_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$k9s_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <k9s_version> <build_version> [architecture]"
    echo "Example: $0 0.32.5 1 arm64"
    echo "Example: $0 0.32.5 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, ppc64el, s390x, all"
    exit 1
fi

# Function to map Debian architecture to k9s release name
get_k9s_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "Linux_amd64"
            ;;
        "arm64")
            echo "Linux_arm64"
            ;;
        "armhf")
            echo "Linux_armv7"
            ;;
        "ppc64el")
            echo "Linux_ppc64le"
            ;;
        "s390x")
            echo "Linux_s390x"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local k9s_release

    k9s_release=$(get_k9s_release "$build_arch")
    if [ -z "$k9s_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armhf, ppc64el, s390x"
        return 1
    fi

    local archive="k9s_${k9s_release}"
    echo "Building for architecture: $build_arch using $archive"

    # Clean up any previous builds for this architecture
    rm -rf "$archive" || true
    rm -f "${archive}.tar.gz" || true

    # Download and extract k9s binary for this architecture (k9s tags are v-prefixed)
    if ! wget "https://github.com/derailed/k9s/releases/download/v${k9s_VERSION}/${archive}.tar.gz"; then
        echo "❌ Failed to download k9s binary for $build_arch"
        return 1
    fi

    mkdir -p "$archive"
    if ! tar -xf "${archive}.tar.gz" -C "$archive"; then
        echo "❌ Failed to extract k9s binary for $build_arch"
        return 1
    fi

    rm -f "${archive}.tar.gz"

    # Build packages for supported Debian distributions
    declare -a arr=("bookworm" "trixie" "forky" "sid")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$k9s_VERSION-${BUILD_VERSION}~${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "k9s-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg k9s_VERSION="$k9s_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg K9S_RELEASE="$archive"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "k9s-$dist-$build_arch")"
        if ! docker cp "$id:/k9s_$FULL_VERSION.deb" - > "./k9s_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./k9s_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$archive" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building k9s $k9s_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64" "armhf" "ppc64el" "s390x")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la k9s_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
