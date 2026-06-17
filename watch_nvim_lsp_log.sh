#!/usr/bin/env bash

set -e

script_dir="$(dirname "$(readlink -f "$0")")"

info() {
    echo -e "\e[92;1m+++\e[0m $1"
}

warn() {
    echo -e "\e[93;1m+++ WARN:\e[0m $1"
}

error() {
    echo -e "\e[91;1m+++ ERROR:\e[0m $1" >&2
    if [ ${2:-1} -ne 0 ]; then exit ${2:-1}; fi
}

esc=$(printf '\033')
bold_red="${esc}[91;1m"
reset="${esc}[0m"
newline_color="${esc}[2m"
reset_newline_color="${esc}[22m"

#rm ~/.local/state/nvim/logs/lsp.log || true

tail -F ~/.local/state/nvim/logs/lsp.log |
    stdbuf -oL awk -F'\t' '$3 == "\"mylang_ls\""' |
    while IFS=$'\t' read -r i _ lsp _ body; do
        echo -n "${bold_red}$(cut -d' ' -f -2 <<< "$i") $lsp:${reset} "

        echo "$body" | "$script_dir/dev/out/split_around_jsons" | while read -r line; do
            #warn "$(declare -p line)"
            if [[ "$line" == "{"* ]]; then
                fixed_json="$(sed 's/\\"/"/g;s/\\\\/\\/g' <<< "$line")"
                #warn "$(declare -p fixed_json)"
                echo -n "$fixed_json" | jq -C || echo "$fixed_json"
            else
                echo -n "$line"
            fi | sed 's/\(\\r\)\?\\n/'$newline_color'&\n⤷'$reset_newline_color'/g'
        done
        printf "\n\n"
    done
