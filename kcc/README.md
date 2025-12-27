# KCC - Kindle Comic Converter

Convert manga and comics to Kindle-optimized formats with ease.

## What is KCC?

KCC (Kindle Comic Converter) is an open-source tool that optimizes comics and manga for E-ink readers like Kindle, Kobo, and reMarkable. It converts various formats to MOBI, EPUB, CBZ, or PDF with specific optimizations for e-readers.

## Quick Start

### 1. Install Dependencies

```bash
# Install Homebrew dependencies (in Brewfile)
brew bundle

# Or install manually
brew install sevenzip unar
brew install --cask calibre  # For AZW3 conversion
```

### 2. Run Installation

```bash
~/.dotfiles/kcc/install.sh
```

This will:
- Clone KCC repository to `~/.local/share/kcc`
- Create Python virtual environment (uses Python 3.12 if available via pyenv)
- Install all dependencies
- Create wrapper scripts in `~/.local/bin`

### 3. Reload Shell

```bash
exec zsh
```

## Available Commands

### Core CLI Tools

- **`kcc-c2e`** - Convert comics/manga to e-book format
- **`kcc-c2p`** - Create Panel View comics

### Quick Aliases

- **`kcc-manga`** - Convert to EPUB for Kindle Colorsoft (manga mode, color preserved)
- **`kcc-manga-pw`** - Convert for Kindle Paperwhite 5th gen
- **`kcc-manga-oasis`** - Convert for Kindle Oasis
- **`kcc-manga-scribe`** - Convert for Kindle Scribe
- **`epub2azw3`** - Convert EPUB to AZW3 using Calibre

### Batch Functions

#### `kcc-batch-manga <input_dir> <output_dir> [profile]`
Batch convert all CBZ/CBR files in a directory to EPUB.

```bash
# Convert all manga to EPUB for Kindle Colorsoft
kcc-batch-manga ~/Downloads/manga ~/Desktop/manga-kindle

# Convert for Kindle Paperwhite
kcc-batch-manga ~/Downloads/manga ~/Desktop/manga-kindle KPW5
```

**Device Profiles:**
- `KCS` - Kindle Colorsoft (default)
- `KPW5` - Kindle Paperwhite 5th gen
- `KO` - Kindle Oasis
- `KS` - Kindle Scribe
- See full list: `kcc-c2e --help`

#### `epub2azw3-batch <input_dir> <output_dir>`
Batch convert EPUB files to AZW3 format.

```bash
epub2azw3-batch ~/Desktop/manga-epub ~/Desktop/manga-azw3
```

#### `kcc-to-azw3 <input_dir> <output_dir> [profile]`
Complete conversion: CBZ/CBR → EPUB → AZW3 in one command.

```bash
# Convert all files directly to AZW3
kcc-to-azw3 ~/Downloads/onepiece ~/Desktop/onepiece-kindle KCS
```

#### `kcc-to-azw3-asin <input_dir> <epub_dir> <azw3_dir> <csv_file> [profile]`
Complete workflow with ASIN metadata: CBZ/CBR → EPUB (with ASIN) → AZW3.

```bash
# Convert with proper ASIN metadata in one command
kcc-to-azw3-asin ~/Downloads/manga ~/Desktop/manga-epub \
                 ~/Desktop/manga-azw3 ~/.dotfiles/kcc/asins/series.csv KCS
```

## Usage Examples

### Convert Single File

```bash
# Basic manga conversion to EPUB
kcc-c2e --manga-style --profile KPW5 --output ~/output manga.cbz

# With color preservation for Kindle Colorsoft
kcc-c2e --manga-style --forcecolor --profile KCS --format EPUB --output ~/output manga.cbz

# Convert to AZW3 (requires EPUB first, then convert)
kcc-c2e --manga-style --forcecolor --profile KCS --format EPUB --output ~/output manga.cbz
epub2azw3 ~/output/manga.epub ~/output/manga.azw3
```

### Convert Multiple Files

```bash
# Using batch function
kcc-batch-manga ~/Downloads/onepiece ~/Desktop/onepiece-kindle KCS

# Manual loop
for file in ~/Downloads/manga/*.cbz; do
    kcc-manga --output ~/Desktop/output "$file"
done
```

