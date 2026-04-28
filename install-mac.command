#!/bin/bash
# Amazon India Review Scraper — Mac Installer
# Run this once after extracting the zip file.
# Right-click → Open, then click "Open" on the security prompt.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

clear
echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Amazon India Review Scraper            ║"
echo "  ║   One-time Mac Installer · Growisto      ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Python 3 ─────────────────────────────────────────────────────────
echo "  [1/5] Checking Python 3..."

if ! command -v python3 &>/dev/null; then
    echo ""
    echo "  ❌  Python 3 was not found on this machine."
    echo ""
    echo "  Please install it from:"
    echo "     https://www.python.org/downloads/"
    echo ""
    echo "  After installing Python, run this installer again."
    echo ""
    read -p "  Press Enter to close..."
    exit 1
fi

PYVER=$(python3 --version 2>&1)
echo "  ✅  Found $PYVER"

# ── Step 2: pip packages ──────────────────────────────────────────────────────
echo ""
echo "  [2/5] Installing Python packages..."
echo "        (this may take 1–2 minutes)"
echo ""

python3 -m pip install --upgrade pip --quiet 2>&1 | grep -v "^$" | sed 's/^/         /'

python3 -m pip install \
    playwright \
    playwright-stealth \
    beautifulsoup4 \
    openpyxl \
    lxml \
    pandas \
    streamlit \
    --quiet 2>&1 | grep -v "^$" | sed 's/^/         /'

echo ""
echo "  ✅  Packages installed"

# ── Step 3: Playwright browser ───────────────────────────────────────────────
echo ""
echo "  [3/5] Installing Chrome automation browser..."
echo "        (one-time download, ~150 MB)"
echo ""

python3 -m playwright install chromium 2>&1 | sed 's/^/         /'

echo ""
echo "  ✅  Chrome installed"

# ── Step 4: Copy app to permanent home folder ─────────────────────────────────
echo ""
echo "  [4/5] Installing app to ~/AmazonScraper..."

APP_DIR="$HOME/AmazonScraper"
mkdir -p "$APP_DIR"

# Copy all app files (exclude hidden installer artifacts)
rsync -a --exclude='.git' --exclude='__pycache__' \
    --exclude='*.pyc' --exclude='.DS_Store' \
    "$DIR/" "$APP_DIR/" 2>/dev/null || \
cp -r "$DIR/." "$APP_DIR/"

echo "  ✅  App installed to ~/AmazonScraper"

# ── Step 5: Create .app on Desktop ────────────────────────────────────────────
echo ""
echo "  [5/5] Creating Amazon Scraper app on Desktop..."

# Handle iCloud Desktop (common on modern Macs)
if [ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop" ]; then
    DESKTOP="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop"
else
    DESKTOP="$HOME/Desktop"
fi

APP_BUNDLE="$DESKTOP/Amazon Scraper.app"

# Build a minimal .app bundle with AppleScript
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.growisto.amazonreviewer</string>
    <key>CFBundleName</key>
    <string>Amazon Scraper</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST

# Launcher script (the actual executable inside the .app)
cat > "$APP_BUNDLE/Contents/MacOS/launcher" << LAUNCHER
#!/bin/bash
APP_DIR="\$HOME/AmazonScraper"
LOG="\$APP_DIR/scraper.log"

# Kill any previous instance on port 8501
lsof -ti:8501 | xargs kill -9 2>/dev/null || true

# Start Streamlit
cd "\$APP_DIR"
python3 -m streamlit run webapp.py \\
    --server.port 8501 \\
    --server.headless true > "\$LOG" 2>&1 &

# Wait for server to be ready (up to 15s)
for i in \$(seq 1 15); do
    if curl -s http://localhost:8501 > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Open in browser
open "http://localhost:8501"
LAUNCHER

chmod +x "$APP_BUNDLE/Contents/MacOS/launcher"

echo "  ✅  Amazon Scraper.app created on Desktop"

# Reveal it in Finder so it's easy to find
open -R "$APP_BUNDLE" 2>/dev/null || true

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Setup complete! 🎉                     ║"
echo "  ║                                          ║"
echo "  ║   'Amazon Scraper' is now on your        ║"
echo "  ║   Desktop — double-click it to launch.   ║"
echo "  ║                                          ║"
echo "  ║   Finder has opened to show you where.  ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
read -p "  Press Enter to close this window..."
