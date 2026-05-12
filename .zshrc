export PATH="$HOME/.local/bin:$PATH"

# compinit: -u で broken symlink を無視（Docker Desktop 未起動時の警告抑制）
autoload -Uz compinit && compinit -u

eval "$(sheldon source)"

# zeno
eval "$(starship init zsh)"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
fi

# WezTerm: OSC 7 でカレントディレクトリを通知（ペイン分割時のCWD引き継ぎに必要）
autoload -Uz add-zsh-hook
function _wezterm_osc7() {
  printf "\033]7;file://%s%s\033\\" "$HOST" "$PWD"
}
add-zsh-hook precmd _wezterm_osc7

# マウストラッキングリセット
# TUI アプリ（nvim/fzf/claude など）が異常終了するとマウストラッキングが残存し、
# マウス移動が生テキスト(35;60;22M...)として流出する。手動修復用関数。
function fixterm() {
  printf '\e[?1000l'  # normal mouse tracking off
  printf '\e[?1002l'  # button event tracking off
  printf '\e[?1003l'  # all movement tracking off
  printf '\e[?1006l'  # SGR extended mode off
  printf '\e[?1015l'  # URXVT extended mode off
  tput sgr0           # テキスト属性リセット（色・太字など）
}

# precmd で自動リセット: 各コマンド実行後にマウストラッキングを無効化
# TUI アプリ終了後に次のプロンプトが出た瞬間に自動修復される
function _reset_mouse_tracking() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
}
add-zsh-hook precmd _reset_mouse_tracking

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export GROQ_API_KEY=""  # set in ~/.zshrc.local

export CLAUDE_CODE_NO_FLICKER=1

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
