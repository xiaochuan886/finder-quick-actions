# Finder Quick Actions

> 在 Finder 右键菜单里「**在终端中打开**」和「**拷贝路径**」——纯原生实现，零依赖、零后台进程。
> Add **Open in Terminal** and **Copy Path** to the macOS Finder right-click menu — 100% native, zero dependencies, zero background processes.

[中文](#中文) · [English](#english)

---

## 中文

给 macOS Finder 右键菜单加两个原生的 Quick Action（Automator 服务）：

- **在终端中打开** — 右键文件夹，直接打开一个 `cd` 到该目录的 Terminal 新窗口；右键文件则打开它所在的目录
- **拷贝路径** — 把选中项目的绝对路径放进剪贴板，多选时按行分隔，完成后弹通知提示

### 特点

- 🍎 **纯原生**：就是两个 Automator 服务（`.workflow`），不需要安装任何 App
- 🪶 **极轻**：没有后台进程、没有开机自启、不占内存——只在点击菜单那一刻临时执行几行脚本
- 🔓 **无权限申请**：不需要辅助功能/屏幕录制等任何授权
- 🗑 **卸载干净**：删掉文件即消失，不留任何残留

### 安装

```bash
git clone https://github.com/xiaochuan886/finder-quick-actions.git
cd finder-quick-actions
./install.sh zh      # 中文菜单名（在终端中打开 / 拷贝路径）
./install.sh en      # 英文菜单名（Open in Terminal / Copy Path），默认
```

或者一键安装（自动下载仓库）：

```bash
curl -fsSL https://raw.githubusercontent.com/xiaochuan886/finder-quick-actions/main/install.sh | bash -s zh
```

安装脚本会把 `.workflow` 复制到 `~/Library/Services/`，刷新服务缓存并重启 Finder。

### 使用

在 Finder 里**右键任意文件/文件夹**，菜单下半部分的「快速操作」区块或「服务」子菜单里即可找到。

- 菜单里没看到？去 **系统设置 → 隐私与安全性 → 扩展 → Finder** 勾选对应项
- 想加快捷键？去 **系统设置 → 键盘 → 键盘快捷键 → 服务 → 文件和文件夹**，比如给「在终端中打开」绑 `⌘⌥T`

### 卸载

```bash
./uninstall.sh
```

### 自定义

- **换终端**：编辑对应 `.workflow/Contents/document.wflow`，把脚本里的 `open -a Terminal` 改成 `open -a iTerm`（或 Alacritty、Warp 等），再重新运行 `install.sh`
- **改菜单名**：重命名 `.workflow` 文件夹，并同步修改 `Info.plist` 里的 `CFBundleName` 和 `NSMenuItem → default`

### 工作原理

每个功能就是一个标准 macOS 服务 bundle：`Info.plist` 声明服务（限定 Finder、接收任意文件/文件夹 `public.item`），`document.wflow` 是一个 Run Shell Script 动作。核心逻辑总共不到 10 行：

```zsh
# 在终端中打开
for item in "$@"; do
  [ -d "$item" ] && open -a Terminal "$item" || open -a Terminal "$(dirname "$item")"
done

# 拷贝路径
printf '%s\n' "$@" | perl -pe 'chomp if eof' | pbcopy
```

系统服务注册由 `pbs`（Services daemon）管理，所以安装后需要 `pbs -flush` + 重启 Finder 让菜单生效。

### 兼容性

- macOS 13+（在 macOS 26 Tahoe / Apple Silicon 上实测通过）
- 仅支持 Mac 自带 Terminal；其他终端见「自定义」

### 和其他方案对比

| 方案 | 需要装 App | 需要授权 | 备注 |
|---|---|---|---|
| **本仓库** | ❌ | ❌ | 纯原生服务，删文件即卸载 |
| 系统自带 ⌥+右键「拷贝为路径名称」 | ❌ | ❌ | 要按住 Option，藏得深 |
| 系统自带「新建位于文件夹位置的终端窗口」 | ❌ | ❌ | 在「服务」二级菜单里，同样藏得深 |
| [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal) | ✅ | ✅ Finder 扩展授权 | 功能最全（支持 iTerm2/VSCode 等） |
| iTerm2 自带 Finder 扩展 | ✅ | ✅ | 仅 iTerm2 用户 |

### License

[MIT](LICENSE)

---

## English

Two native Quick Actions (Automator services) for the macOS Finder context menu:

- **Open in Terminal** — right-click a folder to open a new Terminal window already `cd`'d into it; right-click a file to open its parent folder
- **Copy Path** — put the absolute path of the selection on the clipboard (newline-separated for multiple items), with a notification when done

### Why

- 🍎 100% native — just two `.workflow` service bundles, no app to install
- 🪶 Featherweight — no background process, no login item, runs only for the split second you click the menu
- 🔓 No permissions needed (no Accessibility / Screen Recording grants)
- 🗑 Clean uninstall — delete the files and they're gone

### Install

```bash
git clone https://github.com/xiaochuan886/finder-quick-actions.git
cd finder-quick-actions
./install.sh en      # English menu names (default); use "zh" for Chinese
```

Or the one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/xiaochuan886/finder-quick-actions/main/install.sh | bash -s en
```

### Usage

Right-click any file/folder in Finder and look in the **Quick Actions** section or the **Services** submenu.

- Not showing up? Enable them in **System Settings → Privacy & Security → Extensions → Finder**
- Want a keyboard shortcut? Assign one in **System Settings → Keyboard → Keyboard Shortcuts → Services**

### Uninstall

```bash
./uninstall.sh
```

### Compatibility

macOS 13+. Tested on macOS 26 (Tahoe), Apple Silicon. For terminals other than Apple Terminal (iTerm2, Alacritty, …), edit `open -a Terminal` in the `document.wflow` script — see the Chinese section above for details.

### License

[MIT](LICENSE)
