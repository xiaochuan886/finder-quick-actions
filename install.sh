#!/bin/bash
# Finder Quick Actions installer — 「在终端中打开」/「拷贝路径」(Open in Terminal / Copy Path)
# Usage: ./install.sh [en|zh]   (default: en)
# Env overrides (mainly for testing):
#   DOWNLOAD_URL  tarball URL used when run standalone (curl | bash)
#   FQA_NO_RESTART=1  skip `pbs -flush` and Finder restart
set -euo pipefail

VARIANT="${1:-en}"
case "$VARIANT" in
  en|zh) ;;
  *) echo "用法 / Usage: ./install.sh [en|zh]"; exit 1 ;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
  echo "❌ 仅支持 macOS / macOS only"; exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Running standalone (e.g. curl | bash): fetch the repo tarball first.
if [ ! -d "$SCRIPT_DIR/workflows" ]; then
  DOWNLOAD_URL="${DOWNLOAD_URL:-https://github.com/xiaochuan886/finder-quick-actions/archive/refs/heads/main.tar.gz}"
  echo "↓ 正在下载仓库 / Downloading repo..."
  TMP_DIR="$(mktemp -d)"
  curl -fsSL "$DOWNLOAD_URL" | tar xz -C "$TMP_DIR" --strip-components=1
  SCRIPT_DIR="$TMP_DIR"
fi

SERVICES_DIR="$HOME/Library/Services"
SRC_DIR="$SCRIPT_DIR/workflows/$VARIANT"

if [ ! -d "$SRC_DIR" ]; then
  echo "❌ 找不到 workflows/$VARIANT / missing workflows/$VARIANT"; exit 1
fi

mkdir -p "$SERVICES_DIR"
cp -R "$SRC_DIR/"*.workflow "$SERVICES_DIR/"
echo "✅ 已安装到 / Installed to: $SERVICES_DIR"

if [ "${FQA_NO_RESTART:-0}" != "1" ]; then
  /System/Library/CoreServices/pbs -flush >/dev/null 2>&1 || true
  killall Finder >/dev/null 2>&1 || true
  echo "🔄 已刷新服务缓存并重启 Finder / Services flushed, Finder restarted"
fi

cat <<'EOF'

🎉 完成！在 Finder 里右键任意文件/文件夹即可使用：
   Done! Right-click any file/folder in Finder:
   - 在终端中打开 / Open in Terminal
   - 拷贝路径 / Copy Path

菜单入口在右键菜单下半部分的「快速操作」或「服务」子菜单里。
Look in the "Quick Actions" section or the "Services" submenu.

如果没看到 / If missing:
   系统设置 → 隐私与安全性 → 扩展 → Finder，勾选对应项
   System Settings → Privacy & Security → Extensions → Finder

卸载 / Uninstall: ./uninstall.sh
EOF
