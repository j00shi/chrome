#!/usr/bin/env bash
#
# Compiles the SCSS in this directory to CSS and opens the Sidebery style editor.
#
# No prior installation needed: on first run this downloads a standalone Dart Sass
# binary (a single self-contained executable, no Node/Ruby/npm) into ./.sass/.
# Works on macOS and Linux. Windows users: run compile.ps1 instead.
#
# Usage:  ./compile.sh       (you may need: chmod +x compile.sh)

set -euo pipefail

SASS_VERSION="1.105.2"
EXT_URL="moz-extension://f9a9eaf3-d5c8-4e78-a9bc-8a2bb55cd97f/page.setup/setup.html#styles_editor"

# Run from the directory this script lives in, so paths are stable.
cd "$(dirname "$0")"

TOOLS_DIR=".sass"
SASS_BIN="$TOOLS_DIR/dart-sass/sass"

# --- Detect platform -------------------------------------------------------
case "$(uname -s)" in
	Darwin) plat="macos" ;;
	Linux)  plat="linux" ;;
	*) echo "Unsupported OS: $(uname -s). On Windows, run compile.ps1 instead." >&2; exit 1 ;;
esac
case "$(uname -m)" in
	x86_64|amd64)  arch="x64" ;;
	arm64|aarch64) arch="arm64" ;;
	*) echo "Unsupported CPU: $(uname -m)" >&2; exit 1 ;;
esac

# --- Download Dart Sass once -----------------------------------------------
if [ ! -x "$SASS_BIN" ]; then
	echo "Downloading Dart Sass $SASS_VERSION ($plat-$arch)..."
	mkdir -p "$TOOLS_DIR"
	url="https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-${plat}-${arch}.tar.gz"
	curl -fsSL "$url" | tar -xz -C "$TOOLS_DIR"
fi

# --- Compile ---------------------------------------------------------------
echo "Compiling SCSS..."
"$SASS_BIN" --style=compressed \
	userChrome.scss:userChrome.css \
	userContent.scss:userContent.css \
	styleEditor.scss:styleEditor.css
echo "Done."

# --- Open the Sidebery style editor in Firefox -----------------------------
if command -v open >/dev/null 2>&1; then          # macOS
	open -a Firefox "$EXT_URL" 2>/dev/null || {
		echo "Couldn't launch Firefox. Open this URL manually:"
		echo "  $EXT_URL"
	}
elif command -v firefox >/dev/null 2>&1; then      # Linux
	firefox "$EXT_URL" >/dev/null 2>&1 &
else
	echo "Couldn't find Firefox automatically. Open this URL manually:"
	echo "  $EXT_URL"
fi
