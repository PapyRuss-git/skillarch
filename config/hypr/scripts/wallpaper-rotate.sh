#!/usr/bin/env sh
set -eu

WALLPAPER_DIR="${WALLPAPER_DIR:-/opt/skillarch/assets/wallpaper-slideshow}"
INTERVAL="${WALLPAPER_INTERVAL:-300}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/skillarch"
STATE_FILE="$STATE_DIR/wallpaper-current"
LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/skillarch-wallpaper-rotate.lock"

mkdir "$LOCK_DIR" 2>/dev/null || exit 0
cleanup() {
    rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

mkdir -p "$STATE_DIR"

pick_wallpaper() {
    list_file="$(mktemp)"
    candidates_file="$(mktemp)"

    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print | sort > "$list_file"

    if [ ! -s "$list_file" ]; then
        rm -f "$list_file" "$candidates_file"
        return 1
    fi

    current=""
    if [ -f "$STATE_FILE" ]; then
        current="$(cat "$STATE_FILE")"
    fi

    grep -Fvx "$current" "$list_file" > "$candidates_file" || true
    if [ ! -s "$candidates_file" ]; then
        cp "$list_file" "$candidates_file"
    fi

    if command -v shuf >/dev/null 2>&1; then
        shuf -n 1 "$candidates_file"
    else
        sed -n '1p' "$candidates_file"
    fi

    rm -f "$list_file" "$candidates_file"
}

apply_wallpaper() {
    wallpaper="$1"

    tries=0
    while [ "$tries" -lt 40 ]; do
        if hyprctl hyprpaper wallpaper ",$wallpaper,cover" >/dev/null 2>&1; then
            printf '%s\n' "$wallpaper" > "$STATE_FILE"
            return 0
        fi
        tries=$((tries + 1))
        sleep 0.5
    done
    return 1
}

while :; do
    wallpaper="$(pick_wallpaper)" || exit 0
    if apply_wallpaper "$wallpaper"; then
        sleep "$INTERVAL"
    else
        sleep 5
    fi
done
