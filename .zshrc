export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DESKTOP_DIR="$XDG_DATA_HOME/applications"
export XDG_DOCUMENTS_DIR="$HOME/Downloads"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Downloads"
export XDG_PUBLICSHARE_DIR="$HOME/Downloads"
export XDG_RUNTIME_DIR="/run/user/${UID:-$(id -u)}"
export XDG_SCREENSHOT_DIR="$HOME/Screenshots"
export XDG_TEMPLATES_DIR="$HOME/Downloads"
export XDG_VIDEOS_DIR="$HOME/Downloads"

declare -x | grep -E '^XDG_.+_DIR=.+$' | sed -r 's#=#="#; s#$#"#' > $XDG_CONFIG_HOME/user-dirs.dirs

export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
export ANDROID_AVD_HOME="$XDG_DATA_HOME/android"
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AZURE_CONFIG_DIR="$XDG_DATA_HOME/azure"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CM_DIR="$XDG_CACHE_HOME/clipmenud"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export KONAN_DATA_DIR="$XDG_DATA_HOME/konan"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export MC_CONFIG_DIR="$XDG_CONFIG_HOME/mcli"
export MINIKUBE_HOME="$XDG_DATA_HOME/minikube"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_DATA_HOME/NuGet"
export PEX_ROOT="$XDG_CACHE_HOME/pex"
export PULSE_COOKIE="$XDG_RUNTIME_DIR/pulse/cookie"
export REGISTRY_AUTH_FILE="$XDG_CONFIG_HOME/containers/auth.json"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SECRETS_DIR="$(realpath --relative-base=$HOME $XDG_CONFIG_HOME/gitsecret)"
export SLIT_DIR="$XDG_DATA_HOME/slit"
export SONAR_USER_HOME="$XDG_DATA_HOME/sonarlint"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
export STACK_ROOT="$XDG_CONFIG_HOME/stack"
export TALOSCONFIG="$XDG_CONFIG_HOME/talos/config.yaml"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export XAUTHORITY="$XDG_CACHE_HOME/x11/authority"
export XINITRC="$XDG_CONFIG_HOME/xorg/initrc"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

export BROWSER=google-chrome-stable
export CLUSTERCTL_DISABLE_VERSIONCHECK="true"
export EDITOR=nvim
export FZF_ALT_C_COMMAND='fd -t d --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -20'"
export FZF_CTRL_T_COMMAND='fd -t f --hidden'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --pager=never -p {} | head -20'"
export GOFLAGS="-modcacherw"
export GRADLE_COMPLETION_UNQUALIFIED_TASKS="true"
export GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx1G
export HELM_DIFF_OUTPUT="dyff"
export HELM_PLUGINS="/usr/lib/helm/plugins"
export HISTSIZE=9223372036854775807
export HWATCH="--differences word"
export KUBECTL_NODE_SHELL_POD_CPU=0
export KUBECTL_NODE_SHELL_POD_MEMORY=0
export PAGER=less
export SAVEHIST=9223372036854775807
export SDL_AUDIODRIVER="pulse"
export SECRETS_EXTENSION=".gpg"
export SYSTEMD_PAGERSECURE=false
export VISUAL="$EDITOR"

if ( [[ ! -v XDG_SESSION_TYPE ]] || [[ "$XDG_SESSION_TYPE" == "tty" ]] ) && [[ -o interactive ]] && [[ "$XDG_VTNR" == 1 ]]; then
  if false; then
    export XDG_CURRENT_DESKTOP=sway
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export MOZ_ENABLE_WAYLAND=1
    export XDG_SESSION_TYPE=wayland
    export WLR_DRM_NO_MODIFIERS=1
    export WLR_DRM_DEVICES=/dev/dri/card0
    systemctl --user import-environment 2> /dev/null
    exec systemd-cat --stderr-priority=warning --identifier=wayland nice -n -19 sway --unsupported-gpu
  else
    export XDG_SESSION_TYPE=x11
    systemctl --user import-environment 2> /dev/null
    xorgConfig=""
    if lsmod | grep -q nvidia; then
      xorgConfig="-config nvidia.conf"
    fi
    exec systemd-cat --stderr-priority=warning --identifier=xorg nice -n -19 startx -- -keeptty $xorgConfig
  fi
