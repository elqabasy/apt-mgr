#!/bin/bash
# Generate Debian packaging files from project.conf

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load-config.sh"

# Create debian directory if it doesn't exist
mkdir -p debian/source

# Generate debian/control
cat > debian/control << EOF
Source: ${PACKAGE_NAME}
Section: ${PACKAGE_SECTION}
Priority: ${PACKAGE_PRIORITY}
Maintainer: ${PACKAGE_MAINTAINER}
Build-Depends: debhelper-compat (= 13), dh-exec
Standards-Version: 4.6.2
Rules-Requires-Root: no
Homepage: ${PACKAGE_HOMEPAGE}

Package: ${PACKAGE_NAME}
Architecture: all
Depends: \${misc:Depends}, bash, apt
Suggests: bash-completion, zsh
Description: ${PACKAGE_DESCRIPTION}
 ${PACKAGE_DESCRIPTION}
 .
 Features:
  * Smart package backup with minimal or full options
  * Easy package restoration with dependency handling
  * Intelligent cleanup with safe and aggressive modes
  * System analysis to identify large packages
  * Distribution aware (Debian, Ubuntu, Kali Linux)
  * Bash and Zsh completion support
EOF

# Generate debian/changelog
cat > debian/changelog << EOF
${PACKAGE_NAME} (${PACKAGE_VERSION}) unstable; urgency=medium

  * Initial release
  * Professional APT package management tool
  * Backup, restore, and cleanup functionality
  * Bash and Zsh completion support
  * Comprehensive manual pages

 -- ${PACKAGE_MAINTAINER}  $(date -R)
EOF

# Generate debian/install
cat > debian/install << EOF
${PACKAGE_NAME} usr/bin
man/${PACKAGE_NAME}.1 usr/share/man/man1
man/${PACKAGE_NAME}.conf.5 usr/share/man/man5
completions/${PACKAGE_NAME}.bash usr/share/bash-completion/completions
completions/${PACKAGE_NAME}.zsh usr/share/zsh/vendor-completions
etc/${PACKAGE_NAME}.conf etc
LICENSE usr/share/doc/${PACKAGE_NAME}
README.md usr/share/doc/${PACKAGE_NAME}
EOF

# Generate debian/postinst
cat > debian/postinst << EOF
#!/bin/sh
# postinst script for ${PACKAGE_NAME}

set -e

case "\$1" in
    configure)
        # Update man page database
        if command -v mandb >/dev/null 2>&1; then
            mandb -q
        fi
        
        # Check if bash-completion is installed
        if command -v bash-completion >/dev/null 2>&1; then
            echo "Bash completion installed for ${PACKAGE_NAME}"
        fi
        
        echo "${PACKAGE_NAME} successfully installed. Run '${PACKAGE_NAME} help' for usage."
        ;;
    
    abort-upgrade|abort-remove|abort-deconfigure)
        ;;
    
    *)
        echo "postinst called with unknown argument $1" >&2
        exit 1
        ;;
esac

#DEBHELPER#

exit 0
EOF



# Generate debian/prerm
cat > debian/prerm << EOF
#!/bin/sh
# prerm script for ${PACKAGE_NAME}

set -e

case "\$1" in
    remove|upgrade)
        # Clean up completion files
        rm -f /usr/share/bash-completion/completions/${PACKAGE_NAME}
        rm -f /usr/share/zsh/vendor-completions/_${PACKAGE_NAME}
        ;;
    
    failed-upgrade)
        ;;
    
    *)
        echo "prerm called with unknown argument $1" >&2
        exit 1
        ;;
esac

#DEBHELPER#

exit 0
EOF

# Set executable permissions
chmod +x debian/postinst
chmod +x debian/prerm

echo "✅ Debian packaging files generated successfully!"
echo "📦 Package: ${PACKAGE_NAME}_${PACKAGE_VERSION}"
