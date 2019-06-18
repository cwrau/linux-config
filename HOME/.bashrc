pgrep i3lock &>/dev/null && unlock

case "$-" in
  *i*)
    GIT_PROMPT_THEME=Default_NoExitState
    if command -v kubectl &> /dev/null
    then
      function _kubecontext() {
        local ctx
	ctx="$(kubectl config current-context 2>/dev/null)"
        if [[ "$?" == "0" ]]
        then
          echo " ⎈ ${ctx} ⎈ "
        fi
      }
      GIT_PROMPT_START='\n[ \u@\h ]$(_kubecontext)'
    else
      GIT_PROMPT_START='\n[ \u@\h ]'
    fi
    GIT_PROMPT_END='\n\e[38;2;133;153;0m$PWD\e[0m\nλ '

    PROMPT_COMMAND='history -a'
    PS1="$GIT_PROMPT_START$GIT_PROMPT_END"

    GIT_PROMPT_ONLY_IN_REPO=1

    HISTCONTROL=ignoredups
    HISTTIMEFORMAT='%F %T%z '

    shopt -s histappend
    shopt -s cmdhist

    shopt -s checkwinsize

    shopt -s autocd 2> /dev/null
    shopt -s dirspell 2> /dev/null
    shopt -s cdspell 2> /dev/null

    bind Space:magic-space

    bind "set completion-ignore-case on"
    bind "set completion-map-case on"
    bind "set show-all-if-ambiguous on"
    bind "set mark-symlinked-directories on"

    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind '"\e[C": forward-char'
    bind '"\e[D": backward-char'
    ;;
esac

