# claude-workspace

Windows 和 Mac 共用的工作仓库，可在两台电脑上用 Claude Code（网页 / 桌面 App / CLI）打开同一个仓库继续工作。

## 使用方式

- **云端会话（claude.ai/code）**：新建会话时选择本仓库，两台电脑打开的都是同一份代码。
- **本地 CLI**：在两台电脑上分别 `git clone`，开始工作前 `git pull`，结束后 `git push`。

## 跨平台约定

- 换行符由 `.gitattributes` 统一为 LF（`.bat/.cmd/.ps1` 为 CRLF）。
- `.DS_Store`、`Thumbs.db` 等系统文件已在 `.gitignore` 中忽略。
- 文件名避免大小写仅不同的同名文件（Mac/Windows 默认不区分大小写）。
- 路径中尽量不用中文和空格，减少脚本兼容问题。

## 同步 Claude Code 本地数据（Mac → Windows）

> ⚠️ 仓库必须是 **Private**，否则聊天记录会公开。`sync-from-mac.sh` 检测到公开仓库会拒绝上传。

会同步：全局记忆 `CLAUDE.md`、`settings.json`、`commands/`、`skills/`、`agents/`、各项目的 `memory/` 和聊天记录 `*.jsonl`。
不会同步：登录凭证 `.credentials.json` 和其他缓存（Windows 上重新登录即可）。

**Mac：**
```bash
git clone https://github.com/linyu991103-cmd/claude-workspace ~/claude-workspace
~/claude-workspace/sync-from-mac.sh              # 加 --no-history 则不传聊天记录
```

**Windows（PowerShell）：**
```powershell
git clone https://github.com/linyu991103-cmd/claude-workspace $HOME\claude-workspace
powershell -ExecutionPolicy Bypass -File $HOME\claude-workspace\sync-to-win.ps1
```

说明：Claude Code 按项目绝对路径给记录分文件夹（如 `-Users-lin-myproj`），Windows 上同一项目的文件夹名不同（如 `C--Users-lin-myproj`）。
如果想让 Windows 上的某个项目用到 Mac 的项目记忆，把 `%USERPROFILE%\.claude\projects\<Mac 文件夹>\memory` 复制到对应的 Windows 项目文件夹即可。