fi

if ! [[ -v DISPLAY ]]; then
  export GPG_TTY="$(tty)"
fi

renice -n -10 -p $(pgrep -s $$) >/dev/null

#if ! cat /proc/self/cgroup | awk -F:: '{print $2}' | xargs -i cat /sys/fs/cgroup/{}/cgroup.controllers | grep -q cpu; then
#  exec systemd-run --user --slice-inherit --property=Delegate=yes --same-dir --scope -S
#fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

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
COMPLETION_WAITING_DOTS="true"

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
HIST_STAMPS="%Y-%m-%dT%H-%M-%S%z"
HISTTIMEFORMAT="%Y-%m-%dT%T"

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

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'
zstyle ':completion:*' use-ip false
# by specifying an empty hosts array we force zsh to load the hosts from the config file
zstyle ':completion:*:hosts' hosts

export ZSH_CACHE_DIR=${XDG_CACHE_HOME}/oh-my-zsh
[ -d $ZSH_CACHE_DIR ] || mkdir $ZSH_CACHE_DIR
ZSH_CUSTOM=/usr/share/zsh
ZSH_THEME="../../zsh-theme-powerlevel10k/powerlevel10k"

plugins=(
  direnv
  dirhistory
  fancy-ctrl-z
  fd
  fzf
  git
  git-auto-fetch
  gitfast
  gradle
  per-directory-history
  ripgrep
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-you-should-use
)

export HISTORY_BASE="$XDG_DATA_HOME/directory_history"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump-${ZSH_VERSION}"

source $ZSH/oh-my-zsh.sh

ZSH_HIGHLIGHT_STYLES[comment]=fg=#7a7a7a
autoload -Uz compinit && compinit -d "$ZSH_COMPDUMP"
autoload -U bashcompinit && bashcompinit -d "$ZSH_COMPDUMP"

zstyle ':fzf-tab:complete:*' fzf-bindings alt-space:toggle
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group 'left' 'right'
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*:*' fzf-flags -i
#zstyle ':completion:*' matcher-list 'b:=*'
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh #> /dev/null

compdef _gradle gradle-or-gradlew

[[ -f $XDG_CONFIG_HOME/p10k.zsh ]] && source $XDG_CONFIG_HOME/p10k.zsh
[[ -f /opt/azure-cli/az.completion ]] && source /opt/azure-cli/az.completion
[[ -f /usr/share/LS_COLORS/dircolors.sh ]] && source /usr/share/LS_COLORS/dircolors.sh

setopt KSH_GLOB
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
unsetopt HIST_IGNORE_DUPS
unsetopt SHARE_HISTORY

function fixHistory() {
  local currentPath="${PWD}"
  local currentHistory="${HISTORY_BASE}/${currentPath}/history"
  local longestHistory
  longestHistory="$(wc --total=never -l "${currentHistory}" "${HOME}/../.snapshots/"*"/snapshot/$(realpath --relative-to="$(dirname "$HOME")" "${HOME}")/$(realpath --relative-to="${HOME}" "${HISTORY_BASE}")/${currentPath}/history" | sort -h | tail -1 | awk '{print $2}')"
  if ! [[ "$longestHistory" -ef "$currentHistory" ]]; then
    cp "$longestHistory" "$currentHistory"
  fi
}

