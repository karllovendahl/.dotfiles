# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Load Powerlevel10k from a user install first, then platform package paths.
for POWERLEVEL10K_PATH in \
    "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" \
    "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" \
    "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"; do
    if [[ -r "$POWERLEVEL10K_PATH" ]]; then
        source "$POWERLEVEL10K_PATH"
        break
    fi
done
unset POWERLEVEL10K_PATH

if [[ "$(uname)" == "Darwin" ]]; then
    export PATH="/Applications/Opera GX.app/Contents/MacOS:$PATH"
elif [[ "$(uname)" == "Linux" && -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Re-read the prompt colours when theme-set switches theme, so open shells
# follow along instead of keeping the previous theme's colours.
_theme_sync() {
  local name
  name=$(<"$HOME/.config/theme/current/name") 2>/dev/null || return
  if [[ -n ${_theme_name-} && $name != "$_theme_name" ]]; then
    source ~/.p10k.zsh && (( $+functions[p10k] )) && p10k reload
  fi
  _theme_name=$name
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _theme_sync

# tuicr picks its theme once at startup and cannot tell the mode inside tmux,
# so pass the current theme's mode; config.toml maps it to a theme.
tuicr() {
  local mode
  mode=$(sed -n 's/^THEME_MODE="\(.*\)"$/\1/p' "$HOME/.config/theme/current/colors.sh" 2>/dev/null)
  command tuicr ${mode:+--appearance=$mode} "$@"
}

################### EXPORTS ######################

export EDITOR="nvim"
export VISUAL="nvim"

export PATH="$HOME/.config/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# User-installed developer tools.
export PATH="$HOME/.cargo/bin:$HOME/.nix-profile/bin:$PATH"

if [[ "$(uname)" == "Darwin" && -d "/opt/homebrew/opt/postgresql@17/bin" ]]; then
    export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
fi

# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"
# Fix for dotnet tools in both WSL and macOS
if [[ "$(uname)" == "Linux" ]]; then
    # We're in Linux (WSL)
    if [[ -d "/usr/share/dotnet" ]]; then
        # Set .NET environment variables for WSL
        export DOTNET_ROOT=/usr/share/dotnet
        export PATH="$HOME/.dotnet/tools:$PATH"
    fi
elif [[ "$(uname)" == "Darwin" ]]; then
    # We're in macOS
    # macOS-specific dotnet config if needed
    # Nothing needed here as it works already
    true
fi

############### BINDS AND MODES ##################
bindkey -v

bindkey '^R' history-incremental-search-backward

############### AUTO COMPLETION ##################
# Add optional completion directories before initializing the completion system.
if [[ -n "${ASDF_DIR:-}" && -d "$ASDF_DIR/completions" ]]; then
    fpath=("$ASDF_DIR/completions" $fpath)
fi

if [[ "$(uname)" == "Darwin" && -d "/opt/homebrew/share/zsh-completions" ]]; then
    fpath=(/opt/homebrew/share/zsh-completions $fpath)
elif [[ "$(uname)" == "Linux" && -d "/usr/share/zsh/site-functions" ]]; then
    fpath=(/usr/share/zsh/site-functions $fpath)
fi

autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection for completions
zstyle ':completion:*' menu select

#################### ALIAS #######################

alias ls="eza --icons=always"
alias g="git"
alias python="python3"
alias gppr="git_pr.sh"
alias gpsu="git_push_upstream.sh"
alias ghome="git_home.sh"
alias gl="git log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gpf="git push --force-with-lease"
alias grbc="git rebase --continue"
alias grbm="git rebase origin/main"
alias gca="git commit --amend"
alias grep="rg"
alias gco="git checkout"
alias gs="git status"
alias gcob="git checkout -b"
alias gb="git rev-parse --abbrev-ref HEAD"
alias gaan="git add -AN"
alias gap="git add -p"
alias v="nvim"
alias eko='~/repos/eko/bin/eko --cwd "$PWD"'

#################### PLUGINS #######################
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi
