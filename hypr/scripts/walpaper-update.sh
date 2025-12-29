#!/bin/bash

# Chemin du wallpaper choisi (argument)
wall="$1"

if [ ! -f "$wall" ]; then
    echo "Erreur : pas de fichier wallpaper."
    exit 1
fi

# 1) Change le wallpaper
swww img "$wall"

# 2) Génère les couleurs depuis ce wallpaper, sans toucher au wallpaper
#    -n = ne change pas le fond, juste les couleurs
wal -n -i "$wall"

# 3) Les applications (Waybar, Kitty, Rofi) lisent automatiquement ~/.cache/wal/colors-*
