ASIN Reference Files
====================

This directory contains CSV files mapping manga volume filenames to their Amazon ASIN codes.

Format
------
filename,asin

Example:
Vol. 01.azw3,B00F3HG7ES
Vol. 02.azw3,B00F3HGBPW

How to Find ASINs
-----------------
1. Go to Amazon.com or your regional Amazon site
2. Search for the manga volume (e.g., "One Piece Vol. 1 Kindle")
3. Open the product page
4. Find the ASIN in the "Product details" section
5. Or look in the URL: /dp/B00F3HG7ES/

Example URL:
https://www.amazon.com/One-Piece-Vol-Romance-Graphic-ebook/dp/B00F3HG7ES/

The ASIN is the 10-character code after /dp/ (in this case: B00F3HG7ES)

Creating New Reference Files
-----------------------------
Create a new CSV file for each manga series:

onepiece.csv    - One Piece volumes
naruto.csv      - Naruto volumes
bleach.csv      - Bleach volumes
etc.

Usage
-----
set-asin-batch ~/Desktop/manga-azw3 ~/.dotfiles/kcc/asins/onepiece.csv

Note
----
Only the first 10 One Piece volumes are included as examples.
Add more volumes as needed by finding their ASINs on Amazon.
