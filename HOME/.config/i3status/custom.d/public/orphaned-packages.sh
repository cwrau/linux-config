#!/bin/bash

set -ex -o pipefail

pgrep yay &>/dev/null && exit 1

num=$(timeout 20 bash -c "yay -Qtd  2>/dev/null | awk '{print \$1}' | wc -l")

[[ ${num:-0} -gt 0 ]] || exit 1

echo "$num Packages orphaned"
echo "$color_bad"
