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
export XDG_STATE_HOME="$HOME/.local/state"
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
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
export GOPATH="$XDG_CACHE_HOME/go"
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

export BROWSER=browser
export CLUSTERCTL_DISABLE_VERSIONCHECK="true"
export CM_DIR="$XDG_DATA_HOME/clipmenud"
export CM_LAUNCHER=rofi
export CM_MAX_CLIPS=0
export EDITOR=nvim
export FZF_ALT_C_COMMAND='fd -t d --hidden --exclude=.git'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -20'"
export FZF_CTRL_T_COMMAND='fd -t f --hidden --exclude=.git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --pager=never -p {} | head -20'"
export GLAMOUR_STYLE=dracula
export GOFLAGS="-modcacherw"
export GRADLE_COMPLETION_UNQUALIFIED_TASKS="true"
export GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx1G
export GUM_SPIN_SPINNER=points
export HELM_DIFF_OUTPUT="dyff"
export HELM_PLUGINS="/usr/lib/helm/plugins"
export HISTSIZE=9223372036854775807
export HWATCH="--differences word --no-help-banner"
export KUBECTL_NODE_SHELL_POD_CPU=0
export KUBECTL_NODE_SHELL_POD_MEMORY=0
export PAGER=less
export SAVEHIST=9223372036854775807
export SDL_AUDIODRIVER="pulse"
export SECRETS_EXTENSION=".gpg"
export SYSTEMD_PAGERSECURE=false
export VISUAL="$EDITOR"

if [[ "${XDG_SESSION_TYPE:-tty}" == "tty" && -o interactive ]]; then
  case "${XDG_VTNR}" in
    1)
      export XDG_SESSION_TYPE=x11
      systemctl --user import-environment 2> /dev/null
      xorgConfig=""
      if lsmod | grep -Eq ^nvidia; then
        xorgConfig="-config nvidia.conf"
      fi
      exec systemd-cat --stderr-priority=warning --identifier=xorg nice -n -19 startx -- $xorgConfig
      ;;
    a)
      export XDG_CURRENT_DESKTOP=sway
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      #export WLR_DRM_NO_MODIFIERS=1
      #export WLR_DRM_DEVICES=/dev/dri/card0
      systemctl --user import-environment 2> /dev/null
      exec systemd-cat --stderr-priority=warning --identifier=wayland nice -n -19 sway --unsupported-gpu
      ;;
    a)
      export XDG_CURRENT_DESKTOP=hyprland
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export WLR_DRM_NO_MODIFIERS=1
      export WLR_DRM_DEVICES=/dev/dri/card0
      systemctl --user import-environment 2> /dev/null
      exec systemd-cat --stderr-priority=warning --identifier=wayland nice -n -19 Hyprland
      ;;
  esac
fi

if [[ ! -v DISPLAY ]]; then
  export GPG_TTY="$(tty)"
fi

renice -n -10 -p $(pgrep -s $$) >/dev/null

#if ! cat /proc/self/cgroup | awk -F:: '{print $2}' | xargs -i cat /sys/fs/cgroup/{}/cgroup.controllers | grep -q cpu; then
#  exec systemd-run --user --slice-inherit --property=Delegate=yes --same-dir --scope -S
#fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
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
  fzf
  git
  git-auto-fetch
  gitfast
  gradle
  kubectl
  per-directory-history
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-you-should-use
)

export HISTORY_BASE="$XDG_DATA_HOME/directory_history"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump-${ZSH_VERSION}"

source $ZSH/oh-my-zsh.sh

ZSH_HIGHLIGHT_STYLES[comment]=fg=#7a7a7a
autoload -Uz +X compinit && compinit -d "$ZSH_COMPDUMP"
autoload -Uz +X bashcompinit && bashcompinit -d "$ZSH_COMPDUMP"

zstyle ':fzf-tab:complete:*' fzf-bindings alt-space:toggle
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group 'left' 'right'
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*:*' fzf-flags -i --scheme=history
#zstyle ':completion:*' matcher-list 'b:=*'
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh #> /dev/null

compdef _gradle gradle-or-gradlew

[[ -f $XDG_CONFIG_HOME/p10k.zsh ]] && source $XDG_CONFIG_HOME/p10k.zsh

[[ -f /usr/share/LS_COLORS/dircolors.sh ]] && source /usr/share/LS_COLORS/dircolors.sh

setopt KSH_GLOB
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
setopt CORRECT
unsetopt HIST_IGNORE_DUPS
unsetopt SHARE_HISTORY

