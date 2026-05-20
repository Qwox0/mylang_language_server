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

tail -F ~/.local/state/nvim/lsp.log |
    stdbuf -oL awk -F'\t' '$3 == "\"mylang_ls\""' |
    while IFS=$'\t' read -r i _ lsp _ body; do
        echo "$(cut -d' ' -f -2 <<< "$i") $lsp:"

        body="${body#\'}"
        body="${body%\'}"
        body="${body#\"}"
        body="${body%\"}"
        echo "$body" | sed 's/\(\\r\)\?\\n/\n/g' | while read -r line; do
            if [[ "$line" == "{"* ]]; then
                jq -C <<< "$line" || echo "$line"
            else
                echo "$line"
            fi
        done
        echo ""
    done
