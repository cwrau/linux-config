export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DESKTOP_DIR="$XDG_DATA_HOME/applications"
export XDG_DOCUMENTS_DIR="$HOME/Downloads"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Downloads"
export XDG_PUBLICSHARE_DIR="$HOME/Downloads"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_SCREENSHOT_DIR="$HOME/Screenshots"
export XDG_TEMPLATES_DIR="$HOME/Downloads"
export XDG_VIDEOS_DIR="$HOME/Downloads"

declare -x | grep -E '^XDG_.+_DIR=.+$' | sed -r 's#=#="#; s#$#"#' > $XDG_CONFIG_HOME/user-dirs.dirs

export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
export ANDROID_AVD_HOME="$XDG_DATA_HOME/android"
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export AZURE_CONFIG_DIR="$XDG_DATA_HOME/azure"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CLUSTERCTL_DISABLE_VERSIONCHECK=true
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export HELM_DIFF_OUTPUT="dyff"
export HELM_PLUGINS="/usr/lib/helm/plugins"
export KONAN_DATA_DIR="$XDG_DATA_HOME/konan"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export MINIKUBE_HOME="$XDG_DATA_HOME/minikube"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_DATA_HOME/NuGet"
export PULSE_COOKIE="$XDG_RUNTIME_DIR/pulse/cookie"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SECRETS_DIR="$(realpath --relative-base=$HOME $XDG_CONFIG_HOME/gitsecret)"
export SONAR_USER_HOME="$XDG_DATA_HOME/sonarlint"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
export STACK_ROOT="$XDG_CONFIG_HOME/stack"
export TALOSCONFIG="$XDG_CONFIG_HOME/talos/config.yaml"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export XAUTHORITY="$XDG_CACHE_HOME/x11/authority"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

export BROWSER=google-chrome-stable
export EDITOR=nvim
export FZF_ALT_C_COMMAND='fd -t d --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -20'"
export FZF_CTRL_T_COMMAND='fd -t f --hidden'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --pager=never -p {} | head -20'"
export GRADLE_COMPLETION_UNQUALIFIED_TASKS="true"
export GRADLE_OPTS=-Dorg.gradle.jvmargs=-Xmx1G
export HISTSIZE=9223372036854775807
export PAGER=less
export SAVEHIST=9223372036854775807
export SDL_AUDIODRIVER="pulse"
export SECRETS_EXTENSION=".gpg"
export SYSTEMD_PAGERSECURE=false
export VISUAL="$EDITOR"
export KUBECTL_NODE_SHELL_POD_CPU=0
export KUBECTL_NODE_SHELL_POD_MEMORY=0

if [[ $- = *i* ]] && [[ "$XDG_VTNR" == 1 ]]; then
  if false; then
    if [[ -z "$XDG_CURRENT_DESKTOP" ]]; then
      export XDG_CURRENT_DESKTOP=sway
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export WLR_DRM_NO_MODIFIERS=1
      systemctl --user import-environment 2> /dev/null
      exec systemd-cat --stderr-priority=warning --identifier=sway sway --unsupported-gpu
    fi
  else
    if [[ -z "$DISPLAY" ]]; then
      systemctl --user import-environment 2> /dev/null
      exec systemd-cat --stderr-priority=warning --identifier=xorg startx
    fi
  fi
fi
set +x

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

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'
zstyle ':completion:*' use-ip true

export ZSH_CACHE_DIR=${XDG_CACHE_HOME}/oh-my-zsh
[ -d $ZSH_CACHE_DIR ] || mkdir $ZSH_CACHE_DIR
ZSH_CUSTOM=/usr/share/zsh
ZSH_THEME="../../zsh-theme-powerlevel10k/powerlevel10k"

plugins=(
  direnv
  git
  git-auto-fetch
  gitfast
  fancy-ctrl-z
  fd
  fzf
  helm
  kubectl
  gradle
  ripgrep
  sudo
  per-directory-history
  zsh-syntax-highlighting
  zsh-autosuggestions
)

