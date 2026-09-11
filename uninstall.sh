#!/bin/bash
# Finder Quick Actions uninstaller — removes both en and zh variants
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "❌ 仅支持 macOS / macOS only"; exit 1
fi

SERVICES_DIR="$HOME/Library/Services"
NAMES=(
  "Open in Terminal.workflow"
  "Copy Path.workflow"
  "在终端中打开.workflow"
  "拷贝路径.workflow"
)

for name in "${NAMES[@]}"; do
  target="$SERVICES_DIR/$name"
  case "$target" in
    *.workflow)
      if [ -d "$target" ]; then
        rm -rf "$target"
        echo "🗑  已移除 / Removed: $target"
      fi
      ;;
  esac
done

/System/Library/CoreServices/pbs -flush >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true
echo "✅ 卸载完成，已重启 Finder / Done, Finder restarted"
