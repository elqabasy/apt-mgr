#!/bin/bash
# Initial project setup - creates all required files

set -e

source load-config.sh

echo "🚀 Setting up project: $PACKAGE_NAME"

# Create directory structure
mkdir -p man completions etc debian/source build

# Create main script if it doesn't exist
if [[ ! -f "pkgmgr" && ! -f "$PACKAGE_NAME" ]]; then
    echo "❌ Main script not found. Please create the main script first."
    echo "💡 You can start with your existing pkgmgr script"
    exit 1
fi

# Create man pages if they don't exist
if [[ ! -f "man/pkgmgr.1" && ! -f "man/${PACKAGE_NAME}.1" ]]; then
    echo "📝 Creating default man page..."
    cat > "man/${PACKAGE_NAME}.1" << 'EOF'
.TH PKGMGR 1 "2024" "pkgmgr 1.1.0" "APT Package Management Tool"
.SH NAME
pkgmgr \- Professional APT package backup, restore and cleanup tool
.SH SYNOPSIS
.B pkgmgr
[\fICOMMAND\fR] [\fIOPTIONS\fR]
.SH DESCRIPTION
.B pkgmgr
is a comprehensive command-line utility designed to simplify package management on Debian-based systems.
.SH COMMANDS
.TP
.B backup [filename] [\-\-minimal]
Backup installed packages.
.TP
.B restore [filename] [\-\-dry-run]
Restore packages from backup file.
.TP
.B clean [\-\-aggressive] [\-\-dry-run]
Clean system packages.
.TP
.B status
Show system status.
.TP
.B analyze [\-\-size SIZE]
Analyze package sizes.
.TP
.B help
Show help message.
.TP
.B version
Show version information.
.SH AUTHOR
Mahros AL-Qabasy <mahros.elqabasy@gmail.com>
.SH "SEE ALSO"
.BR apt (8),
.BR dpkg (1)
EOF
fi

if [[ ! -f "man/pkgmgr.conf.5" && ! -f "man/${PACKAGE_NAME}.conf.5" ]]; then
    echo "📝 Creating configuration man page..."
    cat > "man/${PACKAGE_NAME}.conf.5" << 'EOF'
.TH PKGMGR.CONF 5 "2024" "pkgmgr 1.1.0" "pkgmgr configuration file"
.SH NAME
pkgmgr.conf \- Configuration file for pkgmgr
.SH DESCRIPTION
The
.B pkgmgr.conf
file contains configuration settings for the pkgmgr tool.
.SH AUTHOR
Mahros AL-Qabasy <mahros.elqabasy@gmail.com>
EOF
fi

# Create completion files if they don't exist
if [[ ! -f "completions/pkgmgr.bash" && ! -f "completions/${PACKAGE_NAME}.bash" ]]; then
    echo "📝 Creating bash completion..."
    cat > "completions/${PACKAGE_NAME}.bash" << 'EOF'
# bash completion for pkgmgr

_pkgmgr() {
    local cur prev words cword
    _init_completion || return

    local commands="backup restore clean status analyze help version"
    local backup_opts="--minimal"
    local restore_opts="--dry-run"
    local clean_opts="--aggressive --dry-run"
    local analyze_opts="--size"

    case "${prev}" in
        backup)
            COMPREPLY=($(compgen -W "${backup_opts}" -- "${cur}"))
            return 0
            ;;
        restore)
            COMPREPLY=($(compgen -W "${restore_opts}" -- "${cur}"))
            return 0
            ;;
        clean)
            COMPREPLY=($(compgen -W "${clean_opts}" -- "${cur}"))
            return 0
            ;;
        analyze)
            COMPREPLY=($(compgen -W "${analyze_opts}" -- "${cur}"))
            return 0
            ;;
        --size)
            COMPREPLY=($(compgen -W "1MB 10MB 50MB 100MB 500MB 1GB" -- "${cur}"))
            return 0
            ;;
        pkgmgr)
            COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
            return 0
            ;;
    esac

    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
    fi
}

complete -F _pkgmgr pkgmgr
EOF
fi

if [[ ! -f "completions/pkgmgr.zsh" && ! -f "completions/${PACKAGE_NAME}.zsh" ]]; then
    echo "📝 Creating zsh completion..."
    cat > "completions/${PACKAGE_NAME}.zsh" << 'EOF'
#compdef pkgmgr

_pkgmgr() {
    local state
    local -a commands backup_opts restore_opts clean_opts analyze_opts

    commands=(
        'backup:Backup installed packages'
        'restore:Restore packages from backup'
        'clean:Clean system packages'
        'status:Show system status'
        'analyze:Analyze package sizes'
        'help:Show help message'
        'version:Show version information'
    )

    backup_opts=('--minimal[Only user-installed packages]')
    restore_opts=('--dry-run[Simulate restore]')
    clean_opts=('--aggressive[Include config files and logs]' '--dry-run[Show what would be removed]')
    analyze_opts=('--size[Filter by minimum size]:size:(1MB 10MB 50MB 100MB 500MB 1GB)')

    _arguments -C \
        "1: :->commands" \
        "*::arg:->args"

    case $state in
        commands)
            _describe 'command' commands
            ;;
        args)
            case $words[1] in
                backup)
                    _arguments $backup_opts
                    ;;
                restore)
                    _arguments $restore_opts
                    ;;
                clean)
                    _arguments $clean_opts
                    ;;
                analyze)
                    _arguments $analyze_opts
                    ;;
            esac
            ;;
    esac
}

_pkgmgr "$@"
EOF
fi

# Create configuration file if it doesn't exist
if [[ ! -f "etc/pkgmgr.conf" && ! -f "etc/${PACKAGE_NAME}.conf" ]]; then
    echo "📝 Creating configuration file..."
    cat > "etc/${PACKAGE_NAME}.conf" << 'EOF'
# pkgmgr configuration file
# This file contains default settings for pkgmgr

# Backup directory (default: ~/.pkgmgr/backups)
# BACKUP_DIR=~/.pkgmgr/backups

# Log level: INFO, WARNING, ERROR (default: INFO)
# LOG_LEVEL=INFO

# Enable aggressive cleanup by default (default: false)
# AGGRESSIVE_CLEANUP=false

# Use minimal backup by default (default: false)
# MINIMAL_BACKUP=false

# Auto-update package lists before operations (default: true)
# AUTO_UPDATE=true
EOF
fi

# Create other required files
if [[ ! -f "LICENSE" ]]; then
    echo "📝 Creating LICENSE file..."
    cat > "LICENSE" << 'EOF'
MIT License

Copyright (c) 2024 Mahros AL-Qabasy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
fi

# Create debian/compat
# echo "13" > debian/compat

# Create debian/source/format
echo "3.0 (quilt)" > debian/source/format

echo "🎉 Project setup complete!"
echo "💡 Now run: ./rename-project.sh (if you have existing files to rename)"
echo "💡 Or run: ./build.sh (to build directly)"
