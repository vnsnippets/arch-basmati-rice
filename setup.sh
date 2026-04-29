#!/bin/bash

TARGET_DIR="$HOME/.config"
CURRENT_DATE=$(date +"%Y%m%d%H%M")
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

# SDDM specific variables
SDDM_SOURCE="$CURRENT_DIR/sddm"
SDDM_TARGET="/usr/share/sddm/themes/basmati-rice"

PROCESSING_ROOT=false

# Ensure ~/.config exists
mkdir -p "$TARGET_DIR"

for param in "$@"; do
    # --- NEW: SDDM THEME HANDLER ---
    if [[ "$param" == "--sddm" ]]; then
        if [ ! -d "$SDDM_SOURCE" ]; then
            echo "  Error: SDDM source folder '$SDDM_SOURCE' not found."
            continue
        fi

        echo "󰑨  Processing SDDM Theme (System access required)..."
        
        # Prompt for sudo early and keep it alive for the duration of this block
        sudo -v

        # Check if target exists and is not a symlink, then rename/backup
        if [ -d "$SDDM_TARGET" ]; then
            BACKUP_SDDM="${SDDM_TARGET}.${CURRENT_DATE}"
            echo "󰆓  Backing up existing SDDM theme: $SDDM_TARGET > $BACKUP_SDDM"
            sudo mv "$SDDM_TARGET" "$BACKUP_SDDM"
        fi

        # Create new directory and copy content
        sudo mkdir -p "$SDDM_TARGET"
        sudo cp -r "$SDDM_SOURCE/." "$SDDM_TARGET/"
        
        # Discard sudo credentials immediately after the system task is done
        sudo -k
        
        echo "  SDDM Theme installed to: $SDDM_TARGET"
        continue
    fi

    # 1. Flag Check[cite: 1]
    if [[ "$param" == "--include-root" ]]; then
        PROCESSING_ROOT=true
        echo "󱀵  Mode Switch: Inlining files directly to $TARGET_DIR"
        continue
    fi

    # 2. Folder Existence Check[cite: 1]
    if [ ! -d "$CURRENT_DIR/$param" ]; then
        echo "  Skipping: '$param' folder not found in current directory."
        continue
    fi

    if [ "$PROCESSING_ROOT" = false ]; then
        # --- MODE A: FOLDER PRESERVATION ---[cite: 1]
        DEST_PATH="$TARGET_DIR/$param"

        if [ -d "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
            BACKUP_FULL_PATH="${DEST_PATH}.${CURRENT_DATE}.bak"
            echo "󰆓  Backing up: $DEST_PATH > $BACKUP_FULL_PATH"
            mv "$DEST_PATH" "$BACKUP_FULL_PATH"
        fi

        if [ -L "$DEST_PATH" ]; then
            rm "$DEST_PATH"
        fi

        ln -s "$CURRENT_DIR/$param" "$DEST_PATH"
        echo "  Folder Linked: $param > $DEST_PATH"

    else
        # --- MODE B: INLINE FILES ---[cite: 1]
        echo "󱂬  Inlining files from '$param'..."
        
        find "$CURRENT_DIR/$param" -maxdepth 1 -not -path "$CURRENT_DIR/$param" | while read -r filepath; do
            filename=$(basename "$filepath")
            if [[ "$filename" == "$SCRIPT_NAME" ]]; then continue; fi

            dest_file_path="$TARGET_DIR/$filename"

            if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                BACKUP_FILE_PATH="${dest_file_path}.${CURRENT_DATE}.bak"
                echo "󰆓  Backing up root item: $dest_file_path"
                mv "$dest_file_path" "$BACKUP_FILE_PATH"
            fi

            ln -sf "$filepath" "$dest_file_path"
            echo "   File Linked: $filename > $dest_file_path"
        done
    fi
done

echo "  Setup complete."