function normalize-command-line() {
  [[ -z "$BUFFER" ]] && return 0
  functions[__normalize_command_line_tmp]=$BUFFER
  echo -n ${${functions[__normalize_command_line_tmp]#$'\t'}//$'\n\t'/$'\n'} | clip
  unset 'functions[__normalize_command_line_tmp]'
}
zle -N normalize-command-line
bindkey "^Xn" normalize-command-line

function _check_command() {
  local package
  if [ $? -eq 0 ] && command -v $1 &> /dev/null; then
    package=$(rg --text installed /var/log/pacman.log | tail -1 | awk '{print $4}')
    $@
    local ret=$?
    paru -Rs "$package"
    return $ret
  fi
  return 137
}

function command_not_found_handler() {
  [[ "${1:0:1}" == : ]] && return 0
  [[ "$1" =~ ^cccccc ]] && return 0
  local packages
  echo "Packages containing '$1' in name"
  tmpPackage $1
  _check_command $@
}

function _nop() {}

function e() {
  i3-msg "exec xdg-open \"$*\""
}

#function ssh() {
#  if [[ "${#@}" > 1 ]] || [[ "${#@}" == 0 ]]; then
#    /usr/bin/ssh "$@"
#  elif [[ -f ~/.ssh/checked_hosts ]] && grep -q -- "$1" ~/.ssh/checked_hosts; then
#    name="$1"
#    shift
#    scp -q ~/.bashrc ${name}:/tmp/cwr.bashrc > /dev/null
#
#    /usr/bin/ssh $name -t "sh -c 'if which bash &> /dev/null; then bash --rcfile /tmp/cwr.bashrc -i; else if which ash &> /dev/null; then ash; else sh; fi; fi'"
#    return $?
#  else
#    ssh-copy-id $1
#    ret=$?
#    if [ $ret -eq 0 ]; then
#      echo "$1" >> ~/.ssh/checked_hosts
#      ssh "$@"
#      return $?
#    fi
#    return $ret
#  fi
#}

function idea() {
  if [[ ! -v 1 ]]; then
    open_project _
  else
    open_project "$(realpath "$1")"
  fi
}

function diff() {
  if [ -t 1 ]; then
    semantic-diff "$@"
    #command diff "${@}" --color=always -u | diff-so-fancy | command less --tabs=1,5 -RF
  else
    command diff -u "${@}"
  fi
}

function reload-tmpfiles() {
  command systemd-run --user --unit reload-tmpfiles $(command systemctl --user cat systemd-tmpfiles-setup.service | grep ^ExecStart | cut -d = -f 2)
}

function swap() {
  local tmp
  tmp=$(mktemp -u XXXXXX)
  mv "$1" "$tmp" && mv "$2" "$1" &&  mv "$tmp" "$2"
}

function bak() {
  cp -r "${1%/}" "${1%/}-$(date --iso-8601=seconds)"
}

function helmUpdates() {
  kubectl get helmreleases -A -o json | jq -r '.items[] | select(.spec.chart.version != null) | "\(.metadata.namespace) \(.metadata.name) \(.spec.chart.repository) \(.spec.chart.name) \(.spec.chart.version)"' | while read ns name repo chart version; do
    <<EOF > /tmp/repo.yaml
apiVersion: ""
generated: "0001-01-01T00:00:00Z"
repositories:
  - name: repo
    url: "$repo"
EOF

    helm --repository-config /tmp/repo.yaml repo update &> /dev/null
    latestVersion=$(helm --repository-config /tmp/repo.yaml --output json search repo $chart | jq -r ".[] | select(.name == \"repo/$chart\") | .version")
    if [ "$version" != "$latestVersion" ]; then
      echo update $ns/$name to version $latestVersion
    fi
  done
  rm -f /tmp/repo.yaml
}

function google() {
  local IFS=+
  xdg-open "http://google.com/search?q=${*}"
}

function knodes() {
  echo "+> ${@}" >&2
  for node in $(kubectl get nodes -o json | jq '.items[] | "\(.metadata.name):\(.status.addresses[] | select(.type == "InternalIP") | .address)"' | sort -V); do
    IFS=: read name ip <<< "$node"
    echo $name >&2
    ssh $ip $@
  done
}

function gop() {
  local pass
  local name="$1"
  if [[ -z "$name" ]] || ! [[ -f "$XDG_RUNTIME_DIR/gopass/$name" ]]; then
    pass="$(gopass ls --flat | grep -v 'kube.?config' | fzf --preview "cat $XDG_RUNTIME_DIR/gopass/{}" | xargs -r -i cat $XDG_RUNTIME_DIR/gopass/{})"
  else
    pass="$(cat "$XDG_RUNTIME_DIR/gopass/$name")"
  fi

  if ! [ -t 1 ]; then
    echo -n "$pass"
  else
    echo -n "$pass" | clip
  fi
}
compdef _nop gop

function kbuild() {
  kustomize build --enable-alpha-plugins "$@"
}
compdef _directories kbuild

function kdiff() {
  kbuild "$@" | kubectl diff -f -
}
compdef _directories kdiff

function kapply() {
  kbuild "$@" | kubectl apply -f - --server-side --force-conflicts
}
compdef _directories kapply

function cwatch() {
  local ns=$1
  local cluster=$2
  watch --color -n 1 clusterctl describe cluster --show-conditions all --echo -n $ns $cluster
}
function _cwatch() {
  _arguments "1: :($(kubectl get namespaces --no-headers -o custom-columns=:metadata.name))"
  _arguments "2: :->cluster"

  if [[ "$state" == "cluster" ]]; then
    compadd $(kubectl --namespace ${words[2]} get clusters --no-headers -o custom-columns=:metadata.name)
  fi
}
compdef _cwatch cwatch

function findCluster() {
  local cluster="$1"
  for mgmt_cluster in $(gopass list --flat | command grep -E 'kube-?config' | grep mgmt); do
    KUBECONFIG=$XDG_RUNTIME_DIR/gopass/$mgmt_cluster kubectl get cluster -A | grep -q sustago && echo $mgmt_cluster && break
  done
}

function krsdiff() {
  local namespace
  local firstRS
  local secondRS

  namespace="$(kubectl get namespaces -o custom-columns=:metadata.name | fzf -1)"
  firstRS="$(kubectl -n "$namespace" get replicasets -o custom-columns=:metadata.name | fzf -1 --preview "kubectl -n '$namespace' get replicaset {} -o custom-columns=:metadata.creationTimestamp")"
  secondRS="$(kubectl -n "$namespace" get replicasets -o custom-columns=:metadata.name | rg -v "^$firstRS\$" | fzf -1 --preview "kubectl -n '$namespace' get replicaset {} -o custom-columns=:metadata.creationTimestamp")"

  dyff between <(kubectl -n "$namespace" get rs "$firstRS" -o yaml | yq -y '.metadata.name="rs"') <(kubectl -n "$namespace" get rs "$secondRS" -o yaml | yq -y '.metadata.name="rs"')
}

function pkgSync() {
  local OLDPWD=$PWD
  cd $HOME
  git pull
  command systemctl --user daemon-reload

  local package
  local packages
  local depends
  eval $(sed -n '/#startPackages/,/#endPackages/p;/#endPackages/q' $HOME/config/PKGBUILD | rg -v '#')
  packages=$depends

  local targetPackages
  targetPackages=$(echo $packages | tr ' ' '\n')
  local originalPackages=$targetPackages

  local newPackages
  newPackages=$(paru -Qqe | rg -xv -e "$(echo $targetPackages | tr '\n' '|' | sed 's#|$##g')" -e linux-config)

  if [ ! -z $newPackages ] && [[ "$(echo $newPackages | wc -l)" -gt 0 ]]; then
    echo "$(<<<$newPackages | wc -l) new Packages"
    while read -r package; do
      if [[ "$package" == "linux-config" ]]; then
        continue
      fi
      paru -Qi $package
      read -k 1 "choice?[A]dd, [r]emove, [d]epends or [s]kip $package? "
      echo
      case $choice in;
        [Aa])
          targetPackages="$targetPackages\\n$package"
          paru -D --asdeps $package
          ;;
        [Rr])
          echo "=========="
          echo
          paru -R --noconfirm $package
          ;;
        [Dd])
          echo "=========="
          echo
          paru -D --asdeps $package
          ;;
        *)
          :
          ;;
      esac
      echo
      echo "=========="
      echo
    done <<<"$newPackages"
  else
    echo "No new Packages"
  fi

  local missingPackages
  missingPackages=$(echo $targetPackages | rg -xv $(paru -Qqd | tr '\n' '|' | sed 's#|$##g'))

  if [ ! -z $missingPackages ]; then
    echo "$(wc -l <<<$missingPackages) missing Packages"
    while read -r package; do
      if paru -Qi $package >/dev/null; then
        paru -D --asdeps $package
        continue
      fi
      paru -Si $package
      paru -Qi $package
      read -k 1 "choice?[I]install, [r]emove or [s]kip $package? "
      echo
      case $choice in;
        [Ii])
          echo "=========="
          echo
          paru -S --noconfirm $package
          ;;
        [Rr])
          targetPackages=$(echo $targetPackages | rg -xv "$package")
          ;;
        *)
          :
          ;;
      esac
      echo
      echo "=========="
      echo
    done <<<"$missingPackages"
  else
    echo "No missing Packages"
  fi

  local orphanedPackages
  orphanedPackages=$(paru -Qqtd)

  if [ ! -z $orphanedPackages ]; then
    echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
    if read -q "?Remove orphaned packages? "; then
      while [ ! -z $orphanedPackages ]; do
        echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
        paru -R --noconfirm $(tr '\n' ' ' <<<$orphanedPackages)
        echo
        orphanedPackages=$(paru -Qqtd)
      done
    fi
  else
    echo "No orphaned Packages"
  fi

  local unusedPackages
  unusedPackages=$(paru -Qi | awk '/^Name/{name=$3} /^Required By/{req=$4} /^Optional For/{opt=$0} /^Install Reason/{res=$4$5} /^$/{if (req == "None" && res != "Explicitlyinstalled"){print name}}' | rg -xv $(echo $targetPackages | tr '\n' '|' | sed 's#|$##g'))

  if [ ! -z $unusedPackages ]; then
    echo "$(wc -l <<<$unusedPackages) unused Packages"
    if read -q "?Remove unused packages? "; then
      while [ ! -z $unusedPackages ]; do
        echo "$(wc -l <<<$unusedPackages) unused Packages"
        paru -R --noconfirm $(tr '\n' ' ' <<<$unusedPackages)
        echo
        unusedPackages=$(paru -Qi | awk '/^Name/{name=$3} /^Required By/{req=$4} /^Optional For/{opt=$0} /^Install Reason/{res=$4$5} /^$/{if (req == "None" && res != "Explicitlyinstalled"){print name}}')
      done
    fi
  else
    echo "No unused Packages"
  fi

  newPackages=$( (
      echo '  #startPackages'
      echo 'depends=('
      echo $targetPackages | sort | uniq | sed 's#^#    #g'
      echo '  )'
      echo '  #endPackages'
  ) | sed -r 's#$#\\n#g' | tr -d '\n' | sed -r 's#\\n$##g')

  diff <(echo $originalPackages | sort) <(echo $targetPackages | sort)
  if ! command diff <(echo $originalPackages) <(echo $targetPackages) &> /dev/null; then
    if read -q "?Commit? "; then
      sed -i -e "/#endPackages/a \\${newPackages}" -e '/#startPackages/,/#endPackages/d' -e 's#NewPackages#Packages#g' $HOME/config/PKGBUILD
      local pkgrel
      eval "$(grep pkgrel $HOME/config/PKGBUILD)"
      sed -i -e "s#pkgrel=$pkgrel#pkgrel=$(( pkgrel + 1 ))#" $HOME/config/PKGBUILD
      git commit -m pkgSync $HOME/config/PKGBUILD
      git push
    fi
    (cd $HOME/config && makepkg -si)
  else
    echo "No changes to be made"
  fi
  cd $OLDPWD
}
compdef _nop pkgSync

