#!/bin/bash

set -ex -o pipefail

unadded=$(cd $HOME/projects/linux-config &> /dev/null && git diff --name-only | wc -l)
uncommitted=$(cd $HOME/projects/linux-config &> /dev/null && git diff --cached --name-only | wc -l)
unpushed=$(cd $HOME/projects/linux-config &> /dev/null && git log --branches --not --remotes --format=%H | wc -l)

if [[ ${unadded:-0} -gt 0 ]]
then
    echo -n "$unadded file$([[ ${unadded:-0} -gt 1 ]] && echo s) changed"
fi

if [[ ${uncommitted:-0} -gt 0 ]]
then
    [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
    echo -n "$uncommitted change$([[ ${uncommitted:-0} -gt 1 ]] && echo s) not committed"
fi

if [[ ${unpushed:-0} -gt 0 ]]
then
    [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
    echo -n "$unpushed commit$([[ ${unpushed:-0} -gt 1 ]] && echo s) not pushed"
fi

if [[ ${unadded:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unpushed:-0} -gt 0 ]]
then
  echo
  echo "$color_bad"
fi
