#!/bin/bash
# build-deb.sh - Build apt-mgr Debian package to ./build directory

set -e

PACKAGE="apt-mgr"
BUILDDIR="./build"
VERSION=$(dpkg-parsechangelog -S Version 2>/dev/null | cut -d'-' -f1)

echo "Building $PACKAGE version $VERSION..."

# Clean previous builds
rm -rf "$BUILDDIR"
mkdir -p "$BUILDDIR"

# Build the package with output directory
dpkg-buildpackage -us -uc -b

# Move all build artifacts to build directory
echo "Moving build artifacts to $BUILDDIR/..."
mv ../${PACKAGE}_* "$BUILDDIR/" 2>/dev/null || true

# List the created files
echo ""
echo "Build complete! Created files in $BUILDDIR/:"
ls -la "$BUILDDIR"/

# Show package info
echo ""
echo "Package information:"
cd "$BUILDDIR"
DEB_FILE=$(ls ${PACKAGE}_${VERSION}_*.deb 2>/dev/null | head -1)
if [ -n "$DEB_FILE" ]; then
    echo "Package: $DEB_FILE"
    dpkg -I "$DEB_FILE" | grep -E "(Package|Version|Architecture|Installed-Size)"
else
    echo "No .deb file found!"
fi
