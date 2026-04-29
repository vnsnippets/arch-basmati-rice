#!/bin/bash

TARGET_DIR="$HOME/.config"
CURRENT_DATE=$(date +"%Y%m%d%H%M")
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

# Specific folder paths
SDDM_SOURCE="$CURRENT_DIR/sddm"
SDDM_TARGET="/usr/share/sddm/themes/basmati-rice"
STARSHIP_SOURCE="$CURRENT_DIR/starship"

# Mode tracking: "none", "modules", or "sddm"
MODE="none"

# --- HELP MESSAGE ---
show_help() {
    echo "Usage: ./$SCRIPT_NAME [FLAGS] [FOLDERS...]"
    echo ""
    echo "Flags:"
    echo "  --modules   Symlink specified folder(s) as whole directories into $TARGET_DIR."
    echo "  --starship  Inline files from ./starship/ directly into $TARGET_DIR."
    echo "  --sddm      Install SDDM theme to system directory (requires sudo)."
    echo ""
    echo "Example: ./$SCRIPT_NAME --modules nvim kitty --starship --sddm"
    exit 0
}

if [ $# -eq 0 ]; then
    show_help
fi

mkdir -p "$TARGET_DIR"

for param in "$@"; do
    case "$param" in
        --sddm)
            # Logic strictly targeting the ./sddm folder
            if [ ! -d "$SDDM_SOURCE" ]; then
                echo "  Error: SDDM source folder '$SDDM_SOURCE' not found."
            else
                echo "󰑨  Processing SDDM Theme (System access required)..."
                sudo -v
                if [ -d "$SDDM_TARGET" ]; then
                    BACKUP_SDDM="${SDDM_TARGET}.${CURRENT_DATE}"
                    echo "󰆓  Backing up existing SDDM theme: $SDDM_TARGET > $BACKUP_SDDM"
                    sudo mv "$SDDM_TARGET" "$BACKUP_SDDM"
                fi
                sudo mkdir -p "$SDDM_TARGET"
                sudo cp -r "$SDDM_SOURCE/." "$SDDM_TARGET/"
                sudo -k
                echo "  SDDM Theme installed to: $SDDM_TARGET"
            fi
            MODE="none" # Reset to prevent eating subsequent params
            continue
            ;;
        --starship)
            # Logic strictly targeting the ./starship folder
            if [ ! -d "$STARSHIP_SOURCE" ]; then
                echo "  Error: Starship source folder '$STARSHIP_SOURCE' not found."
            else
                echo "󱀵  Processing Starship configuration..."
                find "$STARSHIP_SOURCE" -maxdepth 1 -not -path "$STARSHIP_SOURCE" | while read -r filepath; do
                    filename=$(basename "$filepath")
                    [[ "$filename" == "$SCRIPT_NAME" ]] && continue

                    dest_file_path="$TARGET_DIR/$filename"
                    
                    # Backup real files if they exist
                    if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                        BACKUP_FILE_PATH="${dest_file_path}.${CURRENT_DATE}.bak"
                        echo "󰆓  Backing up: $dest_file_path"
                        mv "$dest_file_path" "$BACKUP_FILE_PATH"
                    fi

                    ln -sf "$filepath" "$dest_file_path"
                    echo "   File Linked: $filename > $dest_file_path"
                done
            fi
            MODE="none" # Reset to prevent eating subsequent params
            continue
            ;;
        --modules)
            MODE="modules"
            echo "󱂬  Mode Switch: Symlinking folders to $TARGET_DIR"
            continue
            ;;
        -h|--help)
            show_help
            ;;
    esac

    # Logic execution based on active MODE
    if [[ "$MODE" == "modules" ]]; then
        if [ ! -d "$CURRENT_DIR/$param" ]; then
            echo "  Skipping: '$param' folder not found."
            continue
        fi

        DEST_PATH="$TARGET_DIR/$param"
        
        # Folder preservation logic
        if [ -d "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
            BACKUP_FULL_PATH="${DEST_PATH}.${CURRENT_DATE}.bak"
            echo "󰆓  Backing up: $DEST_PATH > $BACKUP_FULL_PATH"
            mv "$DEST_PATH" "$BACKUP_FULL_PATH"
        fi

        [ -L "$DEST_PATH" ] && rm "$DEST_PATH"
        ln -s "$CURRENT_DIR/$param" "$DEST_PATH"
        echo "  Folder Linked: $param > $DEST_PATH"
    fi
done

echo "  Setup complete."