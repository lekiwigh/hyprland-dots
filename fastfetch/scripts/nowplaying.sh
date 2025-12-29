#!/bin/bash

# Récupère le média en cours de lecture
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
status=$(playerctl status 2>/dev/null)

# Vérifie si quelque chose est en train de jouer
if [ -z "$title" ]; then
    echo "Nothing playing"
    exit 0
fi

# Barre de progression simple (optionnelle)
duration=$(playerctl metadata mpris:length 2>/dev/null)
position=$(playerctl position 2>/dev/null)

if [ -n "$duration" ] && [ "$duration" -gt 0 ]; then
    total_blocks=20
    progress=$((position*total_blocks/duration/1000000))
    bar=$(printf "%-${total_blocks}s" "#" | sed "s/ /-/g")
    bar="${bar:0:$progress}$(printf "%0.s-" $(seq $progress $total_blocks))"
else
    bar="--------------------"
fi

# Affiche le résultat
echo "$artist - $title [$bar]"