declare -a tmpPackages
function tmpPackage() {
  local packages=()
  local package="${1?At least a single search term is required}"
  if [[ "${#@}" -eq 1 ]] && paru -Si "$1" >/dev/null; then
    paru -S "$1"
  else
    paru -- "${@}"
  fi
  packages=( $(grep installed /var/log/pacman.log | awk '{print $4}' | tail -5 | tac | awk '!x[$0]++') )
  if [[ "${packages[(Ie)${package}]}" -gt 0 ]] && read -q "?Auto-uninstall '$package'? "; then
    tmpPackages+=( "$package" )
  else
    tmpPackages+=( $( <<<"$packages" | tr ' ' $'\n' | fzf --prompt='Choose package to be uninstalled on exit' -m) )
  fi
}
compdef _paru tmpPackage

function _cleanTmpPackages() {
  if [[ "${#tmpPackages}" -gt 0 ]]; then
    paru -Rs --noconfirm "${tmpPackages[@]}"
  fi
}

function TRAPEXIT() {
  _cleanTmpPackages
}

function () :r(){
  _cleanTmpPackages
  exec zsh
}

function clip() {
  local xclipArgs=()
  if [[ -t 0 ]]; then
    xclipArgs+=( -o )
  fi
  xclip -selection clipboard "${xclipArgs[@]}"
}
compdef _nop clip

