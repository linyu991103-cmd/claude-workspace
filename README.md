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
