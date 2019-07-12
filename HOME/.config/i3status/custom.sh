#!/bin/bash

set -x -o pipefail

tmp=/tmp/i3status
base=$HOME/.config/i3status/custom.d/

rm -rf ${tmp}
mkdir -p ${tmp}

source <(
  cat ~/.config/i3status/config | grep color_ | while read line
  do
    key=$(echo ${line} | sed -r 's#^([^ ]+) = .+$#\1#g')
    value=$(echo ${line} | sed -r 's#^.+"([^ ]+)"$#\1#g')
    echo "export $key=$value"
  done
)

(
  i3status | (
    read line && echo "${line/\}/,\"click_events\":true\}}" && read line && echo "$line" && read line && echo "$line" &&
    while read line
    do
      line="${line#[}"
      line="${line#,[}"
      i3Out=",["

      for s in $(fd -E '*_action*' -E '*_click*' -e sh -t x --search-path $base | sort -n --field-separator=/ -k 8)
      do
        name=$(basename -- "$s" .sh | sed -r 's#^[0-9]*_?([^_]+)_?-?[0-9]*$#\1#g')
        interval=$(echo $(basename -- "$s" .sh) | sed -rn 's#^.+_(-?[0-9]+)$#\1#gp')
        currTmp=${tmp}/${name}
        mkdir -p ${currTmp}

        if [[ -L ${currTmp}/lastExecute ]]
        then
          last=$(readlink ${currTmp}/lastExecute)
        else
          last=0
        fi

        if ( [[ ${interval:-0} == -1 ]] && [[ ${last} == -1  ]] ) ||
            ( [[ ${interval:-0} == -2 ]] && ! [[ -f ${currTmp}/out ]] ) ||
            ( [[ ${interval:-0} -ge 0 ]] && [[ $(($(date +%s) - $last)) -ge ${interval:-0} ]] )
        then
          (
            mkdir ${currTmp}/lock &>/dev/null || exit

            start=$(date +%s%N)
            out=$(tmp=${currTmp} ${s} 2>${currTmp}/stderr.tmp)
            exitCode=$?
            end=$(date +%s%N)

            if [[ "$exitCode" = "0" ]]
            then
              echo "$out" >${currTmp}/out
              time=$(( ( $end - $start ) / 1000000 ))
              ln -sf ${time} ${currTmp}/time
              mv ${currTmp}/stderr.tmp ${currTmp}/stderr
            fi

            notification="$(echo "$out" | sed '3q;d')"
            notificationOptions="$(echo "$out" | sed '4q;d')"

            oldNotification="$(cat ${currTmp}/notification || echo "")"

            if [[ ! ${notification} = "${oldNotification}" ]] && ! pgrep i3lock &> /dev/null
            then
              action=
              [[ ! -z ${notification} ]] && action=$(dunstify "i3status: $name" ${notificationOptions} "${notification}")
              echo "${notification}" > ${currTmp}/notification
            fi

            echo $action >> /tmp/kuchen

            if [[ ! -z $action ]]
            then
              actionScript="${name}_action_${action}.sh"

              if [[ -x ${base}/public/${actionScript} ]]
              then
                ${base}/public/${actionScript} &
              elif [[ -x ${base}/private/${actionScript} ]]
              then
                ${base}/private/${actionScript} &
              else
                echo "${actionScript}" | tee -a ${tmp}/actions >&2
              fi
            fi

            rmdir ${currTmp}/lock &>/dev/null
          ) &

          ln -sf $(date +%s) ${currTmp}/lastExecute
        fi

        [[ -f ${currTmp}/out ]] || continue

        out=$(cat ${currTmp}/out)
        [[ -z "$out" ]] && continue

        text="$(echo "$out" | sed '1q;d')"
        color="$(echo "$out" | sed '2q;d')"

        i3Out="${i3Out}{\"name\":\"$name\",\"full_text\":\"$text\",\"color\":\"$color\"},"
      done

      i3Out="${i3Out}${line}"

      echo "$i3Out" | sed -r 's#\[,#\[#g; s#,,#,#g; s#},\[#},#g; s#\[,#\[#g; s#\[\[#\[#g; s#,,#,#g'
    done
  )
) &

while read line; do
  line=$(echo ${line} | sed -r 's#^,##g')
  name=$(echo ${line} | jq -r .name)
  button=$(echo ${line} | jq -r .button)

  clickScript="${name}_click_${button}.sh"

  if [[ -x ${base}/public/${clickScript} ]]
  then
    (
      ${base}/public/${clickScript} ${line}
      pkill i3status --signal USR1
    ) &
  elif [[ -x ${base}/private/${clickScript} ]]
  then
    (
      ${base}/private/${clickScript} ${line}
      pkill i3status --signal USR1
    ) &
  else
    echo "${line}" | tee -a ${tmp}/clicks >&2
  fi
done

wait
