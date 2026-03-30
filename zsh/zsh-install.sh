#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════╗
# ║          Zsh Environment Setup & Fix Script          ║
# ║    Installs deps + patches ZSH_HIGHLIGHT_STYLES      ║
# ╚══════════════════════════════════════════════════════╝
set -euo pipefail

ZSHRC="$HOME/.zshrc"
BACKUP="$HOME/.zshrc.bak.$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[•]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*"; exit 1; }

# ── Detect package manager ────────────────────────────────
detect_pkg_manager() {
    if command -v pacman &>/dev/null;   then echo pacman
    elif command -v apt-get &>/dev/null; then echo apt
    elif command -v dnf &>/dev/null;    then echo dnf
    elif command -v pkg &>/dev/null;    then echo pkg        # Termux
    else die "No supported package manager found."
    fi
}

install_pkg() {
    local pkg="$1"
    case "$PKG_MGR" in
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        apt)    sudo apt-get install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pkg)    pkg install -y "$pkg" ;;
    esac
}

PKG_MGR=$(detect_pkg_manager)
info "Package manager: $PKG_MGR"

# ── 1. Install zsh-syntax-highlighting ───────────────────
info "Checking zsh-syntax-highlighting..."
SHL_PATHS=(
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    /data/data/com.termux/files/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
)
SHL_FOUND=false
for p in "${SHL_PATHS[@]}"; do [[ -f "$p" ]] && SHL_FOUND=true && break; done

if $SHL_FOUND; then
    success "zsh-syntax-highlighting already installed."
else
    warn "zsh-syntax-highlighting not found — installing..."
    case "$PKG_MGR" in
        pacman) install_pkg zsh-syntax-highlighting ;;
        apt)    install_pkg zsh-syntax-highlighting ;;
        dnf)    install_pkg zsh-syntax-highlighting ;;
        pkg)    install_pkg zsh-syntax-highlighting ;;
    esac
    success "zsh-syntax-highlighting installed."
fi

# ── 2. Install zsh-autosuggestions ───────────────────────
info "Checking zsh-autosuggestions..."
SUG_PATHS=(
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    /data/data/com.termux/files/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
)
SUG_FOUND=false
for p in "${SUG_PATHS[@]}"; do [[ -f "$p" ]] && SUG_FOUND=true && break; done

if $SUG_FOUND; then
    success "zsh-autosuggestions already installed."
else
    warn "zsh-autosuggestions not found — installing..."
    install_pkg zsh-autosuggestions
    success "zsh-autosuggestions installed."
fi

# ── 3. Install optional tools ─────────────────────────────
for tool in eza bat fzf starship btop; do
    if ! command -v "$tool" &>/dev/null; then
        warn "$tool not found — attempting install..."
        install_pkg "$tool" 2>/dev/null && success "$tool installed." \
            || warn "$tool install failed (non-fatal, aliases will fall back)."
    else
        success "$tool already present."
    fi
done

# ── 4. Patch .zshrc: guard ZSH_HIGHLIGHT_STYLES ──────────
info "Backing up $ZSHRC → $BACKUP"
cp "$ZSHRC" "$BACKUP"
success "Backup created."

info "Patching ZSH_HIGHLIGHT_STYLES block..."

# Use Python for reliable multi-line sed replacement (portable across distros)
python3 - <<'PYEOF'
import re, os, sys

zshrc = os.path.expanduser("~/.zshrc")
with open(zshrc) as f:
    content = f.read()

# The broken pattern: HIGHLIGHT_STYLES lines sit outside any if-block
broken_block = r"""ZSH_HIGHLIGHT_STYLES\[command\]='fg=#a6e3a1,bold'
ZSH_HIGHLIGHT_STYLES\[builtin\]='fg=#89b4fa,bold'
ZSH_HIGHLIGHT_STYLES\[alias\]='fg=#cba6f7,bold'
ZSH_HIGHLIGHT_STYLES\[function\]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES\[path\]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES\[unknown-token\]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES\[single-quoted-argument\]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES\[double-quoted-argument\]='fg=#f9e2af'"""

replacement = """# Highlight styles are set inside the sourcing block below (fixes subscript error)"""

# Build the fixed sourcing block to replace the existing one
old_source_block_pattern = (
    r"(# ── Syntax highlighting.*?\n)"
    r"(if \[.*?zsh-syntax-highlighting.*?fi)"
)

new_source_block = """\
# ── Syntax highlighting (sourced last) ────────────────────
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Guard: only set HIGHLIGHT_STYLES after plugin is loaded
if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
    ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#cba6f7,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#94e2d5'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
fi"""

# Step 1: Remove the stray HIGHLIGHT_STYLES lines (outside if-block)
stray = re.compile(
    r"^ZSH_HIGHLIGHT_STYLES\[(?:command|builtin|alias|function|path|unknown-token|single-quoted-argument|double-quoted-argument)\]=.*\n",
    re.MULTILINE
)
patched = stray.sub("", content)

# Step 2: Replace the sourcing if-block with guarded version
block_re = re.compile(
    r"# ── Syntax highlighting.*?\n"
    r"if \[\[.*?zsh-syntax-highlighting\.zsh.*?fi\n",
    re.DOTALL
)
if block_re.search(patched):
    patched = block_re.sub(new_source_block + "\n", patched, count=1)
    print("✓ Sourcing block replaced with guarded version.")
else:
    print("⚠ Could not locate sourcing block — appending guard at end.")
    patched += "\n" + new_source_block + "\n"

with open(zshrc, "w") as f:
    f.write(patched)

print("✓ .zshrc patched successfully.")
PYEOF

success ".zshrc patched."

# ── 5. Validate: no more bare HIGHLIGHT_STYLES lines ──────
if grep -n "^ZSH_HIGHLIGHT_STYLES\[" "$ZSHRC" &>/dev/null; then
    warn "Some bare ZSH_HIGHLIGHT_STYLES lines may still exist — check manually."
else
    success "No stray ZSH_HIGHLIGHT_STYLES assignments found outside guard."
fi

# ── 6. Re-source ──────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  All done! Run this to apply changes:    ${NC}"
echo -e "${CYAN}      source ~/.zshrc                      ${NC}"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""
echo -e "  Backup saved at: ${YELLOW}$BACKUP${NC}"
