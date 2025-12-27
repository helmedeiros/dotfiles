#!/bin/zsh
#
# KCC (Kindle Comic Converter) aliases and helper functions
#

# Quick manga conversion to EPUB for Kindle Colorsoft
alias kcc-manga='kcc-c2e --manga-style --forcecolor --profile KCS --format EPUB'

# Quick manga conversion to EPUB for Kindle Paperwhite
alias kcc-manga-pw='kcc-c2e --manga-style --forcecolor --profile KPW5 --format EPUB'

# Quick manga conversion to EPUB for Kindle Oasis
alias kcc-manga-oasis='kcc-c2e --manga-style --forcecolor --profile KO --format EPUB'

# Quick manga conversion to EPUB for Kindle Scribe
alias kcc-manga-scribe='kcc-c2e --manga-style --forcecolor --profile KS --format EPUB'

# Convert EPUB to AZW3 using Calibre
alias epub2azw3='/Applications/calibre.app/Contents/MacOS/ebook-convert'

# Batch convert all CBZ/CBR files in a directory to EPUB for Kindle Colorsoft
# Usage: kcc-batch-manga <input_dir> <output_dir>
kcc-batch-manga() {
    if [ $# -lt 2 ]; then
        echo "Usage: kcc-batch-manga <input_dir> <output_dir> [device_profile]"
        echo ""
        echo "Device profiles:"
        echo "  KCS  - Kindle Colorsoft (default)"
        echo "  KPW5 - Kindle Paperwhite 5th gen"
        echo "  KO   - Kindle Oasis"
        echo "  KS   - Kindle Scribe"
        return 1
    fi

    local input_dir="$1"
    local output_dir="$2"
    local profile="${3:-KCS}"

    mkdir -p "$output_dir"

    local count=0
    local total=$(find "$input_dir" -type f \( -name "*.cbz" -o -name "*.cbr" \) | wc -l | tr -d ' ')

    for file in "$input_dir"/*.{cbz,cbr}(N); do
        [ -f "$file" ] || continue
        count=$((count + 1))
        echo "[$count/$total] Converting: $(basename "$file")"
        ~/.local/bin/kcc-c2e --manga-style --forcecolor --profile "$profile" --format EPUB --output "$output_dir" "$file"
    done

    echo ""
    echo "✓ Converted $count files to $output_dir"
}

# Batch convert EPUB files to AZW3
# Usage: epub2azw3-batch <input_dir> <output_dir>
epub2azw3-batch() {
    if [ $# -lt 2 ]; then
        echo "Usage: epub2azw3-batch <input_dir> <output_dir>"
        return 1
    fi

    local input_dir="$1"
    local output_dir="$2"

    if [ ! -f "/Applications/calibre.app/Contents/MacOS/ebook-convert" ]; then
        echo "Error: Calibre not found. Install via: brew install --cask calibre"
        return 1
    fi

    mkdir -p "$output_dir"

    local count=0
    local total=$(find "$input_dir" -type f -name "*.epub" | wc -l | tr -d ' ')

    for epub in "$input_dir"/*.epub(N); do
        [ -f "$epub" ] || continue
        count=$((count + 1))
        local filename=$(basename "$epub" .epub)
        local output="$output_dir/${filename}.azw3"

        echo "[$count/$total] Converting: $filename"
        /Applications/calibre.app/Contents/MacOS/ebook-convert "$epub" "$output" --no-inline-toc > /dev/null 2>&1
    done

    echo ""
    echo "✓ Converted $count files to $output_dir"
}

# Combined: CBZ/CBR → EPUB → AZW3
# Usage: kcc-to-azw3 <input_dir> <output_dir> [device_profile]
kcc-to-azw3() {
    if [ $# -lt 2 ]; then
        echo "Usage: kcc-to-azw3 <input_dir> <output_dir> [device_profile]"
        echo ""
        echo "Converts CBZ/CBR → EPUB → AZW3 in one command"
        return 1
    fi

    local input_dir="$1"
    local output_dir="$2"
    local profile="${3:-KCS}"
    local temp_dir="${output_dir}_temp_epub"

    echo "Step 1/2: Converting to EPUB..."
    kcc-batch-manga "$input_dir" "$temp_dir" "$profile"

    echo ""
    echo "Step 2/2: Converting EPUB to AZW3..."
    epub2azw3-batch "$temp_dir" "$output_dir"

    echo ""
    echo "Cleaning up temporary files..."
    rm -rf "$temp_dir"

    echo ""
    echo "✓ All files converted to AZW3 in $output_dir"
}

# Complete workflow: CBZ/CBR → EPUB with ASIN → AZW3
# Usage: kcc-to-azw3-asin <input_dir> <epub_dir> <azw3_dir> <csv_file> [device_profile]
kcc-to-azw3-asin() {
    if [ $# -lt 4 ]; then
        echo "Usage: kcc-to-azw3-asin <input_dir> <epub_dir> <azw3_dir> <csv_file> [device_profile]"
        echo ""
        echo "Complete workflow: CBZ/CBR → EPUB (with ASIN metadata) → AZW3"
        echo ""
        echo "Arguments:"
        echo "  input_dir    - Directory containing CBZ/CBR files"
        echo "  epub_dir     - Directory for EPUB files (with metadata)"
        echo "  azw3_dir     - Directory for final AZW3 files"
        echo "  csv_file     - CSV file with ASIN metadata"
        echo "  device_profile - Kindle device profile (default: KCS)"
        echo ""
        echo "Example:"
        echo "  kcc-to-azw3-asin ~/Downloads/manga ~/Desktop/manga-epub \\"
        echo "                   ~/Desktop/manga-azw3 ~/.dotfiles/kcc/asins/series.csv KCS"
        return 1
    fi

    local input_dir="$1"
    local epub_dir="$2"
    local azw3_dir="$3"
    local csv_file="$4"
    local profile="${5:-KCS}"

    echo "==============================================="
    echo "Complete KCC + ASIN Workflow"
    echo "==============================================="
    echo ""

    echo "Step 1/3: Converting CBZ/CBR to EPUB..."
    kcc-batch-manga "$input_dir" "$epub_dir" "$profile"

    echo ""
    echo "Step 2/3: Setting ASIN metadata on EPUB files..."
    set-asin-batch "$epub_dir" "$csv_file"

    echo ""
    echo "Step 3/3: Converting EPUB to AZW3..."
    epub2azw3-batch "$epub_dir" "$azw3_dir"

    echo ""
    echo "==============================================="
    echo "✓ Complete! Files ready in: $azw3_dir"
    echo "==============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Transfer AZW3 files to your Kindle via USB or email"
    echo "  2. Books should open without 'Invalid ASIN' errors"
    echo "  3. Enjoy reading with proper metadata!"
}

# ==================== ASIN Metadata Functions ====================

# Set ASIN metadata on an ebook file
# Usage: set-asin <file> <asin>
set-asin() {
    if [ $# -lt 2 ]; then
        echo "Usage: set-asin <file> <asin>"
        echo ""
        echo "Sets Amazon ASIN metadata on an ebook file to fix 'Invalid ASIN' Kindle errors."
        echo ""
        echo "Example:"
        echo "  set-asin 'Vol. 01.epub' B00XXXXXXX"
        return 1
    fi

    local file="$1"
    local asin="$2"

    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi

    if [ ! -f "/Applications/calibre.app/Contents/MacOS/ebook-meta" ]; then
        echo "Error: Calibre not found. Install via: brew install --cask calibre"
        return 1
    fi

    echo "Setting ASIN $asin on $(basename "$file")..."
    /Applications/calibre.app/Contents/MacOS/ebook-meta "$file" --identifier amazon:"$asin"

    if [ $? -eq 0 ]; then
        echo "✓ ASIN set successfully"
    else
        echo "✗ Failed to set ASIN"
        return 1
    fi
}

# Batch set ASIN metadata from a CSV file
# Usage: set-asin-batch <directory> <csv_file>
# CSV format: filename,asin,title,author (without headers)
set-asin-batch() {
    if [ $# -lt 2 ]; then
        echo "Usage: set-asin-batch <directory> <csv_file>"
        echo ""
        echo "Batch sets ASIN, title, and author metadata from a CSV file."
        echo ""
        echo "CSV format (no headers):"
        echo "  Vol. 01.epub,B00XXXXXXX,My Series Vol. 1: First Chapter,Author Name"
        echo "  Vol. 02.epub,B00YYYYYYY,My Series Vol. 2: Second Chapter,Author Name"
        echo ""
        echo "Example:"
        echo "  set-asin-batch ~/Desktop/manga-epub ~/.dotfiles/kcc/asins/series.csv"
        return 1
    fi

    local dir="$1"
    local csv_file="$2"

    if [ ! -d "$dir" ]; then
        echo "Error: Directory not found: $dir"
        return 1
    fi

    if [ ! -f "$csv_file" ]; then
        echo "Error: CSV file not found: $csv_file"
        return 1
    fi

    if [ ! -f "/Applications/calibre.app/Contents/MacOS/ebook-meta" ]; then
        echo "Error: Calibre not found. Install via: brew install --cask calibre"
        return 1
    fi

    local count=0
    local success=0

    while IFS=',' read -r filename asin title author; do
        # Skip empty lines
        [ -z "$filename" ] && continue

        local filepath="$dir/$filename"
        count=$((count + 1))

        if [ -f "$filepath" ]; then
            echo "[$count] Setting metadata for: $filename"
            /Applications/calibre.app/Contents/MacOS/ebook-meta "$filepath" \
                --identifier amazon:"$asin" \
                --title "$title" \
                --authors "$author" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                success=$((success + 1))
            fi
        else
            echo "[$count] File not found: $filename (skipping)"
        fi
    done < "$csv_file"

    echo ""
    echo "✓ Set metadata on $success/$count files"
}

# Get ASIN from an ebook file
# Usage: get-asin <file>
get-asin() {
    if [ $# -lt 1 ]; then
        echo "Usage: get-asin <file>"
        echo ""
        echo "Displays the ASIN metadata from an ebook file."
        return 1
    fi

    local file="$1"

    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi

    if [ ! -f "/Applications/calibre.app/Contents/MacOS/ebook-meta" ]; then
        echo "Error: Calibre not found. Install via: brew install --cask calibre"
        return 1
    fi

    /Applications/calibre.app/Contents/MacOS/ebook-meta "$file" | grep -i "amazon"
}
