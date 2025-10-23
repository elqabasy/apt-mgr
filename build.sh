#!/bin/bash
# Build script that uses project.conf

set -e

source load-config.sh

echo "🔨 Building ${PACKAGE_NAME} ${PACKAGE_VERSION}..."


# Verify required files exist
echo "🔍 Verifying required files..."
required_files=(
    "$PACKAGE_NAME"
    "man/${PACKAGE_NAME}.1"
    "man/${PACKAGE_NAME}.conf.5"
    "completions/${PACKAGE_NAME}.bash"
    "completions/${PACKAGE_NAME}.zsh"
    "etc/${PACKAGE_NAME}.conf"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Required file missing: $file"
        echo "💡 Run ./rename-project.sh first to rename files"
        exit 1
    fi
    echo "✅ Found: $file"
done

# Generate Debian files first
echo "📄 Generating Debian packaging files..."
./generate-debian-files.sh

# Clean previous builds
if [[ -d "$BUILDDIR" ]]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "$BUILDDIR"
fi

# Create build directory
mkdir -p "$BUILDDIR"

# Build package
echo "🏗️  Building Debian package..."
if dpkg-buildpackage -us -uc -b; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Move artifacts to build directory
echo "📁 Moving artifacts to ${BUILDDIR}/..."
mv ../${PACKAGE_NAME}_* "$BUILDDIR/" 2>/dev/null || true

# Clean up temporary files
echo "🧹 Cleaning temporary files..."
rm -f ../${PACKAGE_NAME}_*

# Display results
echo ""
echo "🎉 Build complete! Files in ${BUILDDIR}/:"
ls -la "$BUILDDIR"/

# Show package info
echo ""
echo "📊 Package information:"
DEB_FILE=$(ls "$BUILDDIR"/*.deb 2>/dev/null | head -1)
if [[ -n "$DEB_FILE" ]]; then
    echo "Package: $(basename "$DEB_FILE")"
    dpkg -I "$DEB_FILE" | grep -E "(Package|Version|Architecture|Installed-Size)|Description"
    
    echo ""
    echo "💡 To install: sudo dpkg -i $BUILDDIR/$(basename "$DEB_FILE")"
else
    echo "❌ No .deb file found in build directory!"
    exit 1
fi