if [ "$(hostname)" = 'cwr' ]
then
  if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]]
  then
    exec startx
  fi

  function command_not_found_handle {
    echo "Command '$1' not found, but could be installed via the following packages:"
    yay -Fysq -- $1
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

  HISTSIZE=-1
  HISTFILESIZE=-1

  #export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  #gpgconf --launch gpg-agent
else
  [ -f ${HOME}/.bashrc ] && source ${HOME}/.bashrc
  if [ -f /tmp/cwr.bashrc ]
  then
    if [ "${KEEP_RC}" != "true" ]
    then
      function cleanup() {
        rm -f /tmp/cwr.bashrc
      }

      trap cleanup EXIT

      export KEEP_RC=true
    fi
    alias bash="bash --rcfile /tmp/cwr.bashrc -i"
  fi

  lastlog -u $USER | perl -lane 'END{print "Last login: @F[3..6] $F[8] from $F[2]"}'
fi

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

[ -f /etc/motd ] && cat /etc/motd

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

alias env='env | sort'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -phAbl --color=auto --time-style=long-iso'
alias vim='vim -b'
if [[ "$(id -u)" != 0 ]] && command -v sudo &> /dev/null
then
  command -v apt &> /dev/null && alias apt='sudo apt'
  command -v apt-get &> /dev/null && alias apt-get='sudo apt-get'
  command -v systemctl &> /dev/null && alias systemctl='sudo systemctl'
  command -v pacman &> /dev/null && alias pacman='sudo pacman'
fi
alias top="htop"
alias vi='vim'
command -v bat &> /dev/null && alias cat='bat'
command -v slit &> /dev/null && alias less='slit'
command -v prettyping &> /dev/null && alias ping='prettyping --nolegend'
command -v ncdu &> /dev/null && alias du="ncdu"
command -v tldr &> /dev/null && alias man='tldr'
command -v rg &> /dev/null && alias rg='rg -S'


function memU() {
    ps -ax -o rss | awk '{a += $1} END{print (a/1024/1024)/'"$(free -h | grep Mem | awk '{print $2}' | sed -r 's#[^0-9]##g')"*100'}'
}

function mem() {
    ps -ax -o rss,command | awk '{print $1/1024 "\t" $2}' | grep -v '\[' | awk '{a[$2] += $1} END{for (i in a) { b=a[i]; if (b > 512) { if (b > 1024) { b=b/1024 "GiB" } else { b=b "MiB" } print b "\t" i } } }' | sort -h
}

if command -v docker &> /dev/null && [[ -x $(which docker) ]]
then
  function jflint() {
    if [[ $# = 0 ]]
    then
      if [[ -f Jenkinsfile ]]
      then
        file=Jenkinsfile
      else
        echo "No argument given and default 'Jenkinsfile' doesn't exist"
        return 1
      fi
    elif [[ $# = 1 ]]
    then
      if [[ -f "$1" ]]
      then
        file="$1"
      else
        echo "File '$1' doesn't exist"
        return 1
      fi
    else
      echo "Too many arguments"
      return 1
    fi

    docker-run --network host -v "$(realpath "$file")":/Jenkinsfile registry.4allportal.net/jflint --csrf-disabled -j https://jenkins.4allportal.net /Jenkinsfile
  }

  function docker-run() {
    docker run --rm -it "$@"
  }

  function docker-here() {
    docker-run -v "$PWD:$PWD" -w "$PWD" -u `id --user`:`id --group` "$@"
  }

  function ctop() {
    docker-run --name ctop -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop
  }

  command -v gotop &>/dev/null && alias htop="gotop"
  command -v gotop &>/dev/null && alias gotop="gotop -r 4"
fi

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

function gitUpdate() {
  if command -v git &> /dev/null && (timeout 0.5 ping -c 1 google.com &> /dev/null)
  then
    pushd "$1" > /dev/null
    [ -f .git/FETCH_HEAD ] || (popd > /dev/null; return 0)
    if (( ($(date +%s) - $(stat -c %Y .git/FETCH_HEAD)) > 86400 ))
    then
      git reset --hard &> /dev/null
      git clean -d -x -f &> /dev/null
      git pull &> /dev/null
    fi
    popd > /dev/null
  fi
}

if [ -d ~/.vim_runtime ] #https://github.com/amix/vimrc
then
  gitUpdate ~/.vim_runtime
  ~/.vim_runtime/install_awesome_vimrc.sh &> /dev/null
fi

if [ -f /usr/lib/bash-git-prompt/gitprompt.sh ] #https://github.com/magicmonty/bash-git-prompt
then
  . /usr/lib/bash-git-prompt/gitprompt.sh
fi

if [ -r /etc/bash_completion ] ||
   [ -r /etc/profile.d/bash_completion.sh ] ||
   [ -r /usr/share/bash-completion/bash_completion ]
then
  [ -f /etc/bash_completion ] && source /etc/bash_completion
  [ -f /etc/profile.d/bash_completion.sh ] && source /etc/profile.d/bash_completion.sh
  [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
  if command -v kubectl &> /dev/null
  then
    source <(kubectl completion bash)
    if [ -d $HOME/.krew/bin ]
    then
      alias kubectl="PATH=\"$PATH:$HOME/.krew/bin\" kubectl"
    fi
    if command -v fzf &> /dev/null
    then
      # Get current context
      alias krc='kubectl config current-context'
      # List all contexts
      alias klc='kubectl config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"'
      # Change current context
      alias kcc='kubectl config use-context "$(klc | fzf -e | sed "s/^..//")"'
      
      # Get current namespace
      alias krn='kubectl config get-contexts --no-headers "$(krc)" | awk "{print \$5}" | sed "s/^$/default/"'
      # List all namespaces
      alias kln='kubectl get -o name ns | sed "s|^.*/|  |;\|$(krn)|s/ /*/"'
      # Change current namespace
      alias kcn='kubectl config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'
    fi
  fi
  command -v kubeadm &> /dev/null && source <(kubeadm completion bash)
  command -v helm &> /dev/null && source <(helm completion bash)
fi
export VISUAL=vim
export EDITOR="$VISUAL"
[ -d /usr/local/bin/custom ] && PATH="$PATH:/usr/local/bin/custom"
