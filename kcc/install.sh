#!/usr/bin/env bash
#
# Install KCC (Kindle Comic Converter) CLI tools
# This script sets up the KCC CLI in an isolated environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
KCC_INSTALL_DIR="$HOME/.local/share/kcc"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/ciromattia/kcc.git"

echo -e "${GREEN}Installing KCC (Kindle Comic Converter) CLI...${NC}"

# Check if required tools are available
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    exit 1
fi

# Check for optional dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
if ! command -v 7z &> /dev/null && ! command -v unar &> /dev/null; then
    echo -e "${YELLOW}Warning: Neither sevenzip nor unar found. Install via: brew install sevenzip unar${NC}"
fi

# Use pyenv Python 3.12 if available, fallback to system python3
PYTHON_CMD="python3"
if command -v pyenv &> /dev/null; then
    if pyenv versions --bare | grep -q "^3.12"; then
        PYTHON_CMD="$HOME/.pyenv/versions/3.12.8/bin/python3"
        echo -e "${GREEN}Using pyenv Python 3.12${NC}"
    fi
fi

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$KCC_INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Clone or update repository
if [ -d "$KCC_INSTALL_DIR/.git" ]; then
    echo -e "${YELLOW}Updating existing KCC repository...${NC}"
    cd "$KCC_INSTALL_DIR"
    git pull
else
    echo -e "${YELLOW}Cloning KCC repository...${NC}"
    git clone "$REPO_URL" "$KCC_INSTALL_DIR"
    cd "$KCC_INSTALL_DIR"
fi

# Create virtual environment
echo -e "${YELLOW}Creating Python virtual environment...${NC}"
if [ -d "$KCC_INSTALL_DIR/venv" ]; then
    echo "Virtual environment already exists, recreating..."
    rm -rf "$KCC_INSTALL_DIR/venv"
fi
$PYTHON_CMD -m venv "$KCC_INSTALL_DIR/venv"

# Activate virtual environment and install dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
source "$KCC_INSTALL_DIR/venv/bin/activate"
pip install --upgrade pip
pip install -r "$KCC_INSTALL_DIR/requirements.txt"
deactivate

# Create wrapper script for kcc-c2e
echo -e "${YELLOW}Creating wrapper scripts...${NC}"
cat > "$BIN_DIR/kcc-c2e" << 'EOF'
#!/usr/bin/env bash
# Wrapper script for kcc-c2e CLI tool

KCC_DIR="$HOME/.local/share/kcc"
source "$KCC_DIR/venv/bin/activate"
python "$KCC_DIR/kcc-c2e.py" "$@"
deactivate
EOF

# Create wrapper script for kcc-c2p
cat > "$BIN_DIR/kcc-c2p" << 'EOF'
#!/usr/bin/env bash
# Wrapper script for kcc-c2p CLI tool

KCC_DIR="$HOME/.local/share/kcc"
source "$KCC_DIR/venv/bin/activate"
python "$KCC_DIR/kcc-c2p.py" "$@"
deactivate
EOF

# Make wrapper scripts executable
chmod +x "$BIN_DIR/kcc-c2e"
chmod +x "$BIN_DIR/kcc-c2p"

echo -e "${GREEN}✓ KCC CLI installed successfully!${NC}"
echo ""
echo "The following commands are now available:"
echo "  - kcc-c2e: Convert comics/manga to e-book format"
echo "  - kcc-c2p: Create Panel View comics"
echo ""
echo "Installation location: $KCC_INSTALL_DIR"
echo "Wrapper scripts: $BIN_DIR"
echo ""
echo "Usage example:"
echo "  kcc-c2e --manga-style --profile KPW --output ~/output manga_folder/"
echo ""
echo "Make sure $BIN_DIR is in your PATH."
echo "Add this to your shell config if needed:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
