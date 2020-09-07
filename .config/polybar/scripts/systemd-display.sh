#!/bin/bash

eval $(cat $XDG_CONFIG_HOME/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

name=${1}
text=${2}

case $(systemctl --user is-active "${name}") in
  active)
    echo "%{F$color_green}${text}%{F-}"
    ;;

  inactive)
    echo "%{F$color_orange}${text}%{F-}"
    ;;

  failed)
    echo "%{F$color_red}${text}%{F-}"
    ;;
esac

