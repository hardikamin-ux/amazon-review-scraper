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
echo "  [1/4] Checking Python 3..."

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
echo "  [2/4] Installing Python packages..."
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
echo "  [3/4] Installing Chrome automation browser..."
echo "        (one-time download, ~150 MB)"
echo ""

python3 -m playwright install chromium 2>&1 | sed 's/^/         /'

echo ""
echo "  ✅  Chrome installed"

# ── Step 4: Desktop shortcut ──────────────────────────────────────────────────
echo ""
echo "  [4/4] Creating Desktop shortcut..."

DESKTOP="$HOME/Desktop"
SHORTCUT="$DESKTOP/Amazon Scraper.command"

cat > "$SHORTCUT" << LAUNCHER
#!/bin/bash
# Amazon India Review Scraper — Launcher
cd "$DIR"

echo "Starting Amazon India Review Scraper..."
python3 -m streamlit run webapp.py \\
    --server.port 8501 \\
    --server.headless true &
STREAMLIT_PID=\$!

sleep 3
open "http://localhost:8501"

echo "App running at http://localhost:8501"
echo "Close this window to stop the scraper."
wait \$STREAMLIT_PID
LAUNCHER

chmod +x "$SHORTCUT"

echo ""
echo "  ✅  Desktop shortcut created"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Setup complete! 🎉                     ║"
echo "  ║                                          ║"
echo "  ║   Double-click 'Amazon Scraper' on       ║"
echo "  ║   your Desktop to launch the tool.       ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
read -p "  Press Enter to close this window..."