export HISTORY_BASE="$XDG_CACHE_HOME/directory_history"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump-${ZSH_VERSION}"

source $ZSH/oh-my-zsh.sh

source /usr/share/git/completion/git-completion.zsh &> /dev/null
source /usr/share/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh &> /dev/null

autoload -U compinit && compinit -d "$ZSH_COMPDUMP"
autoload -U bashcompinit && bashcompinit -d "$ZSH_COMPDUMP"

compdef _gradle gradle-or-gradlew

[[ -f $XDG_CONFIG_HOME/p10k.zsh ]] && source $XDG_CONFIG_HOME/p10k.zsh
[[ -f /opt/azure-cli/az.completion ]] && source /opt/azure-cli/az.completion
[[ -f /usr/share/LS_COLORS/dircolors.sh ]] && source /usr/share/LS_COLORS/dircolors.sh

setopt KSH_GLOB
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
unsetopt HIST_IGNORE_DUPS
unsetopt SHARE_HISTORY

function _check_command() {
  if [ $? -eq 0 ] && command -v $1 &> /dev/null; then
    $@
    local ret=$?
    paru -Rs $(rg --text installed /var/log/pacman.log | tail -1 | awk '{print $4}')
    return $ret
  fi
  return 137
}

function command_not_found_handler() {
  if [[ "$1" =~ ^cccccc ]]; then
    return 0
  fi
  local packages
  echo "Packages containing '$1' in name"
  paru -- $1
  _check_command $@
}

function _nop() {}

function e.() {
  i3-msg "exec xdg-open $PWD"
}
compdef _nop e.

function e() {
  i3-msg "exec xdg-open \"$*\""
}

function _ssh() {
  if [[ "${#@}" > 1 ]] || [[ "${#@}" == 0 ]]; then
    /usr/bin/ssh "$@"
  elif [[ -f ~/.ssh/checked_hosts ]] && grep -q -- "$1" ~/.ssh/checked_hosts; then
    name="$1"
    shift
    scp -q ~/.bashrc ${name}:/tmp/cwr.bashrc > /dev/null

    /usr/bin/ssh $name -t "sh -c 'if which bash &> /dev/null; then bash --rcfile /tmp/cwr.bashrc -i; else if which ash &> /dev/null; then ash; else sh; fi; fi'"
    return $?
  else
    ssh-copy-id $1
    ret=$?
    if [ $ret -eq 0 ]; then
      echo "$1" >> ~/.ssh/checked_hosts
      ssh "$@"
      return $?
    fi
    return $ret
  fi
}

function idea() {
  [[ -z "$1" ]] && open_project _
  [[ "$1" ]] && open_project "$(realpath "$1")"
}

