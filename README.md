# apt-mgr

**Professional APT Package Management Tool**

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Debian%20|%20Ubuntu%20|%20Kali-lightgrey.svg)

`apt-mgr` is a comprehensive command-line utility designed to simplify package management on Debian-based systems (Debian, Ubuntu, Kali Linux). It provides robust backup/restore capabilities, intelligent cleanup features, and detailed system analysis in a user-friendly interface.

**Author**: Mahros AL-Qabasy ([mahros.elqabasy@gmail.com](mailto:mahros.elqabasy@gmail.com))  
**Repository**: https://github.com/elqabasy/apt-mgr

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
wget https://raw.githubusercontent.com/elqabasy/apt-mgr/main/apt-mgr
chmod +x apt-mgr
sudo mv apt-mgr /usr/local/bin/
