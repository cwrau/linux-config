#!/bin/bash

# shellcheck source=/dev/null
source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

name=${1}
text=${2}

case $(systemctl --user is-active "${name}") in
  active)
    # shellcheck disable=SC2154
    echo "%{F$color_green}${text}%{F-}"
    ;;

  inactive)
    # shellcheck disable=SC2154
    echo "%{F$color_orange}${text}%{F-}"
    ;;

  failed)
    # shellcheck disable=SC2154
    echo "%{F$color_red}${text}%{F-}"
    ;;
esac

