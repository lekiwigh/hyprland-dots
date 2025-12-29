#!/bin/bash

# ============================================================================
# Pywal Wallpaper Changer with swww animations
# ============================================================================

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
WAL_CACHE="$HOME/.cache/wal"

# ============================================================================
# Functions
# ============================================================================

apply_wallpaper() {
    local wall_path="$1"
    swww img "$wall_path" \
        --transition-type any \
        --transition-angle 45 \
        --transition-step 50 \
        --transition-fps 144 \
        --transition-duration 1.5
}

apply_pywal_colors() {
    local wall_path="$1"
    PYWAL_DONT_RELOAD_WALLPAPER=1 wal -i "$wall_path"
}

apply_pywal_colors_16() {
    local wall_path="$1"
    PYWAL_DONT_RELOAD_WALLPAPER=1 wal --cols16 -i "$wall_path"    # --16 palette--
}

update_telegram() {
    wal-telegram --wal 2>/dev/null
}

update_rofi_colors() {
    sed -n \
        -e 's/@define-color background /bg0 : /p' \
        -e 's/@define-color foreground /fg0 : /p' \
        -e 's/@define-color color1 /red : /p' \
        -e 's/@define-color color2 /green : /p' \
        -e 's/@define-color color3 /yellow : /p' \
        -e 's/@define-color color4 /blue : /p' \
        "$WAL_CACHE/colors-waybar.css" \
        | sed 's/;$/;/' \
        | sed '1s/^/* {\n/' \
        | sed '$s/$/\n}/' \
        > "$WAL_CACHE/rofi-colors.rasi"
}

update_cava_colors() {
    ~/bin/update-cava-colors
}

update_firefox_pywalfox() {
    local wall_path="$1"
    
    # Vérifie si Firefox est ouvert
    if ! pgrep -x firefox > /dev/null; then
        echo "Firefox is not running, skipping Pywalfox update"
        return
    fi
    
    # Crée un lien symbolique pour que Pywalfox trouve le wallpaper
    ln -sf "$wall_path" "$HOME/.cache/wal/wal" 2>/dev/null
    
    # Met à jour Pywalfox
    if command -v pywalfox &> /dev/null; then
        pywalfox update 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Pywalfox updated successfully"
        else
            echo "Pywalfox update failed"
        fi
    else
        echo "Pywalfox not installed"
    fi
}

update_hyprlock() {
    local wall_path="$1"
    local wall_path_abs=$(realpath "$wall_path")
    sed "s|__WALLPAPER__|$wall_path_abs|" \
        "$HOME/.config/hypr/hyprlock.conf.template" \
        > "$HOME/.config/hypr/hyprlock.conf"
}

update_hyprland_borders() {
    local color1=$(sed -n '2p' "$WAL_CACHE/colors" | tr -d '\n')
    local color2=$(sed -n '3p' "$WAL_CACHE/colors" | tr -d '\n')
    local rgba1="rgba(${color1:1}ee)"
    local rgba2="rgba(${color2:1}ee)"
    
    sed -i "s|col.active_border =.*|col.active_border = $rgba1 $rgba2 45deg|" \
        "$HOME/.config/hypr/hyprland.conf"
    hyprctl reload
}

update_wlogout() {
    local wlogout_colors="$HOME/.config/wlogout/colors.css"
    
    # Récupère les couleurs pywal
    local bg=$(sed -n '1p' "$WAL_CACHE/colors")
    local bg2=$(sed -n '2p' "$WAL_CACHE/colors")
    local bg3=$(sed -n '3p' "$WAL_CACHE/colors")
    local fg=$(sed -n '8p' "$WAL_CACHE/colors")
    local accent=$(sed -n '5p' "$WAL_CACHE/colors")
    
    # Crée le fichier CSS pour wlogout
    cat > "$wlogout_colors" << EOF
/* Pywal colors for wlogout */
* {
    background: ${bg};
    background-secondary: ${bg2};
    background-hover: ${bg3};
    foreground: ${fg};
    accent: ${accent};
}

window {
    background-color: ${bg}ee;
}

button {
    background-color: ${bg2};
    color: ${fg};
    border: 2px solid ${accent};
}

button:hover {
    background-color: ${bg3};
    border-color: ${accent};
}

button:focus {
    background-color: ${accent};
    color: ${bg};
}
EOF
    
    echo "wlogout colors updated"
}

update_discord() {
    walcord
}

cleanup_preview() {
    pkill -f "feh --zoom fill"
}

# ============================================================================
# Main Script
# ============================================================================

# Select wallpaper
WALL=$(ls "$WALLPAPER_DIR" | rofi -dmenu -i -p "Wallpapers 󰸉 : ")

if [ -z "$WALL" ]; then
    exit 0
fi

WALL_PATH="$WALLPAPER_DIR/$WALL"

# Show preview
feh --zoom fill --geometry 1750x960 "$WALL_PATH" &

# Confirmation
CONFIRM=$(echo -e "Basic\n16 Colors\nNo" | rofi -dmenu -i -p "Want ts ghxsty 󰊠 ?")

if [[ "$CONFIRM" == "Basic" ]]; then
    cleanup_preview
    
    # Apply all changes
    apply_wallpaper "$WALL_PATH"
    apply_pywal_colors "$WALL_PATH"
    update_telegram
    update_rofi_colors
    update_cava_colors
    update_hyprlock "$WALL_PATH"
    update_hyprland_borders
    update_discord
    update_wlogout

    notify-send "Pywal" "Colors Updated ✓"
elif [[ "$CONFIRM" == "16 Colors" ]]; then
    cleanup_preview
    
    # Apply all changes
    apply_wallpaper "$WALL_PATH"
    apply_pywal_colors_16 "$WALL_PATH"
    update_telegram
    update_rofi_colors
    update_cava_colors
    update_hyprlock "$WALL_PATH"
    update_hyprland_borders
    update_discord
    update_wlogout

    notify-send "Pywal 16" "Colors Updated ✓"
else
    notify-send "Pywal" "Colors Unchanged"
fi

cleanup_preview