function column() {
  local col="${1:-1}"
  awk "{print \$$col}"
}

function releaseAur() {
  (
    set -e
    local choice
    git add PKGBUILD .SRCINFO
    git clean -xfd
    grep -q source= PKGBUILD && updpkgsums
    makepkg -df
    makepkg --printsrcinfo > .SRCINFO
    choice=$(gum choose "Version Bump" custom)
    case "$choice" in
      "Version Bump")
        git commit . -m "Version Bump"
        ;;
      custom)
        git commit -v .
        ;;
      *)
        echo abort > /dev/stderr
        return 1
        ;;
    esac
    git push
    git clean -xfd
  )
}

function kkkk() {
  local config
  local openRc
  local unitName
  local query
  local exitCode

  if ! command systemctl --user is-active -q gopass-fuse.service; then
    command systemctl --user start --no-block gopass-fuse
  fi

  if [[ ! -v 1 ]]; then
    query=""
  elif [[ -f "$XDG_RUNTIME_DIR/gopass/$1" ]]; then
    config="$1"
  else
    query="$1"
  fi
  if [[ -z "$config" ]]; then
    config="$(gopass ls -flat | grep --pcre2 -o '^.+(?=/kube-?config)' | fzf --query "$query" -1)"
    exitCode="$?"
    if [[ "$exitCode" != 0 ]]; then
      return "$exitCode"
    fi
  fi

  KUBECONFIG="$XDG_RUNTIME_DIR/gopass/$config/kube-config"
  if [[ ! -f "$KUBECONFIG" ]]; then
    KUBECONFIG="$XDG_RUNTIME_DIR/gopass/$config/kubeconfig"
  fi

  export KUBECONFIG
  openRc="$XDG_RUNTIME_DIR/gopass/$config/open-rc"
  if [[ -f "$openRc" ]]; then
    unitName="$(md5sum "$openRc" | awk NF=1)"
    if ! command systemctl --user is-active -q "$unitName"; then
      systemd-run --user --collect -q --slice sshuttle --unit="$unitName" -- bash -c "source '$openRc'"
    fi
  fi

  if [[ "$TEMPORARY" != true ]]; then
    mkdir -p "$XDG_RUNTIME_DIR/kconfig"
    echo "$config" > "$XDG_RUNTIME_DIR/kconfig/current_kubeconfig"
    ln -fs "$KUBECONFIG" "$XDG_CONFIG_HOME/kube/config"
  fi
}

