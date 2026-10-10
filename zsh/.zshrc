### ---- Zinit bootstrap ----------------------------------------------------------
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Path Emacs
export PATH="$HOME/.config/emacs/bin:$PATH"


# ---- Plugins essenciais --------------------------------------------------------
# Syntax highlighting
zinit light zdharma-continuum/fast-syntax-highlighting

# Autosugestoes estilo fish
zinit light zsh-users/zsh-autosuggestions

# Completions extra
zinit light zsh-users/zsh-completions

# Historico melhorado com pesquisa
zinit light zsh-users/zsh-history-substring-search

# ---- Turbo mode ----------------------------------------------------------------
zinit wait lucid for \
      OMZL::git.zsh \
      OMZP::git \
      OMZP::command-not-found

# ---- Completions ---------------------------------------------------------------
autoload -Uz compinit && compinit
zinit cdreplay -q

# ---- Prompt: Starship ----------------------------------------------------------
eval "$(starship init zsh)"

# Direnv
eval "$(direnv hook zsh)"

# ---- Keybindings ---------------------------------------------------------------
bindkey -e 

bindkey "\e[3~" delete-char
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward
bindkey "^H" backward-kill-word
bindkey "^U" backward-kill-line
bindkey "^K" kill-line
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

# ---- Opcoes gerais -------------------------------------------------------------
setopt autocd
setopt correct
setopt hist_ignore_dups
setopt share_history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
export PATH="$HOME/.cargo/bin:$PATH"
export _JAVA_AWT_WM_NONREPARENTING=1
