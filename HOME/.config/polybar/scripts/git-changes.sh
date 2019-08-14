#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

cd $HOME/projects/linux-config &> /dev/null

function update() {
  untracked=$(git ls-files -o --exclude-standard | wc -l)
  unadded=$(git diff --name-only | wc -l)
  uncommitted=$(git diff --cached --name-only | wc -l)
  unpushed=$(git log --branches --not --remotes --format=%H | wc -l)

  if [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unpushed:-0} -gt 0 ]]
  then
    echo -n "%{F$color_red}"
  fi

  if [[ ${untracked:-0} -gt 0 ]]
  then
      echo -n "$untracked file$([[ ${untracked} -gt 1 ]] && echo s) untracked"
  fi

  if [[ ${unadded:-0} -gt 0 ]]
  then
      [[ ${untracked:-0} -gt 0 ]] && echo -n ', '
      echo -n "$unadded file$([[ ${unadded} -gt 1 ]] && echo s) changed"
  fi

  if [[ ${uncommitted:-0} -gt 0 ]]
  then
      [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
      echo -n "$uncommitted change$([[ ${uncommitted} -gt 1 ]] && echo s) not committed"
  fi

  if [[ ${unpushed:-0} -gt 0 ]]
  then
      [[ ${untracked:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
      echo -n "$unpushed commit$([[ ${unpushed} -gt 1 ]] && echo s) not pushed"
  fi

  if [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unpushed:-0} -gt 0 ]]
  then
    echo "%{F-}"
  fi
}

update
inotifywait -m -r -e modify -e move -e create -e delete ./ 2> /dev/null | while read -r _
do
  update
done
