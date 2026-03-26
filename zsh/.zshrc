# ╔══════════════════════════════════════════════════════╗
# ║                    ~/.zshrc                          ║
# ║         Oh My Zsh + Starship + Plugins               ║
# ╚══════════════════════════════════════════════════════╝

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
export MAIN=/storage/emulated/0/
# ── Oh My Zsh plugins ────────────────────────────────────
plugins=(git z extract copypath dirhistory)

# Skip global compinit — we do it ourselves below, faster
skip_global_compinit=1

source $ZSH/oh-my-zsh.sh

# ── Zsh options ──────────────────────────────────────────
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt GLOB_DOTS
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ── Completion (cached — only rebuilds once a day) ───────
autoload -Uz compinit
setopt EXTENDEDGLOB
zcompdump="$HOME/.cache/zsh/zcompdump"
mkdir -p "$HOME/.cache/zsh"
# Only regenerate if dump is older than 24h
if [[ -n $zcompdump(#qN.mh+24) ]]; then
    compinit -d "$zcompdump"
    touch "$zcompdump"
else
    compinit -C -d "$zcompdump"   # -C skips the security check = fast
fi
unset zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{mauve}── %d ──%f'

# ── Autosuggestions ──────────────────────────────────────
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70,italic"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
bindkey '^ ' autosuggest-accept
bindkey '^[f' forward-word

# ── Syntax highlighting (sourced last) ────────────────────
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#cba6f7,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'

# ── Aliases ──────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --git --group-directories-first'
    alias lt='eza --tree --icons --level=2'
    alias la='eza -a --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -lahF --color=auto'
    alias la='ls -a --color=auto'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias bcat='bat'
fi

alias g='git'
alias gs='git status -s'
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'

alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias clean='sudo pacman -Sc'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias ps='ps aux'
alias top='btop 2>/dev/null || htop'

alias zshrc='${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc'
alias awmrc='${EDITOR:-nvim} ~/.config/awesome/rc.lua'
alias kittyrc='${EDITOR:-nvim} ~/.config/kitty/kitty.conf'
alias picomrc='${EDITOR:-nvim} ~/.config/picom/picom.conf'
alias rofirc='${EDITOR:-nvim} ~/.config/rofi/catppuccin.rasi'
alias reload='awesome-client "awesome.restart()"'

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# ── Environment ──────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R --mouse --wheel-lines=3'
export MANPAGER='sh -c "col -bx | bat -l man -p"'
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ── fzf ──────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
    source /usr/share/fzf/key-bindings.zsh  2>/dev/null || true
    source /usr/share/fzf/completion.zsh    2>/dev/null || true
    export FZF_DEFAULT_OPTS="
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
        --prompt='  ' --pointer='▶' --marker='✓'
        --border=rounded --height=50% --layout=reverse
    "
fi

# ── Starship prompt ──────────────────────────────────────
eval "$(starship init zsh)"