function diff() {
  if [ -t 1 ]; then
    command diff -u "${@}" | diff-so-fancy | /usr/bin/less --tabs=1,5 -RF
  else
    command diff -u "${@}"
  fi
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

function _hr_getYaml() {
  local yaml="$1"
  local index="$2"
  local kind="$3"

  <<<"$yaml" | yq -erys "[.[] | select(.kind == \"$kind\")][$index]"
}

function _hr_getNamespace() {
  local yaml="$1"

  <<<"$yaml" | yq -er '.spec.targetNamespace // .metadata.namespace'
}

function _hr_getReleaseName() {
  local yaml="$1"
  local ns

  if <<<"$yaml" | yq -e '.apiVersion == "helm.fluxcd.io/v1" or .spec.targetNamespace' > /dev/null; then
    <<<"$yaml" | yq -er ".spec.releaseName // \"$(_hr_getNamespace "$yaml")-\\(.metadata.name)\""
  else
    <<<"$yaml" | yq -er '.spec.releaseName // .metadata.name'
  fi
}

function _hr_git() {
  local subCommand="$1"
  local commands=()
  local gitUrl="$2"
  local gitRef="$3"
  local gitPath="$4"
  local namespace="$5"
  local releaseName="$6"
  local values="$7"

  if [[ "$subCommand" = "template" ]]; then
    commands+=("template")
  elif [[ "$subCommand" = "diff" ]]; then
    commands+=("diff" "upgrade" "--show-secrets" "--color")
  fi

  rm -rf /tmp/helm-chart
  (
    git clone "$gitUrl" /tmp/helm-chart
    cd /tmp/helm-chart
    git checkout "$gitRef"
  ) > /dev/null

  helm dependency build "/tmp/helm-chart/$gitPath" > /dev/null
  helm "${commands[@]}" --namespace $namespace $releaseName "/tmp/helm-chart/$gitPath" --values <(<<< "$values") ${@:8}
  rm -rf /tmp/helm-chart
}

function helmrelease() {
  local subCommand="${1?You need to set the command}"
  shift
  local commands=()
  local namespace
  local releaseName
  local helmReleaseYaml
  local numberOfHelmReleases
  local values
  local index=0
  local sourceParameter
  local yaml
  case "$subCommand" in
    template)
      commands+=("template")
      ;;
    diff)
      commands+=("diff" "upgrade" "--show-secrets" "--color" "--output=dyff")
      ;;
    install)
      commands+=("install")
      ;;
    *)
      echo "command '$subCommand' is not implemented" > /dev/stderr
      return 1
      ;;
  esac

  while [[ "$#" != 0 ]]; do
    case "$1" in
      -)
        yaml=$(cat)
        shift
        ;;
      -+([0-9]))
        index="${1/-/}"
        shift
        ;;
      -ALL)
        index=ALL
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        if [[ -f "$1" ]]; then
          yaml=$(cat "$1")
        elif [[ -d "$1" ]]; then
          sourceParameter="$1"
        elif [[ "$1" =~ ^https://* ]]; then
          sourceParameter="$1"
        else
          echo "parameter '$1' is not supported" > /dev/stderr
          return 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$yaml" ]]; then
    yaml=$(cat)
  fi

  numberOfHelmReleases=$(<<< "$yaml" | yq -ers '[.[] | select(.kind == "HelmRelease")] | length')
  if [[ "$numberOfHelmReleases" -lt 1 ]]; then
    echo "There are no HelmReleases in the input" > /dev/stderr
    return 1
  elif [[ "$numberOfHelmReleases" != 1 ]] && [[ "$subCommand" == "install" ]]; then
    echo "You can only install 1 HelmReleases at the same time" > /dev/stderr
    return 1
  elif [[ "$numberOfHelmReleases" -gt 1 ]] && [[ "$index" = "ALL" ]]; then
    <<<"$yaml" | yq -erys '.[] | select(.kind != "HelmRelease") | select(.)' \
      | if [[ "$subCommand" = "template" ]]; then
          cat -
        elif [[ "$subCommand" = "diff" ]]; then
          kubectl diff -f - || true
        fi
    for index in {0..$((numberOfHelmReleases - 1))}; do
      if [[ "$subCommand" = "template" ]]; then
        echo ---
      fi
      <<<"$yaml" | yq -erys '([.[] | select(.kind == "HelmRelease")]['"$index"']),(.[] | select(.kind | IN(["GitRepository", "HelmRepository"][])))' | helmrelease "$subCommand" -
    done
  fi

  helmReleaseYaml=$(_hr_getYaml "$yaml" "$index" HelmRelease)
  [ "$?" -ne 0 ] && return 1
  namespace=$(_hr_getNamespace "$helmReleaseYaml")
  releaseName=$(_hr_getReleaseName "$helmReleaseYaml")
  values=$(<<< "$helmReleaseYaml" | yq -y -er .spec.values)
  if [ -d "$sourceParameter" ]; then
    helm "${commands[@]}" --namespace $namespace $releaseName "$sourceParameter" --values <(<<< "$values") ${@}
  elif <<< "$helmReleaseYaml" | yq -e '.apiVersion == "helm.fluxcd.io/v1"' > /dev/null; then
    if <<< "$helmReleaseYaml" | yq -e .spec.chart.git > /dev/null; then
      local gitPath
      local gitUrl
      local gitRef
      gitPath="$(<<< "$helmReleaseYaml" | yq -er '.spec.chart.path // "."')"
      gitUrl="$(<<< "$helmReleaseYaml" | yq -er .spec.chart.git)"
      gitRef="$(<<< "$helmReleaseYaml" | yq -er '.spec.chart.ref // "master"')"
      _hr_git "$subCommand" "$gitUrl" "$gitRef" "$gitPath" "$namespace" "$releaseName" "$values" "$@"
    else
      helm "${commands[@]}" --namespace $namespace --repo $(<<< "$helmReleaseYaml" | yq -er .spec.chart.repository) $releaseName $(<<< "$helmReleaseYaml" | yq -er .spec.chart.name) --version $(<<< "$helmReleaseYaml" | yq -er .spec.chart.version) --values <(<<< "$values") "$@"
    fi
  else
    local sourceNamespace
    local sourceName
    local sourceKind
    local sourceResource
    local chartName
    local helmRepositoryUrl
    sourceNamespace=$(<<< "$helmReleaseYaml" | yq -er ".spec.chart.spec.sourceRef.namespace // \"$namespace\"")
    sourceName=$(<<< "$helmReleaseYaml" | yq -er .spec.chart.spec.sourceRef.name)
    sourceKind=$(<<< "$helmReleaseYaml" | yq -er .spec.chart.spec.sourceRef.kind)
    if [[ -z "$sourceParameter" ]]; then
      local sourceYaml
      sourceYaml=$(_hr_getYaml "$yaml" "" "$sourceKind")
      sourceResource=$(<<< "$sourceYaml" | yq -erys "[.[] | select( (.metadata.namespace == \"$sourceNamespace\") and (.metadata.name == \"$sourceName\") )][0]")
      if [[ "$?" != 0 ]]; then
        sourceResource=$(kubectl --namespace=$sourceNamespace get $sourceKind $sourceName -o yaml)
        if [[ "$?" != 0 ]]; then
          helmRepositoryUrl="https://teutonet.github.io/teutonet-helm-charts"
          echo "Source resource '$sourceNamespace/$sourceKind/$sourceName' not found in cluster nor in input" > /dev/stderr
          vared -p "Please specify Helm Repository URL: " helmRepositoryUrl > /dev/null
          sourceKind=HelmRepository
          sourceResource=$'spec:\n  url: '"$helmRepositoryUrl"
        fi
      fi
    elif ! [[ -z "$sourceParameter" ]]; then
      sourceResource=$'spec:\n  url: '"$sourceParameter"
    fi
    chartName="$(<<< "$helmReleaseYaml" | yq -er .spec.chart.spec.chart)"
    case "$sourceKind" in
      GitRepository)
        local gitUrl
        local gitRef
        gitUrl="$(<<< "$sourceResource" | yq -er .spec.url)"
        gitRef="$(<<< "$sourceResource" | yq -er '.spec.ref | if .branch then .branch elif .tag then .tag elif .semver then .semver elif .commit then .commit else "master" end')"
        _hr_git "$subCommand" "$gitUrl" "$gitRef" "$chartName" "$namespace" "$releaseName" "$values" "$@"
        ;;
      HelmRepository)
        local chartVersion
        helmRepositoryUrl="$(<<< "$sourceResource" | yq -er .spec.url)"
        chartVersion="$(<<< "$helmReleaseYaml" | yq -er .spec.chart.spec.version)"
        helm "${commands[@]}" --namespace $namespace --repo "$helmRepositoryUrl" $releaseName "$chartName" --version "$chartVersion" --values <(<<< "$values") "$@"
        ;;
      *)
        echo "'$sourceKind' is not implemented" > /dev/stderr
        return 1
        ;;
    esac
  fi
}