function kkk() {
  kk bash -c 'ln -fs "$KUBECONFIG" "$XDG_CONFIG_HOME/kube/config" && exec zsh'
}

function getHelm() {
  local repo
  local chart
  local version
  local chartname
  case "${#@}" in
    1)
      chart="$1"
    ;;
    2)
      if [[ "$1" == "oci://"* ]]; then
        chart="$1"
        version="$2"
      else
        repo="$1"
        chart="$2"
      fi
    ;;
    3)
      repo="$1"
      chart="$2"
      version="$3"
    ;;
  esac
  chartname="${chart##*/}"

  helm pull --untar --untardir "${chartname}${version+-$version}" ${repo+--repo=$repo} "${chart}" ${version+--version=$version}
}

function kk() {
  for cluster in $(gopass list --flat G 'kube-?config' G mgmt); do
    KUBECONFIG=$XDG_RUNTIME_DIR/gopass/$cluster kubectl get cluster -A -o json | jq -r '.items[] | "'"$cluster"':\(.metadata.namespace):\(.metadata.name):\(.metadata.annotations["t8s.teuto.net/customer-name"] // "" | try @base64d // .metadata.labels["t8s.teuto.net/customer-id"]):\((.metadata.annotations["t8s.teuto.net/cluster"] // "" | try @base64d) as $name | if $name == "" then .metadata.name else $name end)"'
  done | fzf --track --preview="awk -v name={} 'BEGIN{split(name,splitted,\":\"); cols=split(splitted[1], splitted, \"/\"); print splitted[cols-1]}'" +s -d : --with-nth=4,5 | IFS=: read -r mgmt namespace name _
  [[ "$?" == 0 ]] || return "$?"
  KUBECONFIG="$XDG_RUNTIME_DIR/gopass/$mgmt" capo-shell "$namespace" "$name" "${@}"
}

