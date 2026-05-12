#!/bin/bash
input=$(cat)

# フォルダ名
cwd=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))")
dir=$(basename "$cwd")

# リポジトリ名・ブランチ名
repo=""
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# モデル名
model=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('model',{}).get('display_name','') or '')")

# コンテキスト使用率 (セッション初期は null のため 0 にフォールバック)
used=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); v=d.get('context_window',{}).get('used_percentage'); print(v if v is not None else 0)")

# --- 表示 ---

# フォルダ名（リポジトリ名と異なる場合のみ表示）
if [ "$dir" != "$repo" ]; then
  printf '\e[1;38;5;75m%s\e[0m' "$dir"
fi

# リポジトリ名 | ブランチ名
if [ -n "$repo" ] && [ -n "$branch" ]; then
  if [ "$dir" != "$repo" ]; then
    printf ' \e[38;5;244m|\e[0m'
  fi
  printf ' \e[38;5;215m%s\e[0m \e[38;5;244m|\e[0m \e[38;5;150m%s\e[0m' "$repo" "$branch"
fi

# モデル名
if [ -n "$model" ]; then
  printf ' \e[38;5;244m|\e[0m \e[38;5;183m%s\e[0m' "$model"
fi

# コンテキストプログレスバー (常に表示、null 時は 0%)
used_int=$(printf "%.0f" "$used")
filled=$(( used_int / 5 ))
empty=$(( 20 - filled ))
bar=""
for i in $(seq 1 $filled); do bar="${bar}█"; done
for i in $(seq 1 $empty); do bar="${bar}░"; done
# 色: 0〜60% 緑, 61〜85% 黄, 86〜100% 赤
if [ "$used_int" -le 60 ]; then
  color="\e[38;5;78m"
elif [ "$used_int" -le 85 ]; then
  color="\e[38;5;221m"
else
  color="\e[38;5;203m"
fi
printf ' \e[38;5;244m|\e[0m %b%s\e[0m \e[38;5;244m%d%%\e[0m' "$color" "$bar" "$used_int"
