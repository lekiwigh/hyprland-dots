#!/bin/bash

LOGOS=(
    "/home/ghxsty/Pictures/fastfetch/ascii/gengar"
    "/home/ghxsty/Pictures/fastfetch/ascii/gengarmega"
    "/home/ghxsty/Pictures/fastfetch/ascii/gastly"
    "/home/ghxsty/Pictures/fastfetch/ascii/hunter"
)

# Choisir un logo aléatoire
RANDOM_LOGO=${LOGOS[$RANDOM % ${#LOGOS[@]}]}

# Vérifier que le fichier existe
if [ -f "$RANDOM_LOGO" ]; then
    fastfetch --logo "$RANDOM_LOGO" --logo-type file-raw
else
    echo "Erreur: $RANDOM_LOGO n'existe pas"
    fastfetch --logo "$RANDOM_LOGO" --logo-type file
fi