#!/usr/bin/env bash
# 在 Mac 上运行：把 ~/.claude 里的记忆、设置和聊天记录复制到本仓库的 claude-home/ 并推送。
# 用法：  ./sync-from-mac.sh            # 同步记忆 + 设置 + 聊天记录
#         ./sync-from-mac.sh --no-history  # 只同步记忆 + 设置
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$HOME/.claude"
DEST="$REPO_DIR/claude-home"
WITH_HISTORY=1
[[ "${1:-}" == "--no-history" ]] && WITH_HISTORY=0

# 安全检查：仓库是公开的就拒绝上传（公开仓库 API 返回 200，私有仓库返回 404）
REMOTE_URL="$(git -C "$REPO_DIR" remote get-url origin)"
SLUG="$(echo "$REMOTE_URL" | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
CODE="$(curl -s -o /dev/null -w '%{http_code}' "https://api.github.com/repos/$SLUG" || true)"
if [[ "$CODE" == "200" ]]; then
  echo "✗ 仓库 $SLUG 是公开的，聊天记录会被所有人看到。请先在 GitHub 上改成 Private 再运行。"
  exit 1
fi

[[ -d "$SRC" ]] || { echo "✗ 找不到 $SRC"; exit 1; }

git -C "$REPO_DIR" pull --ff-only

rm -rf "$DEST"
mkdir -p "$DEST/projects"

# 全局记忆与设置（不含 .credentials.json 等登录凭证）
for f in CLAUDE.md settings.json; do
  [[ -f "$SRC/$f" ]] && cp "$SRC/$f" "$DEST/"
done
for d in commands skills agents; do
  [[ -d "$SRC/$d" ]] && cp -R "$SRC/$d" "$DEST/"
done

# 各项目的记忆（memory/）和聊天记录（*.jsonl）
if [[ -d "$SRC/projects" ]]; then
  for p in "$SRC/projects"/*/; do
    name="$(basename "$p")"
    out="$DEST/projects/$name"
    if [[ -d "$p/memory" ]]; then
      mkdir -p "$out"; cp -R "$p/memory" "$out/"
    fi
    if [[ $WITH_HISTORY -eq 1 ]] && compgen -G "$p*.jsonl" > /dev/null; then
      mkdir -p "$out"; cp "$p"*.jsonl "$out/"
    fi
  done
fi

cd "$REPO_DIR"
git add claude-home
if git diff --cached --quiet; then
  echo "✓ 没有新的变化"
else
  git commit -m "Sync Claude data from Mac ($(date '+%Y-%m-%d %H:%M'))"
  git push
  echo "✓ 已同步并推送"
fi
