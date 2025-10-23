# pkgmgr

**Professional APT Package Management Tool**

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Debian%20|%20Ubuntu%20|%20Kali-lightgrey.svg)

`pkgmgr` is a comprehensive command-line utility designed to simplify package management on Debian-based systems (Debian, Ubuntu, Kali Linux). It provides robust backup/restore capabilities, intelligent cleanup features, and detailed system analysis in a user-friendly interface.

**Author**: Mahros AL-Qabasy ([mahros.elqabasy@gmail.com](mailto:mahros.elqabasy@gmail.com))  
**Repository**: https://github.com/elqabasy/pkgmgr

## ✨ Features

- **🔒 Smart Backup**: Export installed packages with minimal or full options
- **🔄 Easy Restore**: Reinstall packages from backup with dependency handling  
- **🧹 Intelligent Cleanup**: Safe and aggressive cleanup modes with dry-run support
- **📊 System Analysis**: Identify large packages and disk usage patterns
- **🎯 Distribution Aware**: Optimized for Kali Linux, Ubuntu, and Debian
- **🚀 User Friendly**: Simple commands with colored output and logging
- **📝 Comprehensive Logging**: Detailed operation logs for troubleshooting

## 🛠️ Installation

### Direct Download
```bash
wget https://raw.githubusercontent.com/elqabasy/pkgmgr/main/pkgmgr
chmod +x pkgmgr
sudo mv pkgmgr /usr/local/bin/
```

### From Source
```bash
git clone https://github.com/elqabasy/pkgmgr.git
cd pkgmgr
sudo make install
```

### Debian Package (Coming Soon)
```bash
# Download .deb file and install
sudo dpkg -i pkgmgr_1.1.0_all.deb
```

## 📖 Usage Examples

```bash
# Backup user-installed packages
pkgmgr backup --minimal

# Full system backup
pkgmgr backup

# Preview aggressive cleanup
pkgmgr clean --aggressive --dry-run

# Perform safe cleanup
pkgmgr clean

# Restore from backup
pkgmgr restore my-backup.txt

# Analyze large packages (>100MB)
pkgmgr analyze --size 100MB

# Show system status
pkgmgr status

# Display help
pkgmgr help
```

## 🗂️ Command Reference

### Backup
```bash
pkgmgr backup [filename]          # Backup to file
pkgmgr backup --minimal           # Only user-installed packages
```

### Restore
```bash
pkgmgr restore [filename]         # Restore from backup
pkgmgr restore --dry-run          # Simulate restore
```

### Cleanup
```bash
pkgmgr clean                      # Safe cleanup
pkgmgr clean --aggressive         # Include config files, logs
pkgmgr clean --dry-run            # Show what would be removed
```

### Analysis
```bash
pkgmgr status                     # System status and cleanup potential
pkgmgr analyze                    # Find largest packages
pkgmgr analyze --size 50MB        # Packages larger than 50MB
```

## 📁 Project Structure

```
pkgmgr/
├── pkgmgr                 # Main bash script
├── README.md              # This file
├── LICENSE               # MIT License
├── Makefile              # Installation makefile
└── debian/               # Debian package build files
    ├── control
    ├── postinst
    └── changelog
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Bug Reports

If you encounter any issues, please [open an issue](https://github.com/elqabasy/pkgmgr/issues) on GitHub.

---

**Maintained by Mahros AL-Qabasy** • [GitHub](https://github.com/elqabasy) • [Email](mailto:mahros.elqabasy@gmail.com)


### GitHub Topics:
```
apt, package-manager, backup, restore, cleanup, debian, ubuntu, kali-linux, bash, devops, system-administration, debian-package
```