function hr() {
  helmrelease "template" "$@"
}
function _hr() {
  #_arguments "1: :($(fd --full-path $(realpath "${${words[2]/\~/$HOME}:-$PWD}" / | xargs -i realpath {} --relative-to="$PWD") -e yaml -e yml -X rg '^kind: HelmRelease$' -l))" \
  #_arguments "1:The helm release to template:_files -f -g '*.(yaml|yml)'" \
  #_arguments "1:The helm release to template:($(cd $(dirname "${words[2]:-$PWD}"); fd -e yaml -e yml -X rg '^kind: HelmRelease$' -l))" \
  #_arguments "1:The helm release to template:->release" \
  _arguments "1:The helm release to template:($(fd -e yaml -e yml -X rg '^kind: HelmRelease$' -l))" \
             "2::The helm chart to use for templating:_files -/"
  case "$state" in
    release)
      if [ -d "${words[2]}" ]; then
        fd --search-path="${words[2]}" -e yaml -e yml -X rg '^kind: HelmRelease$' -l #| xargs -i realpath {} --relative-to=$PWD
      else
        _files -f -g '*.(yaml|yml)'
      fi
      ;;
  esac
}
compdef _hr hr

function hrDiff() {
  HELM_DIFF_USE_UPGRADE_DRY_RUN=true helmrelease "diff" "$@"
}
compdef _hr hrDiff

