# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

[ -s /etc/motd ] && cat /etc/motd

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

declare -x | grep ^XDG | sed -r 's#=#="#; s#$#"#' > $XDG_CONFIG_HOME/user-dirs.dirs

export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
export ANDROID_AVD_HOME="$XDG_DATA_HOME/android"
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"
export AZURE_CONFIG_DIR="$XDG_DATA_HOME/azure"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"
export KONAN_DATA_DIR="$XDG_DATA_HOME/konan"
export LESSHISTFILE="$XDG_DATA_HOME/less/history"
export MINIKUBE_HOME="$XDG_DATA_HOME/minikube"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_DATA_HOME/NuGet"
export PULSE_COOKIE="$XDG_RUNTIME_DIR/pulse/cookie"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SONAR_USER_HOME="$XDG_DATA_HOME/sonarlint"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
export STACK_ROOT="$XDG_CONFIG_HOME/stack"
export XAUTHORITY="$XDG_CACHE_HOME/x11/authority"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

export VISUAL=nvim
export EDITOR="$VISUAL"
export PAGER=slit
export BROWSER="google-chrome-stable"
export SAVEHIST=9223372036854775807
export HISTSIZE=9223372036854775807
export SDL_AUDIODRIVER="pulse"
export FZF_ALT_C_COMMAND='fd -t d --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_T_COMMAND='fd --hidden'
export FZF_CTRL_T_OPTS="--preview '(bat --color=always --pager=never -p {} 2> /dev/null || tree -C {}) 2> /dev/null | head -200'"
export GRADLE_OPTS=-Xmx1G
export GRADLE_COMPLETION_UNQUALIFIED_TASKS="true"

if [[ $- = *i* ]]; then
  if [[ -z "$DISPLAY" ]]; then
    if [[ "$XDG_VTNR" -eq 1 ]]; then
      export DISPLAY=:0
      for ENV in $(declare -x +); do
        systemctl --user import-environment $ENV
      done
      exec systemd-cat --stderr-priority=warning --identifier=xorg startx
    fi
  fi
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
  git
  git-auto-fetch
  gitfast
  fancy-ctrl-z
  fd
  fzf
  gpg-agent
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

compdef _gradle gradle-or-gradlew

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f $XDG_CONFIG_HOME/p10k.zsh ]] && source $XDG_CONFIG_HOME/p10k.zsh
[[ -f /opt/azure-cli/az.completion ]] && source /opt/azure-cli/az.completion
[[ -f /usr/share/LS_COLORS/dircolors.sh ]] && source /usr/share/LS_COLORS/dircolors.sh

setopt INC_APPEND_HISTORY
unsetopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
unsetopt share_history

function _check_command() {
  if [ $? -eq 0 ] && command -v $1 &> /dev/null; then
    $@
    local ret=$?
    paru -R $(rg --text installed /var/log/pacman.log | tail -1 | awk '{print $4}')
    return $ret
  fi
  return 137
}

function command_not_found_handler() {
  local packages
  echo "Command '$1' not found, but could be installed via the following package(s):"
  paru -Ss --provides -- $1
  _check_command $@
  [ $? = 137 ] || return $?
  echo "Packages containing '$1' in name"
  paru -- $1
  _check_command $@
  [ $? = 137 ] || return $?
  echo "Packages containg files with '$1' in their name"
  packages=$(paru -Fyq -- $1)
  paru $packages
  _check_command $@
  [ $? = 137 ] || return $?
}

function _nop() {}

function e.() {
  i3-msg "exec xdg-open $PWD"
}
compdef _nop e.

function e() {
  i3-msg "exec xdg-open \"$*\""
}

function ssh() {
  if [[ "${#@}" > 1 ]]; then
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
  i3-msg "exec intellij-idea-ultimate-edition $(realpath ${1:-.})"
}

function diff() {
  /usr/bin/diff -u "${@}" | diff-so-fancy | /usr/bin/less --tabs=1,5 -RF
}

function swap() {
  local tmp
  tmp=$(mktemp -u XXXXXX)
  mv "$1" "$tmp" && mv "$2" "$1" &&  mv "$tmp" "$2"
}

function bak() {
  cp -r "${1%/}" "${1%/}-$(date --iso-8601=seconds)"
}

function bsrv() {
  index="$1"
  shift
  ssh root@buildsrv${index}.4allportal.net $*
}
function _bsrv() {
  _arguments "1: :(1 2 4)"
}
compdef _bsrv bsrv

function 4ap() {
  name="$1"
  shift
  ssh root@${name}.4allportal.net $*
}
function _4ap() {
  _arguments "1: :($(< $HOME/.ssh/known_hosts | awk '{print $1}' | tr ',' '\n' | grep -E '.4allportal\.net' | sed -r 's#.4allportal.net##g' | sort | uniq | xargs echo -n))"
}
compdef _4ap 4ap

function fapp() {
  gradle :assemble --parallel
  local version
  local apps
  version="$(cat build/4app.json | jq -r '.dependencies[] | select(.artifactId == "4allportal-core") | .artifactVersion')"
  apps="$(cat build/4app.json | jq -r '[.dependencies[] | select(.artifactId != "4allportal-core") | "\(.artifactId):\(.artifactVersion)"] | join(",")')"
  rm -rf /tmp/data/apps
  mkdir -p /tmp/data/apps
  cp build/*.4app /tmp/data/apps
  fap "$version" -e APPS_INSTALL=$apps $@
}

function fap() {
  if nc -z localhost 8181; then
    echo 'Port already used'
    return 1
  fi
  mkdir -p /tmp/data/custom/modules/file/mounts
  mkdir -p /tmp/data/data
  <<EOF > /tmp/data/custom/modules/file/mounts/data.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<mount enabled="true">
    <file_module>file</file_module>
    <folder_module>folder</folder_module>
    <base_path>/4allportal/assets</base_path>
    <use_fileid>false</use_fileid>
    <use_volumeid>false</use_volumeid>
    <read_only>false</read_only>
    <min_index_part_size>15</min_index_part_size>
    <max_index_part_size>150</max_index_part_size>
    <exclude_folders>
        <exclude_folder>layout</exclude_folder>
    </exclude_folders>
    <exclude_files>
        <exclude_file>4ap_fileimport[.]xml</exclude_file>
        <exclude_file>Thumbs[.]db</exclude_file>
    </exclude_files>
    <period>60</period>
    <change_handlers>
        <change_handler>com.cm4ap.ce.fsi.handler.FileChangeHandler</change_handler>
        <change_handler>com.cm4ap.ce.fsi.handler.LogOutputHandler</change_handler>
    </change_handlers>
    <use_mod_time_millis>true</use_mod_time_millis>
</mount>
EOF

  local tag=$1
  shift

  local podmanArgs=()
  local fapArgs=()

  local next=false
  local keep=false

  for arg in "$@"; do
    if [ "$arg" = "-k" ]; then
      keep=true
      continue
    fi

    if [ "$arg" = "--" ]; then
      next=true
      continue
    fi

    if [ "$next" = "false" ]; then
      podmanArgs+=("$arg")
    else
      fapArgs+=("$arg")
    fi
  done

  if [ "$tag" != "LOCAL" ]; then
    podman pull registry.4allportal.net/4allportal:$tag
  fi
  local exitCode
  set -x
  podman run --rm -it -e DATABASE_HOST=localhost -e DATABASE_TYPE=mariadb -e MANAGED=true --userns keep-id --net host \
    --name="4allportal-$tag" \
    --read-only \
    -v /tmp/data/data:/4allportal/data/data:ro \
    --tmpfs=/{4allportal/{_runtime,assets},tmp} $podmanArgs \
    -v /tmp/data:/4allportal/data \
    registry.4allportal.net/4allportal:$tag $fapArgs
  exitCode=$?
  set +x

  if [ "$keep" = "false" ]; then
    rm -rf /tmp/data
  fi
  return exitCode
}
function _fap() {
  local state
  _arguments "1: :->core"
  _arguments "--app: :->app"
  case "$state" in
    core)
      echo core >> /tmp/com
      _wanted coreVersion expl 'coreVersion' 'appVs 4allportal-core | sed -r "s#4allportal-core:##g"' && ret=0
      ;;
    app)
      if compset -S ':*'; then
        echo app >> /tmp/com
        #compadd $(_getApps)
        _wanted app expl '4apps' _getApps && ret=0
      elif compset -P '*:'; then
        _wanted version expl 'versions' appVs '$app' && ret=0
      else
        _alternative 'apps:4apps:_getApps'
      fi
  esac
}
function _4apps() {
  _combination  apps-versions apps
}

function fapClone() {
  sshAccess=root@${1}
  shift
  if [ -z "$1" ] || [ "$1" = "" ]; then
    installationPath=/4allportal/data
  else
    installationPath=${1}
    shift
  fi
  apps="$(ssh $sshAccess -- find $installationPath/apps -name '*.4app' -exec unzip -p {} 4app.json \\\; | jq -s '.')"
  coreVersion="$(jq -r -n --argjson v "$apps" '$v | .[] | select(.artifactId == "4allportal-core") | .artifactVersion')"
  appsString="$(jq -r -n --argjson v "$apps" '$v | .[] | select(.artifactId != "4allportal-core") | "\(.artifactId):\(.artifactVersion)"' | paste -sd ,)"

  rm -rf /tmp/data
  mkdir -p /tmp/data/custom

  ssh $sshAccess -- tar -czf - -C $installationPath/custom . | tar -xzf - -C /tmp/data/custom

  eval $(echo fap $coreVersion -e APPS_INSTALL=$appsString $@ | tee /dev/stderr)

  rm -rf /tmp/data
}
function _fapClone() {
  local state
  _arguments "1: :($(< $HOME/.ssh/known_hosts | awk '{print $1}' | tr ',' '\n' | sort | uniq | xargs echo -n))" \
             "2: :->files"
  if [ "$state" = "files" ]; then
    _remote_files -/ -h root@${words[2]} -- ssh
  fi
}
compdef _fapClone fapClone

function appVs() {
  ssh -o LogLevel=QUIET root@repository.4allportal.net find /services/repository/apps/$1 -mindepth 1 -maxdepth 1 -type d -exec basename {} \\\; | rg ${2:-.} | sort -V | sed "s#^#$1:#g" | tr -d '\r'
}
function _getApps() {
  ssh -o LogLevel=QUIET root@repository.4allportal.net find /services/repository/apps -mindepth 1 -maxdepth 1 -type d -exec basename {} \\\; | sort | uniq | tr -d '\r'
}
function _appVs() {
  _arguments "1: :($(_getApps))"
}
compdef _appVs appVs

function appV() {
  echo "$1:$(ssh -o LogLevel=QUIET root@repository.4allportal.net find /services/repository/apps/$1 -mindepth 1 -maxdepth 1 -type d -exec basename {} \\\; | rg ${2:-.} | sort -V | rg -v SNAPSHOT | tail -1 | tr -d '\r')"
}
compdef _appVs appV

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
  local HR="$1"

  if [ "$HR" = "-" -o "$HR" = "" ]; then
    < /dev/stdin
  else
    < "$HR"
    [ "$?" -ne 0 ] && return 1
  fi | yq -erys '.[] | select(.kind == "HelmRelease")'
  return 0
}

function _hr_getNamespace() {
  local yaml
  yaml="$1"

  <<<"$yaml" | yq -er 'if .spec.targetNamespace then .spec.targetNamespace else .metadata.namespace end'
}

function _hr_getReleaseName() {
  local yaml
  local ns
  yaml="$1"
  ns=$(_hr_getNamespace "$yaml")

  <<<"$yaml" | yq -er "if .spec.releaseName then .spec.releaseName else \"$ns-\\(.metadata.name)\" end"
}

function hr() {
  local namespace
  local releaseName
  local yaml
  local values
  yaml=$(_hr_getYaml "$1")
  if [[ "$2" =~ -[0-9]+ ]]; then
    yaml="$(<<<"$yaml" | yq -erys ".[${2/-}]")"
    shift
  fi
  [ "$?" -ne 0 ] && retureleaseName 1
  namespace=$(_hr_getNamespace "$yaml")
  releaseName=$(_hr_getReleaseName "$yaml")
  values=$(<<< "$yaml" | yq -y -er .spec.values)
  if [ -d "$2" ]; then
    helm template --namespace $namespace $releaseName "$2" --values <(<<< "$values") ${@:3}
  elif <<< "$yaml" | yq -er .spec.chart.git > /dev/null; then
    rm -rf /tmp/helm-chart
    local gitPath
    gitPath="$(<<< "$yaml" | yq -er 'if .spec.chart.path then .spec.chart.path else "." end')"
    git clone --depth 1 --branch "$(<<< "$yaml" | yq -er 'if .spec.chart.ref then .spec.chart.ref else "master" end')" "$(<<< "$yaml" | yq -er .spec.chart.git)" /tmp/helm-chart > /dev/null

    helm dependency update "/tmp/helm-chart/$gitPath" > /dev/null
    helm template --namespace $namespace $releaseName "/tmp/helm-chart/$gitPath" --values <(<<< "$values") ${@:2}
    rm -rf /tmp/helm-chart
  else
    helm template --namespace $namespace --repo $(<<< "$yaml" | yq -er .spec.chart.repository) $releaseName $(<<< "$yaml" | yq -er .spec.chart.name) --version $(<<< "$yaml" | yq -er .spec.chart.version) --values <(<<< "$values") ${@:2}
  fi
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
  local namespace
  local releaseName
  local chartName
  local yaml
  yaml=$(_hr_getYaml "$1")
  if [[ "$2" =~ -[0-9]+ ]]; then
    yaml="$(<<<"$yaml" | yq -erys ".[${2/-}]")"
    shift
  fi
  [ "$?" -ne 0 ] && return 1
  namespace=$(_hr_getNamespace "$yaml")
  releaseName=$(_hr_getReleaseName "$yaml")
  chartName=$(<<<"$yaml" | yq -er .spec.chart.name)
  if [ -d "$2" ]; then
    helm diff --show-secrets upgrade --namespace $namespace $releaseName "$2" --values <(<<<"$yaml" | yq -y -er .spec.values) ${@:3} | grep -v helm.sh/chart | less
  else
    local repoTmpFile
    repoTmpFile=$(mktemp --suffix .yaml)
    trap "rm -f $repoTmpFile" EXIT
    <<EOF > $repoTmpFile
apiVersion: ""
generated: "0001-01-01T00:00:00Z"
repositories:
  - name: tmp
    url: "$(<<<"$yaml" | yq -er .spec.chart.repository)"
EOF
    helm --repository-config $repoTmpFile repo update
    helm --repository-config $repoTmpFile diff --show-secrets upgrade --namespace $namespace $releaseName tmp/$(<<<"$yaml" | yq -er .spec.chart.name) --version $(<<<"$yaml" | yq -er .spec.chart.version) --values <(<<<"$yaml" | yq -y -er .spec.values) ${@:2} | grep -v helm.sh/chart | less
  fi

  # helm diff upgrade --namespace $ns --repo $(yq -e .spec.chart.repository $HR) $rn $(yq -e .spec.chart.name $HR) --version $(yq -e .spec.chart.version $HR) --values <(yq -y .spec.values $HR)
}
compdef _hr hrDiff

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

  if [ ! -z $newPackages ]; then
    echo "$(wc -l <<<$newPackages) new Packages"
    while read -r package; do
      if [ $package = "linux-config" ]; then
        continue
      fi
      paru -Qi $package
      read -k 1 "choice?[A]dd, [r]emove, [d]epends or [s]kip $package? "
      echo
      case $choice in;
        [Aa])
          targetPackages="$targetPackages\\n$package"
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
  missingPackages=$(echo $targetPackages | rg -xv $(paru -Qqe | tr '\n' '|' | sed 's#|$##g'))

  if [ ! -z $missingPackages ]; then
    echo "$(wc -l <<<$missingPackages) missing Packages"
    while read -r package; do
      paru -Si $package
      paru -Qi $package
      read -k 1 "choice?[I]nstall, [r]emove, [e]xplicit or [s]kip $package? "
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
        [Ee])
          echo "=========="
          echo
          paru -D --asexplicit $package
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
  unusedPackages=$(pacman -Qi | awk '/^Name/{name=$3} /^Required By/{req=$4} /^Optional For/{opt=$0} /^Install Reason/{res=$4$5} /^$/{if (req == "None" && res != "Explicitlyinstalled"){print name}}')

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
  git add PKGBUILD .SRCINFO && git clean -xfd && updpkgsums && makepkg -f && makepkg --printsrcinfo > .SRCINFO && git commit -v . && git push && git clean -xfd
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
nAlias less slit
nAlias ps procs
reAlias fzf --ansi
reAlias prettyping --nolegend
nAlias ping prettyping
nAlias du ncdu --exclude-kernfs
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

alias -g A='| awk'
alias -g B='| base64'
alias -g BD='B -d'
alias -g C='| clip'
alias -g G='| grep'
alias -g GZ='| gzip'
alias -g GZD='GZ -d'
alias -g J='| jq'
alias -g L='| less'
alias -g S='| sed'
alias -g SP='| sponge'
alias -g T='| tee'
alias -g TD='T /dev/stderr'
alias -g X='| xargs'
alias -g Y='| yq'
nAlias wd 'while :; do .; sleep 0.1; clear; done'

function _k9s() {
  _arguments "--context[The name of the kubeconfig context to use]: :($(kubectl config get-contexts -o name | xargs echo -n))"
}
compdef _k9s k9s

nAlias krc kubectl config current-context
nAlias klc kubectl 'config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"'
nAlias kcc kubectl 'config use-context "$(klc | fzf -e | sed "s/^..//")"'
nAlias krn kubectl 'config get-contexts --no-headers "$(krc)" | awk "{print \$5}" | sed "s/^$/default/"'
nAlias kln kubectl 'get -o name ns | sed "s|^.*/|  |;\|^  $(krn)$|s/ /*/"'
nAlias kcn kubectl 'config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'

