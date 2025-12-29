#!/bin/bash

ICON_DIRS=("$HOME/.icons" "/usr/share/icons")

# Récupérer les thèmes de curseur
CURSORS=$(find "${ICON_DIRS[@]}" -maxdepth 2 -type d -name cursors 2>/dev/null \
  | sed 's|/cursors||' | xargs -n1 basename | sort -u)

# Menu rofi - choix du curseur
CHOICE=$(echo "$CURSORS" | rofi -dmenu -i -p "Cursors 󰇀:")

[ -z "$CHOICE" ] && exit 0

# Trouver le dossier du thème choisi
THEME_DIR=""
for dir in "${ICON_DIRS[@]}"; do
    if [ -d "$dir/$CHOICE" ]; then
        THEME_DIR="$dir/$CHOICE"
        break
    fi
done

# Chercher une image de preview
PREVIEW_IMG=$(find "$THEME_DIR" -maxdepth 2 -type f \( \
    -iname "cursor.png" -o -iname "preview.png" -o -iname "icon.png" -o -iname "preview.gif" \
\) | head -n 1)

# Preview avec feh
if [ -n "$PREVIEW_IMG" ]; then
    feh --title "Cursor preview: $CHOICE" --geometry 650x750 "$PREVIEW_IMG" &
    FEH_PID=$!
fi

# Choix taille curseur
SIZE=$(printf "24\n42" | rofi -dmenu -i -p "Cursor size:")

# Cancel size → on ferme feh
if [ -z "$SIZE" ]; then
    [ -n "$FEH_PID" ] && kill "$FEH_PID" 2>/dev/null
    exit 0
fi

# Confirmation finale
CONFIRM=$(printf "Yes\nNo" | rofi -dmenu -i -p "Apply $CHOICE ($SIZE px) ?")

# Fermer feh
[ -n "$FEH_PID" ] && kill "$FEH_PID" 2>/dev/null

[ "$CONFIRM" != "Yes" ] && exit 0

# GTK (apps)
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-cursor-theme-name=$CHOICE
gtk-cursor-theme-size=$SIZE
EOF

# XCursor (Wayland + XWayland)
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/cursor.conf <<EOF
XCURSOR_THEME=$CHOICE
XCURSOR_SIZE=$SIZE
EOF

# Appliquer à chaud
hyprctl setcursor "$CHOICE" "$SIZE" 2>/dev/null

notify-send "Cursor applied" "$CHOICE ($SIZE px)"