function kk9s() {
  kk k9s "${@}"
}

if ! [[ -f "$KUBECONFIG" ]]; then
  unset KUBECONFIG
  if [[ -f "$XDG_RUNTIME_DIR/kconfig/current_kubeconfig" ]]; then
    export KUBECONFIG="$XDG_RUNTIME_DIR/gopass/$(gopass ls -flat | grep '^.+/kube-?config' | grep "^$(cat $XDG_RUNTIME_DIR/kconfig/current_kubeconfig)" | tail -1)"
  else
    rm -f "$XDG_RUNTIME_DIR/current_kubeconfig"
  fi
fi

function k9s() {
  if ! [[ -f "$KUBECONFIG" ]]; then
    kk k9s "${@}"
  else
    command k9s "${@}"
  fi
}
function _k9s() {
  if [[ -f $KUBECONFIG ]]; then
    _arguments "1:The name of the kubeconfig context to use:($(kubectl config get-contexts --no-headers -o name))"
  else
    _arguments "1:The path of the kubeconfig file to use:($(gopass ls -flat | /bin/grep -E 'kube.?config'))"
    _arguments "2:The name of the kubeconfig context to use:->context"
  fi

  if [[ "$state" == "context" ]]; then
    compadd $(kubectl --kubeconfig $XDG_RUNTIME_DIR/gopass/${words[2]} config get-contexts --no-headers -o name)
  fi
}
compdef _k9s k9s

function _lnav() {
  #_alternative 'local:local files:_files' \
    _arguments  '1:remote files:_remote_files -- ssh'
}
compdef _lnav lnav

function reAlias() {
  nAlias $1 $1 ${@:2}
}

function nAlias() {
  local param="${@:2}"
  alias "$1=${param}"
}

