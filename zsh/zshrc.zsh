HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

# History sharing across terminal instances
setopt inc_append_history
setopt share_history

# Ignore duplicate commands in history
setopt histignorealldups

# Fix what zsh defines as a word
# Prevents deleting whole line when only a word/segment should be deleted
autoload -Uz select-word-style
select-word-style bash

# Auto-completion system
autoload -Uz compinit
compinit

# Allow auto-completion system
autoload -Uz bashcompinit
bashcompinit

# Tab completion and highlighted colors
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# Where to find command bins
# Prevents command not found when a program is installed
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/cuda/bin
# export PATH=$PATH:/usr/local/cuda/bin:/opt/cuda/bin
# export PATH=$PATH:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin

# Auto-suggest if command requires a package when not found
command_not_found_handler () {
    if [ -x /usr/lib/command-not-found ]
    then
        /usr/lib/command-not-found -- "$1"
        return $?
    else
        if [ -x /usr/share/command-not-found/command-not-found ]
        then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf "%s: command not found\n" "$1" >&2
            return 127
        fi
    fi
}

# Keybindings
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[3~" delete-char

# Auto-load aliases
for aliases_file in $(\ls -a $HOME | \grep -E "\.aliases.*\.zsh"); do
    source $HOME/$aliases_file
done

# Set terminal editor
export EDITOR="/usr/bin/nano"

# Inline auto-suggestion
source $HOME/.config/zsh/auto-suggestion.zsh

# Starship
eval "$(starship init zsh)"
