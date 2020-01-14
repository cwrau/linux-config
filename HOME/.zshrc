# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}'

SAVEHIST=9223372036854775807
HISTSIZE=9223372036854775807

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source /usr/share/zsh/share/antigen.zsh
plugins=(git common-aliases docker-compose docker fancy-ctrl-z fd fzf gpg-agent helm httpie kubectl mvn gradle ripgrep sudo)

antigen use oh-my-zsh
for plugin in $plugins; do
  antigen bundle $plugin
done
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen theme romkatv/powerlevel10k
antigen apply

#for plugin in /usr/share/zsh/plugins/*/*.plugin.zsh; do
#  source "$plugin"
#done

autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.config/p10k.zsh ]] && source ~/.config/p10k.zsh

function command_not_found_handler() {
  echo "Command '$1' not found, but could be installed via the following packages:"
  /bin/yay -Fyq -- $1
}

function e.() {
  xdg-open . > /dev/null
}

function e() {
  xdg-open "$*" > /dev/null
}

function ssh() {
  if $(grep "$1" ~/.ssh/checked_hosts -q )
  then
    name="$1"
    shift
    scp -q ~/.bashrc ${name}:/tmp/cwr.bashrc > /dev/null

    if [[ "${#@}" > 0 ]]
    then
      /usr/bin/ssh -q $name "$@"
    else
      /usr/bin/ssh $name -t "sh -c 'if which bash &> /dev/null; then bash --rcfile /tmp/cwr.bashrc -i; else if which ash &> /dev/null; then ash; else sh; fi; fi'"
    fi
    return $?
  else
    ssh-copy-id $1
    ret=$?
    if [ $ret -eq 0 ]
    then
      echo "$1" >> ~/.ssh/checked_hosts
      ssh "$@"
      return $?
    fi
    return $ret
  fi
}

for intellijTool in /usr/local/bin/custom/custom/*; do
  local func=$(cat - <<EOF
  function $(basename $intellijTool)() {
    i3-msg "exec $intellijTool \$(realpath \${1:-.})"
  }
EOF
)
  eval "$func"
  unset func
done
unset intellijTool

function diff() {
  /bin/diff -u "${@}" | diff-so-fancy | /bin/less --tabs=1,5 -RF
}

function swap() {
  tmpfile=$(mktemp -u $(dirname "$1")/XXXXXX)
  mv "$1" "$tmpfile" -f && mv "$2" "$1" &&  mv "$tmpfile" "$2"
}

function bak() {
  cp -r "${1%/}" "${1%/}~"
}

function bsrv() {
    index="$1"
    shift
    ssh root@buildsrv${index}.4allportal.net $*
}

function 4ap() {
    name="$1"
    shift
    ssh root@${name}.4allportal.net $*
}

function appVs() {
  ssh root@repository.4allportal.net ls /services/repository/apps/$1 -v
}

function appV() {
  echo "$1:$(ssh root@repository.4allportal.net ls /services/repository/apps/$1 -v | tail -1)"
}

function getRepoVersion() {
    4ap repository find /services/repository/apps/4allportal-$1 -mindepth 1 -maxdepth 1 | sed -r 's#^.*/([^/]+)$#\1#g' | sort
}

function ss() {
  local result
  result="$(wiki-search "$@" | fzf | awk '{print $NF}')"
  if [ "$?" -eq "0" ]; then
    wiki-search $result
  fi
}

function google() {
  local IFS=+
  xdg-open "http://google.com/search?q=${*}"
}

#function release4App() {
#  local version="$1"
#  local newVersion="$2"
#
#  for package in package.json cmweb-*/package.json; do
#    cat $package | jq ".version = \"$version\"" | sponge $package
#  done
#
#  mvn versions:set -DgenerateBackupPoms=false -DnewVersion=$version
#
#  git commit . -m 'Version Bump'
#  git tag $version $(git rev-parse HEAD)
#
#  git reset --hard HEAD~1
#
#
#  for package in package.json cmweb-*/package.json; do
#    cat $package | jq ".version = \"$newVersion\"" | sponge $package
#  done
#
#}

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

function reAlias() {
  nAlias $1 $1 ${@:2}
}

function nAlias() {
  if command -v $2 &> /dev/null; then
    local param="${@:2}"
    alias "$1=${param}"
    #if [ -r /etc/bash_completion ] ||
    #   [ -r /etc/profile.d/bash_completion.sh ] ||
    #   [ -r /usr/share/bash-completion/bash_completion ]; then
    #  complete -F _complete_alias $1
    #fi
  fi
}

nAlias :q exit
nAlias :e nvim
reAlias env ' | sort'
reAlias rm -i
reAlias cp -i
reAlias mv -i
reAlias ls -phAvbl --color=always --time-style=long-iso
reAlias nvim -b
if [[ "$(id -u)" != 0 ]] && command -v sudo &> /dev/null; then
  for cmd in systemctl pacman; do
    nAlias $cmd sudo $cmd
  done
fi
nAlias top htop
nAlias vim nvim
nAlias vi vim
nAlias cat bat -p
nAlias less slit
nAlias ps procs
reAlias fzf --ansi
reAlias prettyping --nolegend
nAlias ping prettyping
nAlias du ncdu
nAlias man tldr
reAlias rg -S
reAlias jq -r
reAlias yq -r
nAlias k kubectl
command -v powerpill &> /dev/null && reAlias yay --pacman powerpill
nAlias docker-run docker run --rm -it
nAlias htop gotop
reAlias gotop -r 4
reAlias fd
nAlias gradle gradle-or-gradlew --no-daemon
reAlias feh --scale-down --auto-zoom

alias kubectl="PATH=\"$PATH:$HOME/.krew/bin\" kubectl"

nAlias krc kubectl config current-context
nAlias klc kubectl 'config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"'
nAlias kcc kubectl 'config use-context "$(klc | fzf -e | sed "s/^..//")"'
nAlias krn kubectl 'config get-contexts --no-headers "$(krc)" | awk "{print \$5}" | sed "s/^$/default/"'
nAlias kln kubectl 'get -o name ns | sed "s|^.*/|  |;\|$(krn)|s/ /*/"'
nAlias kcn kubectl 'config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'

export VISUAL=nvim
export EDITOR="$VISUAL"
[ -d /usr/local/bin/custom ] && PATH="$PATH:/usr/local/bin/custom"
[ -d /usr/local/bin/custom/custom ] && PATH="$PATH:/usr/local/bin/custom/custom"

unsetopt share_history
