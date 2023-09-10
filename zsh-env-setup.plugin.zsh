# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2022-2023 Wonwoo Choi

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0:#/*}:-$PWD/$0}

# Then ${0:h} to get plugin's directory

if [[ ${zsh_loaded_plugins[-1]} != */zsh-env-setup && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins[ZSH_ENV_SETUP_DIR]="${0:h}"

# Terminal title [[[1
function .tirr-precmd() {
  print -Pn "\e]0;[%n@%m %~]%#\a"
}

function .tirr-preexec() {
  print -Pn "\e]0;[%n@%m %~]%# "
  echo -n $2
  echo -ne "\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd .tirr-precmd
add-zsh-hook preexec .tirr-preexec

# zsh-sensible [[[1
alias mv='mv -i'
alias cp='cp -i'
alias less='less -SR'

setopt auto_cd hist_ignore_all_dups share_history
zstyle ':completion:*' menu select

# History [[[1
[[ -n "$HISTFILE" ]] || HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# zsh-substring-completion [[[1
setopt complete_in_word
setopt always_to_end
WORDCHARS=''
zmodload -i zsh/complist

zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Aliases [[[1
alias sl=ls
alias ㅣ=l
alias 니=ls
alias ㅣㄴ=ls
alias ㄴㅣ=ls

if (( ${+commands[eza]} )); then
    alias eza='eza --group-directories-first --color=always'
    alias exa='eza'
    alias ls='eza'
    alias l='eza -lgab --time-style iso'
elif (( ${+commands[exa]} )); then
    alias exa='exa --group-directories-first --color=always'
    alias eza='exa'
    alias ls='exa'
    alias l='exa -lgab --time-style iso'
else
    alias ls='ls --color=always'
    alias l='ls -lahk'
fi

if (( ${+commands[nvim]} )); then
    typeset -gx EDITOR=nvim
    alias vim='nvim'
    alias vi='nvim'
elif (( ${+commands[vim]} )); then
    typeset -gx EDITOR=vim
    alias vi='vim'
fi
# ]]]1

# fzf [[[1
if (( ${+commands[fzf]} )); then
    typeset -g FZF_COMPLETION_TRIGGER='\'

  # Use fd if available
  if (( ${+commands[fd]} )); then
      export FZF_DEFAULT_COMMAND='fd --color=always --type f --hidden --follow --exclude ".git"'
      export FZF_DEFAULT_OPTS='--ansi'

      function _fzf_compgen_path() {
          fd --color=always --hidden --follow \
              --exclude ".git" \
              . "$1"
      }

      function _fzf_compgen_dir() {
          fd --color=always --type d --hidden --follow \
              --exclude ".git" \
              . "$1"
      }
  fi
fi
# ]]]1

# Use alternate vim marks [[[ and ]]] as the original ones can
# confuse nested substitutions, e.g.: ${${${VAR}}}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmethod=marker:foldmarker=[[[,]]]
