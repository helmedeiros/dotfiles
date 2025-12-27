# How to Find ASIN Information for Kindle Books

This guide explains how to find ASIN, title, and author information for manga and books to use with the KCC ASIN metadata workflow.

## What is ASIN?

ASIN (Amazon Standard Identification Number) is a unique 10-character identifier assigned by Amazon to products in their catalog. For Kindle books, having the correct ASIN in your sideloaded files:

- Prevents "Invalid ASIN" errors
- Enables proper book opening without workarounds
- Displays cover art correctly
- Enables Goodreads integration
- Syncs reading progress

## Quick Method: Finding ASIN from Amazon Product URL

### Step 1: Search Amazon for the Kindle Edition

1. Go to [Amazon.com](https://www.amazon.com)
2. Search for your book/manga: `"[Series Name] Vol. [Number] Kindle"`
   - Example: `"My Series Vol. 1 Kindle"`
3. Click on the **Kindle Edition** (not paperback or hardcover)

### Step 2: Extract ASIN from URL

The ASIN is in the product page URL after `/dp/`:

```
https://www.amazon.com/Series-Name-Vol-1-Subtitle-ebook/dp/B00XXXXXXX/
                                                            ^^^^^^^^^^
                                                            This is the ASIN
```

**ASIN format:** Always 10 characters, usually starts with `B0` for digital products

### Step 3: Get the Full Title and Author

On the Amazon product page:

1. **Title:** Copy the full title from the page heading
   - Example: "My Series, Vol. 1: The Beginning (Series Graphic Novel)"
   - Simplify to: "My Series Vol. 1: The Beginning"

2. **Author:** Listed under "by [Author Name]"
   - Example: "Author Name"

## Alternative Method: Using Amazon Product Details

If the URL method doesn't work:

1. Scroll down to **Product details** section
2. Look for "ASIN" in the details list
3. Copy the 10-character code

## Creating CSV Reference Files

### CSV Format

The CSV file should have 4 columns (no headers):

```csv
filename,asin,title,author
```

### Example CSV Entry

```csv
Vol. 01.epub,B00XXXXXXX,My Series Vol. 1: First Chapter,Author Name
Vol. 02.epub,B00YYYYYYY,My Series Vol. 2: Second Chapter,Author Name
```

### Filename Guidelines

- Use the EPUB filename (not AZW3) because metadata must be set on EPUB before converting to AZW3
- Use consistent naming: `Vol. XX.epub` with zero-padded numbers
- Match the exact filename of your converted EPUB files

## Web Search Method (for multiple volumes)

For finding ASINs for multiple volumes at once:

### Using Amazon Search

Search for: `"[Series Name] Kindle" site:amazon.com`

Example searches:
```
"My Series Vol" Kindle site:amazon.com
"Another Series Vol" Kindle edition site:amazon.com
```

### Pattern Recognition

For long-running series, ASINs often follow patterns:
- Some series: All start with similar prefixes like `B00F3H`
- The suffix varies for each volume

**Warning:** Never guess ASINs! Always verify each one from Amazon.

## Workflow for New Series

### Step-by-Step Process

1. **Create directory structure:**
   ```bash
   mkdir -p ~/.dotfiles/kcc/asins
   ```

2. **Create CSV file:**
   ```bash
   touch ~/.dotfiles/kcc/asins/[series-name].csv
   ```

3. **For each volume:**
   - Search Amazon for Kindle edition
   - Extract ASIN from URL
   - Copy full title (simplified)
   - Note author name
   - Add line to CSV file

4. **Example workflow for 10 volumes:**
   ```bash
   # Search for each volume 1-10
   # Open Amazon product pages in tabs
   # Copy ASIN, title, author for each
   # Create CSV entries
   ```

## Tips and Tricks

### Faster ASIN Collection

1. **Open multiple tabs:** Open Amazon product pages for all volumes
2. **Use URL bar:** Copy ASIN directly from URL instead of scrolling to details
3. **Spreadsheet software:** Use Excel/Google Sheets to organize, then export as CSV
4. **Browser extensions:** Some extensions can extract product data from Amazon

### Common Mistakes to Avoid

❌ **Wrong:** Using paperback/hardcover ASIN instead of Kindle edition
❌ **Wrong:** Copying ASIN from wrong region (use Amazon.com for US Kindle)
❌ **Wrong:** Using ISBN instead of ASIN (ISBN is 13 digits, ASIN is 10)
❌ **Wrong:** Setting metadata on AZW3 files (set on EPUB first!)

✅ **Correct:** Always use Kindle edition ASIN
✅ **Correct:** Verify each ASIN on Amazon
✅ **Correct:** Set metadata on EPUB before converting to AZW3

### Regional Considerations

Different Amazon regions may have different ASINs:
- **Amazon.com** (US): Use for US Kindle devices
- **Amazon.co.uk** (UK): Use for UK Kindle devices
- **Amazon.co.jp** (Japan): Use for Japanese Kindle devices

Use the Amazon store that matches your Kindle account region.

## Example: Complete CSV for a Series

```csv
Vol. 01.epub,B00AAAAAAA,My Series Vol. 1: Chapter One,Author Name
Vol. 02.epub,B00BBBBBBB,My Series Vol. 2: Chapter Two,Author Name
Vol. 03.epub,B00CCCCCCC,My Series Vol. 3: Chapter Three,Author Name
Vol. 04.epub,B00DDDDDDD,My Series Vol. 4: Chapter Four,Author Name
Vol. 05.epub,B00EEEEEEE,My Series Vol. 5: Chapter Five,Author Name
```

## Using the CSV with set-asin-batch

Once you have created your CSV file:

```bash
# 1. Set metadata on EPUB files
set-asin-batch ~/Desktop/manga-epub ~/.dotfiles/kcc/asins/series-name.csv

# 2. Convert EPUB to AZW3 (metadata will carry over)
epub2azw3-batch ~/Desktop/manga-epub ~/Desktop/manga-azw3

# 3. Transfer AZW3 files to Kindle
```

## Troubleshooting

### "Invalid ASIN" Error on Kindle

If you still see this error after setting metadata:
1. Verify ASIN is correct on Amazon
2. Check that you set metadata on EPUB before converting to AZW3
3. Verify ASIN appears in ebook-meta output:
   ```bash
   get-asin ~/path/to/file.epub
   ```

### Metadata Not Showing in AZW3

If ASIN doesn't appear in final AZW3 file:
1. Re-set metadata on EPUB file
2. Delete old AZW3 file
3. Re-convert EPUB to AZW3
4. Verify with: `/Applications/calibre.app/Contents/MacOS/ebook-meta file.azw3`

## Resources

- **Amazon Kindle Store:** https://www.amazon.com/Kindle-eBooks/
- **ASIN Lookup Tools:** Amazon product pages
- **Calibre ebook-meta docs:** https://manual.calibre-ebook.com/generated/en/ebook-meta.html

## Template CSV Files

Create your own CSV files in this directory following the format shown above.

---

**Remember:** Always verify ASINs are correct before batch processing!
