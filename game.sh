#!/bin/sh
printf '\033c\033]0;%s\a' Neko Noodles
base_path="$(dirname "$(realpath "$0")")"
"$base_path/game.arm64" "$@"