function hrInstall() {
  helmrelease "install" "$@"
}
compdef _hr hrInstall

function knodes() {
  echo "+> ${@}" >&2
  for node in $(kubectl get nodes -o json | jq '.items[] | "\(.metadata.name):\(.status.addresses[] | select(.type == "InternalIP") | .address)"' | sort -V); do
    IFS=: read name ip <<< "$node"
    echo $name >&2
    ssh $ip $@
  done
}

function gop(){
  local pass
  pass="$(gopass ls --flat | /bin/grep -E -v 'kube.?config' | fzf --preview "gopass show {}" | xargs -r -i cat $XDG_RUNTIME_DIR/gopass/{})"
  if ! [ -t 1 ]; then
    echo -n "$pass"
  else
    echo -n "$pass" | clip
  fi
}
compdef _nop gop

function kdiff () {
  kustomize build --enable-alpha-plugins . | kubectl diff -f - | diff-so-fancy
}
compdef _nop kdiff

function kapply () {
  kustomize build --enable-alpha-plugins . | kubectl apply -f -
}
compdef _nop kapply

function cwatch () {
  local ns=$1
  local cluster=$2
  watch -w --color -n 1 clusterctl describe cluster --show-conditions all --echo -n $ns $cluster
}
function _cwatch() {
  _arguments "1: :($(kubectl get namespaces --no-headers -o custom-columns=:metadata.name))"
  _arguments "2: :->cluster"

  if [[ "$state" == "cluster" ]]; then
    compadd $(kubectl --namespace ${words[2]} get clusters --no-headers -o custom-columns=:metadata.name)
  fi
}
compdef _cwatch cwatch

function kk() {
  local config
  local openRc
  local unitName
  local query

  if ! systemctl --user is-active -q gopass-fuse.service; then
    systemctl --user start --no-block gopass-fuse
  fi

  if [[ -z "$1" ]]; then
    query=""
  elif [[ -f "$XDG_RUNTIME_DIR/gopass/$1" ]]; then
    config="$1"
  else
    query="$1"
  fi
  if [[ -z "$config" ]]; then
    config="$(gopass ls -flat | /bin/grep -E 'kube.?config' | fzf --query "$query" -1)"
    if [[ "$?" != 0 ]]; then
      return
    fi
  fi
  mkdir -p "$XDG_RUNTIME_DIR/kconfig"
  echo "$config" > "$XDG_RUNTIME_DIR/kconfig/current_kubeconfig"
  export KUBECONFIG="$XDG_RUNTIME_DIR/gopass/$config"
  openRc="$(dirname "$XDG_RUNTIME_DIR/gopass/$config")/open-rc"
  if [[ -f "$openRc" ]]; then
    unitName="$(md5sum "$openRc" | awk NF=1)"
    if ! systemctl --user is-active -q "$unitName"; then
      systemd-run --user --collect -q --slice sshuttle --unit="$unitName" -- bash -c "source '$openRc'"
    fi
  fi
  ln -fs "$KUBECONFIG" "$XDG_CONFIG_HOME/kube/config"
}