function fixHistory() {
  local currentPath="${PWD}"
  local currentHistory="${HISTORY_BASE}/${currentPath}/history"
  local longestHistory
  longestHistory="$(wc --total=never -l "${currentHistory}" "${HOME}/../.snapshots/"*"/snapshot/$(realpath --relative-to="$(dirname "$HOME")" "${HOME}")/$(realpath --relative-to="${HOME}" "${HISTORY_BASE}")/${currentPath}/history" | sort -h | tail -1 | awk '{print $2}')"
  if [[ ! "$longestHistory" -ef "$currentHistory" ]]; then
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

function command_not_found_handler() {
  local exitCode=0
  [[ "${1:0:1}" == : ]] && return 0
  [[ "$1" =~ ^cccccc ]] && return 0
  tmpPackage $1
  $@ || exitCode=$?
  [[ "${#tmpPackages[@]}" -gt 0 ]] && paru -Rs -- "${tmpPackages[@]}"
  return $exitCode
}

function _nop() {}

function e() {
  i3-msg "exec xdg-open \"$*\""
}

function idea() {
  if [[ ! -v 1 ]]; then
    systemd-run -d --user open_project _
  else
    systemd-run -d --user open_project "$(realpath "$1")"
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
  command systemd-run --user -q --scope --unit reload-tmpfiles $(command systemctl --user cat systemd-tmpfiles-setup.service | grep ^ExecStart | cut -d = -f 2)
}

function swap() {
  local tmp
  tmp=$(mktemp -u XXXXXX)
  mv "$1" "$tmp" && mv "$2" "$1" &&  mv "$tmp" "$2"
}

function bak() {
  cp -ar "${1%/}" "${1%/}-$(date --iso-8601=seconds)"
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
  if ! timeout 10s bash -c 'until systemctl --user is-active -q gopass-fuse.service; do sleep 1; done'; then
    echo "gopass-fuse not started, aborting..." >&2
    return 1
  fi
  local pass
  local name="$1"
  if [[ -z "$name" || ! -f "$XDG_RUNTIME_DIR/gopass/$name" ]]; then
    pass="$(gopass ls --flat | grep -v 'kube.?config' | fzf --preview "cat $XDG_RUNTIME_DIR/gopass/{}" | xargs -i -r cat $XDG_RUNTIME_DIR/gopass/{})"
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

  if [[ ! -z $newPackages && "$(echo $newPackages | wc -l)" -gt 0 ]]; then
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
  local installationSuccessful=0
  if [[ "${#@}" -eq 1 ]] && paru -Si "$1" >/dev/null; then
    paru -S "$1" || installationSuccessful=$?
  else
    paru -- "${@}" || installationSuccessful=$?
  fi
  if [[ "$installationSuccessful" != 0 ]]; then
    return "$installationSuccessful"
  fi
  packages=( $(grep installed /var/log/pacman.log | awk '{print $4}' | tail -5 | tac | awk '!x[$0]++') )
  if [[ "${packages[(Ie)${package}]}" -gt 0 ]] && read -q "?Auto-uninstall '$package'? "; then
    [[ -v tmpPackages ]] || echo what?
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
  local xclipCommand=(xclip -selection clipboard -r)
  local type
  local image=false
  if [[ -t 0 ]]; then
    xclipCommand+=( -o )
    if type="$(xclip -selection clipboard -o -t TARGETS | grep image)"; then
      image=true
      xclipCommand+=( -t "$type" )
    fi
  fi
  if [[ "$image" == true && -t 1 ]]; then
    if [[ "$TERM" =~ ^xterm-(kitty|ghostty)$ ]] && (( ${+commands[chafa]} )); then
      "${xclipCommand[@]}" | chafa -
    else
      "${xclipCommand[@]}" | feh -
    fi
  else
    "${xclipCommand[@]}"
  fi
}
compdef _nop clip

function column() {
  local -a args
  args=( $(getopt -u -o "f" -n "$0" -- "$@") ) || return 1
  local flush
  local -i col=1

  while [[ "${#args}" -gt 0 ]]; do
    case "${args[1]}" in
      -f)
        flush=";fflush()"
        ;;
      --) # positional arguments
        if [[ "${args[2]}" =~ [0-9]+ ]]; then
          col=${args[2]}
          shift args
        fi
        ;;
      *)
        break
        ;;
    esac
    shift args
  done
  awk ${args[@]} "{print \$$col$flush}"
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
        git commit . -m "chore: Version Bump"
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

  if ! command systemctl --user is-active -q gopass-fuse; then
    return 1
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
  MANAGEMENT_KUBECONFIGS="$XDG_CONFIG_HOME/kube/mgmt-dev;$XDG_CONFIG_HOME/kube/mgmt-prod;$XDG_CONFIG_HOME/kube/mgmt-bfe-prod" MULTI_CAPO_SHELL_CUSTOM_NAME_EXPRESSION='.metadata.annotations["t8s.teuto.net/cluster"] // "" | try @base64d' MULTI_CAPO_SHELL_CUSTOM_COLUMN_CUSTOMER_NAME='.metadata.annotations["t8s.teuto.net/customer-name"] // "" | try @base64d // .metadata.labels["t8s.teuto.net/customer-id"]' CAPO_SHELL_KUBECONFIG_FILTER='.users |= map({name: .name, user: {exec: {apiVersion: "client.authentication.k8s.io/v1beta1", command: "kubectl", args: ["oidc-login", "get-token", "--oidc-issuer-url=https://auth.k8s.teuto.net", "--token-cache-storage=keyring", "--oidc-client-id=kubernetes", "--oidc-extra-scope=email", "--oidc-extra-scope=groups", "--oidc-extra-scope=offline_access", "--open-url-after-authentication="]}}})' multi-capo-shell "${@}"
}

