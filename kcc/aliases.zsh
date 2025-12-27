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
        kcc-c2e --manga-style --forcecolor --profile "$profile" --format EPUB --output "$output_dir" "$file"
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
