#!/bin/bash

TARGET_DIR="$HOME/.config"
CURRENT_DATE=$(date +"%Y%m%d%H%M")
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

# SDDM specific variables
SDDM_SOURCE="$CURRENT_DIR/sddm"
SDDM_TARGET="/usr/share/sddm/themes/basmati-rice"

# Mode tracking: "none", "modules", "root", or "sddm"
MODE="none"

# --- HELP MESSAGE ---
show_help() {
    echo "Usage: ./$SCRIPT_NAME [FLAGS] [FOLDERS...]"
    echo ""
    echo "Flags:"
    echo "  --modules        Symlink the specified folder(s) as a whole into $TARGET_DIR."
    echo "  --include-root   Inline the contents of the specified folder(s) into $TARGET_DIR."
    echo "  --sddm           Install the SDDM theme to system directory (requires sudo)."
    echo ""
    echo "Example: ./$SCRIPT_NAME --modules nvim kitty --include-root scripts --sddm"
    exit 0
}

# If no arguments are passed, show help
if [ $# -eq 0 ]; then
    show_help
fi

# Ensure ~/.config exists
mkdir -p "$TARGET_DIR"

for param in "$@"; do
    # 1. Mode Switcher
    case "$param" in
        --sddm)
            MODE="sddm"
            ;;
        --modules)
            MODE="modules"
            echo "󱂬  Mode Switch: Symlinking folders to $TARGET_DIR"
            continue
            ;;
        --include-root)
            MODE="root"
            echo "󱀵  Mode Switch: Inlining files directly to $TARGET_DIR"
            continue
            ;;
        -h|--help)
            show_help
            ;;
    esac

    # 2. Logic execution based on active MODE
    if [[ "$MODE" == "sddm" ]]; then
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
        # Reset mode to none after processing SDDM to avoid eating subsequent folders
        MODE="none"

    elif [[ "$MODE" == "modules" ]]; then
        # --- MODE: FOLDER PRESERVATION ---
        if [ ! -d "$CURRENT_DIR/$param" ]; then
            echo "  Skipping: '$param' folder not found."
            continue
        fi

        DEST_PATH="$TARGET_DIR/$param"
        if [ -d "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
            BACKUP_FULL_PATH="${DEST_PATH}.${CURRENT_DATE}.bak"
            echo "󰆓  Backing up: $DEST_PATH > $BACKUP_FULL_PATH"
            mv "$DEST_PATH" "$BACKUP_FULL_PATH"
        fi

        [ -L "$DEST_PATH" ] && rm "$DEST_PATH"
        ln -s "$CURRENT_DIR/$param" "$DEST_PATH"
        echo "  Folder Linked: $param > $DEST_PATH"

    elif [[ "$MODE" == "root" ]]; then
        # --- MODE: INLINE FILES ---
        if [ ! -d "$CURRENT_DIR/$param" ]; then
            echo "  Skipping: '$param' folder not found."
            continue
        fi

        echo "󱂬  Inlining files from '$param'..."
        find "$CURRENT_DIR/$param" -maxdepth 1 -not -path "$CURRENT_DIR/$param" | while read -r filepath; do
            filename=$(basename "$filepath")
            [[ "$filename" == "$SCRIPT_NAME" ]] && continue

            dest_file_path="$TARGET_DIR/$filename"
            if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                BACKUP_FILE_PATH="${dest_file_path}.${CURRENT_DATE}.bak"
                echo "󰆓  Backing up root item: $dest_file_path"
                mv "$dest_file_path" "$BACKUP_FILE_PATH"
            fi

            ln -sf "$filepath" "$dest_file_path"
            echo "   File Linked: $filename > $dest_file_path"
        done
    else
        echo "  Warning: No flag set for '$param'. Use --modules or --include-root."
    fi
done

echo "  Setup complete."