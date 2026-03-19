# ── Home-Manager session variables ────────────────────────────────────────────
# On NixOS with home-manager, session vars (XDG_SESSION_TYPE, NIXOS_OZONE_WL,
# etc.) are written to this file.  Source it early so everything downstream sees
# them.  On non-NixOS systems the file simply won't exist — no-op.
# useUserPackages=true (home-manager NixOS module) puts vars here:
[[ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]] && \
  source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
# standalone home-manager puts vars here:
[[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]] && \
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# ── Oh-My-Zsh ────────────────────────────────────────────────────────────────
# Works on NixOS (ZSH set by home-manager) and any distro with oh-my-zsh
# installed at ~/.oh-my-zsh or via $ZSH environment variable.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

ZSH_THEME="robbyrussell"   # using custom prompt below — no oh-my-zsh theme needed

plugins=(git z sudo copypath dirhistory)

source "$ZSH/oh-my-zsh.sh"

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE="10000"
SAVEHIST="10000"
HISTORY_IGNORE='(rm *|pkill *|cp *)'
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
unsetopt APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS

# ── Terminal shell integrations ───────────────────────────────────────────────
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="no-rc"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

# ── Catppuccin Mocha — zsh-syntax-highlighting ───────────────────────────────
# On NixOS: nix places the theme at ~/.config/zsh/catppuccin-syntax.zsh
# On other distros: download it on first run into ~/.config/zsh/
_ctp_syntax="$HOME/.config/zsh/catppuccin-syntax.zsh"
if [[ ! -f "$_ctp_syntax" ]]; then
  mkdir -p "$HOME/.config/zsh"
  curl -fsSL -o "$_ctp_syntax" \
    "https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh" \
    2>/dev/null || true
fi
[[ -f "$_ctp_syntax" ]] && source "$_ctp_syntax"
unset _ctp_syntax

# ── Prompt ────────────────────────────────────────────────────────────────────
# Catppuccin Mocha colors:
#   sky=#89dceb  overlay0=#6c7086  green=#a6e3a1  red=#f38ba8  mauve=#cba6f7
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats " %F{#cba6f7} %b%f"
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

_prompt_cwd() {
  local p="${PWD/#$HOME/~}"
  echo "$p"
}

# PROMPT="%F{#89dceb}%n%f%F{#6c7086}@%f%F{#89dceb}%m%f %F{#6c7086}·%f %F{#a6e3a1}\$(_prompt_cwd)%f\${vcs_info_msg_0_} %F{#f38ba8}❯%f "
# RPROMPT=""

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ls="ls --color=auto"
alias ll="ls -lah --color=auto"
alias grep="grep --color=auto"

# NixOS-specific (safe to keep on other distros — commands just won't exist)
alias ns="sudo nixos-rebuild switch --flake ~/dotfiles#nixos --impure"