function krsdiff() {
  local namespace
  local firstRS
  local secondRS

  namespace="$(kubectl get namespaces -o custom-columns=:metadata.name | fzf -1)"
  firstRS="$(kubectl -n "$namespace" get replicasets -o custom-columns=:metadata.name | fzf -1 --preview "kubectl -n '$namespace' get replicaset {} -o custom-columns=:metadata.creationTimestamp")"
  secondRS="$(kubectl -n "$namespace" get replicasets -o custom-columns=:metadata.name | grep -Ev "^$firstRS\$" | fzf -1 --preview "kubectl -n '$namespace' get replicaset {} -o custom-columns=:metadata.creationTimestamp")"

  dyff between <(kubectl -n "$namespace" get rs "$firstRS" -o yaml | yq -y '.metadata.name="rs"') <(kubectl -n "$namespace" get rs "$secondRS" -o yaml | yq -y '.metadata.name="rs"')
}

function krc() {
  kubectl config current-context
}

function klc() {
  kubectl config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"
}

function kcc() {
  local CONTEXT
  CONTEXT="$(klc | fzf -1 | awk '{print $NF}')"
  if [[ "$?" == 0 ]]; then
    kubectl config use-context $CONTEXT
  fi
}

function pkgSync() {
  local OLDPWD=$PWD
  cd $HOME
  git pull
  systemctl --user daemon-reload

  local package
  local packages
  local depends
  eval $(sed -n '/#startPackages/,/#endPackages/p;/#endPackages/q' $HOME/config/PKGBUILD | rg -v '#')
  packages=$depends

  local targetPackages
  targetPackages=$(echo $packages | tr ' ' '\n')
  local originalPackages=$targetPackages

  local newPackages
  newPackages=$(paru -Qqe | rg -xv $(echo $targetPackages | tr '\n' '|' | sed 's#|$##g'))

  if [ ! -z $newPackages ] && [[ "$(echo $newPackages | grep -v linux-config | wc -l)" -gt 0 ]]; then
    echo "$(<<<$newPackages | grep -v linux-config | wc -l) new Packages"
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
      paru -Si $package
      paru -Qi $package
      read -k 1 "choice?[I]nstall, [r]emove, [d]epends or [s]kip $package? "
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
    done <<<"$missingPackages"
  else
    echo "No missing Packages"
  fi

  local orphanedPackages
  orphanedPackages=$(pacman -Qqtd)

  if [ ! -z $orphanedPackages ]; then
    echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
    if read -q "?Remove orphaned packages? "; then
      while [ ! -z $orphanedPackages ]; do
        echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
        paru -R --noconfirm $(tr '\n' ' ' <<<$orphanedPackages)
        echo
        orphanedPackages=$(pacman -Qqtd)
      done
    fi
  else
    echo "No orphaned Packages"
  fi

  local unusedPackages
  unusedPackages=$(pacman -Qi | awk '/^Name/{name=$3} /^Required By/{req=$4} /^Optional For/{opt=$0} /^Install Reason/{res=$4$5} /^$/{if (req == "None" && res != "Explicitlyinstalled"){print name}}' | rg -xv $(echo $targetPackages | tr '\n' '|' | sed 's#|$##g'))

  if [ ! -z $unusedPackages ]; then
    echo "$(wc -l <<<$unusedPackages) unused Packages"
    if read -q "?Remove unused packages? "; then
      while [ ! -z $unusedPackages ]; do
        echo "$(wc -l <<<$unusedPackages) unused Packages"
        paru -R --noconfirm $(tr '\n' ' ' <<<$unusedPackages)
        echo
        unusedPackages=$(pacman -Qi | awk '/^Name/{name=$3} /^Required By/{req=$4} /^Optional For/{opt=$0} /^Install Reason/{res=$4$5} /^$/{if (req == "None" && res != "Explicitlyinstalled"){print name}}')
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
  if ! /usr/bin/diff <(echo $originalPackages) <(echo $targetPackages) &> /dev/null; then
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

function clip() {
  xclip -selection clipboard
}
compdef _nop clip

function releaseAur() {
  git add PKGBUILD .SRCINFO && git clean -xfd && updpkgsums && makepkg -df && makepkg --printsrcinfo > .SRCINFO && git commit -v . && git push && git clean -xfd
}

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
nAlias :r exec zsh
reAlias env "-0 | sort -z | tr '\0' '\n'"
reAlias rm -i
reAlias cp -i
reAlias mv -i
#reAlias ls --almost-all --indicator-style=slash --human-readable --sort=version --escape --format=long --color=always --time-style=long-iso
nAlias ls exa --all --binary --group --classify --sort=filename --long --colour=always --time-style=long-iso --git
reAlias nvim -b
if [[ "$(id -u)" != 0 ]] && command -v sudo &> /dev/null; then
  for cmd in systemctl pacman ip; do
    nAlias $cmd sudo $cmd
  done
fi
nAlias top htop
nAlias vim nvim
nAlias vi vim
nAlias cat "bat --pager 'less -RF'"
nAlias ps procs
reAlias fzf --ansi
reAlias prettyping --nolegend
nAlias ping prettyping
nAlias du ncdu --exclude-kernfs
nAlias jq gojq
reAlias rg -S
reAlias jq -r
reAlias yq -r
nAlias k 'kubectl' # "--context=${KUBECTL_CONTEXT:-$(kubectl config current-context)}" ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'
nAlias podman-run podman run --rm -i -t
nAlias htop gotop
reAlias gotop -r 250ms
reAlias feh --scale-down --auto-zoom --auto-rotate
nAlias grep rg
nAlias o xdg-open
nAlias dmakepkg podman-run --network host -v '$PWD:/pkg' 'whynothugo/makepkg' makepkg
reAlias watch ' '
nAlias scu /usr/bin/systemctl --user
nAlias sc systemctl
nAlias sru /usr/bin/systemd-run --user
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
nAlias update 'paru && (if [ -f $XDG_RUNTIME_DIR/updates-notification ]; then notify-send.sh -s $(cat $XDG_RUNTIME_DIR/updates-notification); fi) && exit'
reAlias code '--user-data-dir $XDG_DATA_HOME/vscode --extensions-dir $XDG_DATA_HOME/vscode/extensions'
nAlias wd 'while :; do .; sleep 0.1; clear; done'

alias -g A='| awk'
alias -g B='| base64'
alias -g BD='B -d'
alias -g C='| clip'
alias -g COUNT='| wc -l'
alias -g G='| grep'
alias -g GZ='| gzip'
alias -g GZD='GZ -d'
alias -g J='| jq'
alias -g L='| less --raw-control-chars'
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

if ! [[ -f "$KUBECONFIG" ]]; then
  unset KUBECONFIG
  if [[ -f "$XDG_RUNTIME_DIR/kconfig/current_kubeconfig" ]]; then
    kk "$(cat $XDG_RUNTIME_DIR/kconfig/current_kubeconfig)"
  else
    rm -f "$XDG_RUNTIME_DIR/current_kubeconfig"
  fi
fi

function k9s() {
  if [[ $# == 2 ]]; then
    kk $1
    command k9s --context $2
  elif [[ $# == 1 ]]; then
    command k9s --context $1
  elif [[ -f "$KUBECONFIG" ]]; then
    command k9s
  else
    kk
    command k9s
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

#if command -v kubectl-neat-diff > /dev/null; then
#  export KUBECTL_EXTERNAL_DIFF=kubectl-neat-diff
#fi
if command -v dyff > /dev/null; then
  export KUBECTL_EXTERNAL_DIFF="dyff between --omit-header --set-exit-code"
fi
