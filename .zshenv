
# /etc/zsh/zshrc の compinit を無効化（~/.zshrc で compinit -u を呼ぶため）
skip_global_compinit=1

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
