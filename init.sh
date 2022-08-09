#!/bin/bash

log_colored() {
    if [ "$1" = "info" ]; then
        echo "$(printf "\033")[30;44;1m(i)$(printf "\033")[0m $2"
    elif [ "$1" = "warn" ]; then
        echo "$(printf "\033")[30;43;1m(*)$(printf "\033")[0m $2"
    elif [ "$1" = "error" ]; then
        echo "$(printf "\033")[30;41;1m(!)$(printf "\033")[0m $2"
    else
        return
    fi
}

check_os() {
    if [ "$(uname)" = "Darwin" ]; then
        log_colored "info" "OS is supported"
    else
        log_colored "error" "OS is not supported"
        log_colored "info" "$(uname -a)"
        exit 1
    fi
}

link() {
    ln -s "$1" "$2"
}

make_symbolic() {
    local repo_dir="$HOME/dotfiles"

    if [ ! -e "$HOME/$2" ]; then
        log_colored "info" "Made $HOME/$2"
        link "${repo_dir}/$1" "$HOME/$2"
        return
    fi

    local result="$(ls -la $HOME/$2)"
    if [ "${result:0:1}" = "l" ]; then
        local old_link="${result##*-> }"
        if [ "${old_link}" != "${repo_dir}/$1" ]; then
            log_colored "warn" "Changed link ${old_link} => ${repo_dir}/$1"
            unlink "$HOME/$2"
            link "${repo_dir}/$1" "$HOME/$2"
        fi
    else
        log_colored "warn" "Moved $2 => ${repo_dir}/not_sync/$2"
        mv -f "$HOME/$2" "${repodir}/not_sync/moved/"
    fi
}

make_symbolics() {
    make_symbolic "sync/config/bash/.bashrc" ".bashrc"
    make_symbolic "sync/config/zsh/.zshrc" ".zshrc"
    make_symbolic "sync/config/zsh/.zshenv" ".zshenv"
    make_symbolic "sync/config/fish" ".config/fish"
    make_symbolic "sync/config/neofetch" ".config/neofetch"
    make_symbolic "sync/config/macos/.CFUserTextEncoding" ".CFUserTextEncoding"

    make_symbolic "not_sync/data/fontforge" ".config/fontforge"
    make_symbolic "not_sync/data/.local" ".local"
    make_symbolic "not_sync/data/.viminfo" ".npm"
    make_symbolic "not_sync/data/.terminfo" ".terminfo"
    make_symbolic "not_sync/data/.viminfo" ".viminfo"
    make_symbolic "not_sync/data/.vscode-oss" ".vscode-oss"

    make_symbolic "not_sync/cache" ".cache"
}

make_dirs() {
    local sync="$HOME/dotfiles/sync"
    local not_sync="$HOME/dotfiles/not_sync"
    local dirs=(
        "${sync}/config"
        "${sync}/config/bash"
        "${sync}/config/zsh"
        "${sync}/config/fish"
        "${sync}/config/neofetch"
        "${sync}/config/macos"
        "${sync}/config/alacritty"

        "${not_sync}"
        "${not_sync}/data"
        "${not_sync}/data/fontforge"
        "${not_sync}/data/.local"
        "${not_sync}/data/.npm"
        "${not_sync}/data/.terminfo"
        "${not_sync}/data/.viminfo"
        "${not_sync}/data/.vscode-oss"

        "${not_sync}/cache"
        "${not_sync}/moved"

        "${not_sync}/histories/bash"
        "${not_sync}/histories/zsh"
    )

    for dir in "${dirs[@]}" ; do
        if [ ! -e "${dir}" ]; then
            log_colored "info" "Made ${dir}"
            mkdir "${dir}"
        fi
    done
}

check_os
make_dirs
make_symbolics

setup_python(){
    if [ -e "/usr/local/bin/python" ]; then
        log_colored "warn" "A symbolic link already exists."
    else
        ln -s "/usr/local/opt/python@3.10/bin/python3" "/usr/local/bin/python"
        log_colored "info" "A symbolic link has been created."
    fi
}
setup_python