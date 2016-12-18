# set prompt format
export PS1="\W|"

# use vim as the system editor
export VISUAL=vim
export EDITOR="$VISUAL"

# use the current tty as the GPG UI
export GPG_TTY=`tty`

# history
HISTCONTROL=ignorespace:ignoredups
bind '"\e[A"':history-search-backward
bind '"\e[B"':history-search-forward

# aliases
alias dc="docker-compose"
alias dk='docker stop $(docker ps -a -q)'

# functions
docker-clean() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}')
}
gitb() {
  git branch | grep '^\*' | cut -d' ' -f2 | tr -d '\n'
}
gitpb() {
  gitb | pbcopy
}
gitpub() {
  git push origin $(gitb)
}

#fzf search
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# other settings
shopt -s histappend
shopt -s checkwinsize

# configure Ctrl-w behavior
stty werase undef
bind '\C-w:unix-filename-rubout'

source $HOME/.rvm/scripts/rvm
source $HOME/.cargo/env

# welcome commander
echo "hello."
