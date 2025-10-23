#compdef apt-mgr

_apt-mgr() {
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
        'completion:Generate shell completion'
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
                completion)
                    _arguments ':shell:(bash zsh)'
                    ;;
            esac
            ;;
    esac
}

_apt-mgr "$@"