function kk9s() {
  kk k9s "${@}"
}

function k9s() {
  if [[ ! -f "$KUBECONFIG" ]]; then
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

function schedule_meeting() {
  local time="${1?}"
  local type
  if [[ "$2" =~ https://* ]]; then
    local url="$2"
    type="${3:-meeting}"
  else
    type="${2:-meeting}"
  fi
  if [[ -v url ]]; then
    command systemd-run --user --on-calendar=@$(date --date="today $time" +%s) --property={Wants,After}="browser@$type.service" -- browser profile $type "$url"
  else
    command systemd-run --user --on-calendar=@$(date --date="today $time" +%s) -- systemctl --user start "browser@$type"
  fi
}

function share() {
  local curlCommand=(curl -fsSL https://0x0.st)
  local url
  if [[ ! -t 0 ]]; then
    url="$("${curlCommand[@]}" -F 'file=@-')"
  elif [[ -v 1 && -f "$1" ]]; then
    url="$("${curlCommand[@]}" -F "file=@$1")"
  else
    echo "Neither stdin nor a file has been given or the file doesn't exist" >&2
    return 1
  fi
  echo "$url" | if [[ -t 1 ]]; then
    clip
    echo "$url"
  else
    cat -
  fi
}

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
reAlias rm -i
reAlias cp -i
reAlias mv -i
nAlias http xh
#reAlias ls --almost-all --indicator-style=slash --human-readable --sort=version --escape --format=long --color=always --time-style=long-iso
#nAlias ls exa --all --binary --group --classify --sort=filename --long --colour=always --time-style=long-iso --git
nAlias ls lsd --almost-all --git --color=always --long --date=+'%Y-%m-%dT%H:%M:%S'
if [[ "$(id -u)" != 0 ]] && (( ${+commands[sudo]} )); then
  for cmd in systemctl systemd-run ip; do
    nAlias $cmd sudo $cmd
  done
fi
nAlias top htop
nAlias vim nvim
nAlias vi vim
nAlias cat "bat --pager 'less -RF' --nonprintable-notation unicode"
nAlias man batman
compdef _man batman
reAlias fzf --ansi
reAlias prettyping --nolegend
nAlias ping prettyping
nAlias du dua -x interactive
nAlias df duf -width 999
reAlias rg -S --engine auto --hidden --glob '!.git' --context-separator=──────────
reAlias jq -er
reAlias yq -er
nAlias k 'kubectl' # "--context=${KUBECTL_CONTEXT:-$(kubectl config current-context)}" ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'
nAlias podman-run podman run --rm -i -t
nAlias htop btop
reAlias feh --scale-down --auto-zoom
nAlias grep rg
nAlias o xdg-open
nAlias actionlint podman-run -v $PWD:$PWD -w $PWD rhysd/actionlint
nAlias scu command systemctl --user
nAlias sc systemctl
nAlias sru command systemd-run --user
nAlias sr systemd-run
nAlias urldecode 'sed "s@+@ @g;s@%@\\\\x@g" | parallel -0 printf "%b"'
nAlias urlencode 'jq -s -R -r @uri'
nAlias base64 'base64 -w 0'
nAlias tree ls --tree -I .git -I node_modules
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
nAlias machinectl sudo machinectl
reAlias history -i 100
nAlias watch hwatch ' '
nAlias task go-task
nAlias openstack CLIFF_MAX_TERM_WIDTH=999 openstack
nAlias auniq "awk '!x[\$0]++'"

alias -g A='| awk'
alias -g B='| base64'
alias -g BD='B -d'
alias -g C='| clip'
alias -g COL='| column'
alias -g COUNT='| wc -l'
alias -g G='| grep'
alias -g GF'G --line-buffered'
alias -g GZ='| gzip'
alias -g GZD='GZ -d'
alias -g J='| jq'
alias -g L='| less'
alias -g NL='| /bin/cat'
alias -g LO='| lnav'
alias -g P='| parallel --bar'
alias -g PB='| parallel'
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
