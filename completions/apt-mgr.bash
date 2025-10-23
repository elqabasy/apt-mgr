# bash completion for apt-mgr

_apt_mgr() {
    local cur prev words cword
    _init_completion || return

    local commands="backup restore clean status analyze help version completion"
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
        completion)
            COMPREPLY=($(compgen -W "bash zsh" -- "${cur}"))
            return 0
            ;;
        apt-mgr)
            COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
            return 0
            ;;
    esac

    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
    fi
}

complete -F _apt_mgr apt-mgr
