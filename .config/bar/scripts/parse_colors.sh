#!/usr/bin/env bash

eval "$(grep -E '^[a-z0-9-]+ = #[0-9a-fA-F]+$' "$XDG_CONFIG_HOME/polybar/colors.ini" | sed -r 's#^#color_#g; s#-#_#g; s# ##g')"