### Complete Workflow (CBZ → AZW3)

```bash
# Option 1: Use helper function
kcc-to-azw3 ~/Downloads/manga ~/Desktop/manga-azw3 KCS

# Option 2: Manual steps
kcc-batch-manga ~/Downloads/manga ~/Desktop/manga-epub KCS
epub2azw3-batch ~/Desktop/manga-epub ~/Desktop/manga-azw3
```

## Command-Line Options

### Main Options
- `-p PROFILE, --profile` - Device profile (KCS, KPW5, KO, KS, etc.)
- `-m, --manga-style` - Manga style (right-to-left reading)
- `-q, --hq` - High quality mode
- `-w, --webtoon` - Webtoon processing mode
- `--forcecolor` - Preserve colors (don't convert to grayscale)

### Output Settings
- `-o OUTPUT, --output` - Output directory or file
- `-t TITLE, --title` - Comic title
- `-f FORMAT, --format` - Output format (MOBI, EPUB, CBZ, KFX, PDF)

### Processing Options
- `-u, --upscale` - Resize images smaller than device resolution
- `-s, --stretch` - Stretch images to device resolution
- `-c CROPPING, --cropping` - Cropping mode (0: Disabled, 1: Margins, 2: Margins + page numbers)

See full options: `kcc-c2e --help`

## Supported Formats

### Input
- Image folders
- CBZ, ZIP
- CBR, RAR
- CB7, 7Z
- PDF

### Output
- EPUB (recommended for modern Kindles)
- AZW3 (Kindle Format 8 - requires conversion from EPUB)
- MOBI (requires KindleGen - legacy format)
- CBZ
- PDF

## Device Profiles

### Kindle Devices
- **KCS** - Kindle Colorsoft (7" color display)
- **KPW5** - Kindle Paperwhite 5th gen
- **KO** - Kindle Oasis
- **KS** - Kindle Scribe
- **K11** - Kindle 11th gen
- **K810** - Kindle 8/10
- See `kcc-c2e --help` for complete list

## File Locations

- **KCC Repository:** `~/.local/share/kcc`
- **CLI Tools:** `~/.local/bin/kcc-c2e`, `~/.local/bin/kcc-c2p`
- **Configuration:** `~/.dotfiles/kcc/`
- **Calibre (if installed):** `/Applications/calibre.app/`

## Updating KCC

```bash
# Re-run the install script to update
~/.dotfiles/kcc/install.sh
```

This will pull the latest changes from GitHub and reinstall dependencies.

## ASIN Metadata for Kindle

### What is ASIN?

ASIN (Amazon Standard Identification Number) is a unique identifier for products on Amazon. For sideloaded Kindle books, having the correct ASIN prevents "Invalid ASIN" errors and enables features like:
- Proper book opening (without workarounds)
- Cover art display
- Goodreads integration
- Reading progress sync

### Available Commands

#### `set-asin <file> <asin>`
Set ASIN metadata on a single ebook file.

```bash
set-asin ~/Desktop/manga-epub/"Vol. 01.epub" B00XXXXXXX
```

#### `get-asin <file>`
Display the current ASIN metadata from an ebook.

```bash
get-asin ~/Desktop/manga-epub/"Vol. 01.epub"
```

#### `set-asin-batch <directory> <csv_file>`
Batch set ASINs from a CSV file.

```bash
set-asin-batch ~/Desktop/manga-epub ~/.dotfiles/kcc/asins/series.csv
```

### Finding ASINs

1. Go to Amazon.com and search for your manga/book
2. Open the Kindle edition product page
3. Find the ASIN in "Product details" or in the URL

Example URL:
```
https://www.amazon.com/Series-Name-Vol-1-Subtitle-ebook/dp/B00XXXXXXX/
                                                            ^^^^^^^^^^
                                                            This is the ASIN
```

### Creating ASIN Reference Files

Create CSV files in `~/.dotfiles/kcc/asins/` for your manga series:

**Format:** `filename,asin,title,author` (no headers)

```csv
Vol. 01.epub,B00XXXXXXX,My Series Vol. 1: First Chapter,Author Name
Vol. 02.epub,B00YYYYYYY,My Series Vol. 2: Second Chapter,Author Name
Vol. 03.epub,B00ZZZZZZZ,My Series Vol. 3: Third Chapter,Author Name
```

**Important:** Use `.epub` extension in the CSV (not `.azw3`) because metadata must be set on EPUB files before converting to AZW3.

**Documentation:**
- `HOW_TO_FIND_ASINS.md` - Detailed guide for finding ASIN information

### Workflow with ASIN

**Recommended: All-in-one command**
```bash
# Complete workflow with ASIN metadata
kcc-to-azw3-asin ~/Downloads/manga ~/Desktop/manga-epub \
                 ~/Desktop/manga-azw3 ~/.dotfiles/kcc/asins/series.csv KCS
```

**Manual workflow (step-by-step)**
```bash
# 1. Convert manga to EPUB
kcc-batch-manga ~/Downloads/manga ~/Desktop/manga-epub KCS

# 2. Set ASIN metadata on EPUB files
set-asin-batch ~/Desktop/manga-epub ~/.dotfiles/kcc/asins/series.csv

# 3. Convert EPUB to AZW3 (metadata carries over)
epub2azw3-batch ~/Desktop/manga-epub ~/Desktop/manga-azw3

# 4. Transfer AZW3 files to Kindle via USB or email
```

### "Invalid ASIN" Error Workaround

If you see "Invalid ASIN" errors on Kindle:

**Temporary fix (firmware bug):**
1. Turn on Airplane mode
2. Tap the three dots next to the book (not the cover)
3. Select "Go To" to open the first chapter
4. Once opened, the book should work normally

**Permanent fix:**
Set the correct ASIN metadata using `set-asin` command before transferring to Kindle.

## Troubleshooting

### KindleGen Missing Error
KCC needs KindleGen for MOBI format. Solutions:
1. Use EPUB format instead (recommended): `--format EPUB`
2. Convert EPUB to AZW3 using Calibre (better than MOBI)
3. Install Kindle Previewer (includes KindleGen)

### "Failed to open source file/directory" Error
- Ensure the file path is correct
- Use absolute paths instead of relative paths
- Check that sevenzip or unar is installed for CBR/CBZ files

### Python Version Issues
The install script uses Python 3.12 from pyenv if available, otherwise falls back to system Python. If you encounter issues:

```bash
# Install Python 3.12 via pyenv
pyenv install 3.12.8
~/.dotfiles/kcc/install.sh
```

### Calibre Not Found
```bash
# Install Calibre for AZW3 conversion
brew install --cask calibre
```

## For LLM Agents

When helping users with KCC conversion tasks:

1. **Installation:** Run `~/.dotfiles/kcc/install.sh` if KCC is not set up
2. **Quick conversions:** Use aliases like `kcc-manga` or helper functions like `kcc-batch-manga`
3. **Batch operations:** Use `kcc-batch-manga` or `kcc-to-azw3` for multiple files
4. **Device profiles:** Ask which Kindle model the user has and use appropriate profile
5. **Format choice:**
   - EPUB for modern Kindles (can convert to AZW3 later)
   - AZW3 is the latest Kindle format (KF8)
   - Avoid MOBI (legacy format)
6. **Color preservation:** Use `--forcecolor` for Kindle Colorsoft
7. **ASIN metadata:**
   - If user reports "Invalid ASIN" errors, use `set-asin` or `set-asin-batch`
   - Create ASIN reference files in `~/.dotfiles/kcc/asins/` for batch operations
   - ASINs can be found in Amazon product URLs or product details
8. **Common errors:** Check for sevenzip/unar, use correct paths, verify Python version

## Resources

- **Official Repository:** https://github.com/ciromattia/kcc
- **Supported Devices:** See `kcc-c2e --help` for complete list
- **Issue Tracker:** https://github.com/ciromattia/kcc/issues

## License

KCC is open-source software released under the ISC License.

---

*Part of the [dotfiles](../) configuration*
