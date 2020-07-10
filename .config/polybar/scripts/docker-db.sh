#!/bin/bash

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

case $(systemctl --user is-active docker-db) in
  active)
    echo "%{F$color_green}%{F-}"
    ;;

  inactive)
    echo "%{F$color_orange}%{F-}"
    ;;

  failed)
    echo "%{F$color_red}%{F-}"
    ;;
esac