nAlias $ ''
nAlias :q exit
nAlias :e nvim
reAlias env "-0 | sort -z | tr '\0' '\n'"
reAlias rm -i
reAlias cp -i
reAlias mv -i
#reAlias ls --almost-all --indicator-style=slash --human-readable --sort=version --escape --format=long --color=always --time-style=long-iso
#nAlias ls exa --all --binary --group --classify --sort=filename --long --colour=always --time-style=long-iso --git
nAlias ls lsd --almost-all --git --color=always --long --date=+'%Y-%m-%dT%H:%M:%S' -I .git
if [[ "$(id -u)" != 0 ]] && (( ${+commands[sudo]} )); then
  for cmd in systemctl ip; do
    nAlias $cmd sudo $cmd
  done
fi
nAlias top htop
nAlias vim nvim
nAlias vi vim
nAlias cat "bat --pager 'less -RF' --nonprintable-notation unicode"
nAlias ps procs
reAlias fzf --ansi
reAlias prettyping --nolegend
nAlias ping prettyping
nAlias du gdu -x
reAlias rg -S --engine auto
reAlias jq -er
reAlias yq -er
nAlias k 'kubectl' # "--context=${KUBECTL_CONTEXT:-$(kubectl config current-context)}" ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'
nAlias podman-run podman run --rm -i -t
nAlias htop btop
reAlias feh --scale-down --auto-zoom --auto-rotate
nAlias grep rg
nAlias o xdg-open
nAlias dmakepkg podman-run --network host -v '$PWD:/pkg' 'whynothugo/makepkg' makepkg
nAlias scu command systemctl --user
nAlias sc systemctl
nAlias sru command systemd-run --user
nAlias sr systemd-run
nAlias urldecode 'sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"'
nAlias urlencode 'jq -s -R -r @uri'
nAlias base64 'base64 -w 0'
nAlias b base64
nAlias bd 'base64 -d'
nAlias tree ls --tree
reAlias mitmproxy "--set confdir=$XDG_CONFIG_HOME/mitmproxy"
reAlias mitmweb "--set confdir=$XDG_CONFIG_HOME/mitmproxy"
nAlias . ls
nAlias cp advcp -g
nAlias mv advmv -g
reAlias code '--user-data-dir $XDG_DATA_HOME/vscode --extensions-dir $XDG_DATA_HOME/vscode/extensions'
nAlias wd 'while :; do .; sleep 0.1; clear; done'
reAlias s3cmd '-c $XDG_CONFIG_HOME/s3cmd/config'
nAlias journalctl command env SYSTEMD_PAGER=lnav journalctl -o short-iso-precise
nAlias pacman echo use paru
nAlias dmesg sudo dmesg -T
reAlias history -i 100
nAlias watch hwatch ' '
nAlias task go-task
unalias diff
nAlias openstack CLIFF_MAX_TERM_WIDTH=999 openstack

alias -g A='| awk'
alias -g B='| base64'
alias -g BD='B -d'
alias -g C='| clip'
alias -g COL='| column'
alias -g COUNT='| wc -l'
alias -g G='| grep'
alias -g GZ='| gzip'
alias -g GZD='GZ -d'
alias -g J='| jq'
alias -g L='| less --raw-control-chars'
alias -g NL='| /bin/cat'
alias -g LO='| lnav'
alias -g S='| sed'
alias -g SP='| sponge'
alias -g T='| tee'
alias -g TD='T /dev/stderr'
alias -g U='| up'
alias -g U='| urlencode'
alias -g UD='| urldecode'
alias -g UR='U --unsafe-full-throttle'
alias -g X='| xargs'
alias -g Y='| yq'

#if command -v kubectl-neat-diff > /dev/null; then
#  export KUBECTL_EXTERNAL_DIFF=kubectl-neat-diff
#fi
if (( ${+commands[dyff]} )); then
  export KUBECTL_EXTERNAL_DIFF="dyff between --omit-header --set-exit-code"
fi

if ! (( ${+commands[kustomize]} )); then
  function kustomize() {
    case "$1" in
      build)
        shift
        ;;
      *)
        echo "Only 'build' is supported as a command" > /dev/stderr
        return 1
        ;;
    esac
    kubectl kustomize "${@}"
  }
fi

