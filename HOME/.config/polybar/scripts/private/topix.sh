#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/topix
mkdir -p $DIR

function toggle() {
  if run
  then
    echo "%{F$color_red}Topix%{F-}"
    RUN=false
    touch $DIR/PAUSE
  else
    readCache
    RUN=true
    rm -f $DIR/PAUSE
  fi
}

trap toggle USR1

function run() {
  [[ "$RUN" == "true" ]]
}

function interval() {
  [[ $(( $(date +%s) % $1 )) == 0 ]]
}

function readCache() {
  if [[ -e $DIR/out ]]
  then
    cat $DIR/out
  fi
}

fullDay=$(( 8 * 60 * 60 ))
maxDay=$(( 10 * 60 * 60 ))

function update() {
  readCache

  key=$(curl --silent -q 'http://topixsrv.cm.dom:8081/4DACTION/WEB_Login' --data 'P_textfieldUserName=c.rau&P_textfieldPassword=CRA1200' | rg main | sed -r 's#^.+web1_vtSid=([^ ]+)".+$#\1#g')
  html=$(curl --silent -q "http://topixsrv.cm.dom:8081/4DACTION/WEB_Zeiterfassung?web1_vtSid=$key")
  state=$(echo "$html" | pup '#timestamps > tbody > tr:last-child > td:nth-child(2) text{}')
  time=$(echo "$html" | pup '#salden > tbody > tr:nth-child(1) > td:nth-child(6) text{}' | cut -c -8)
  curl --silent -q "http://topixsrv.cm.dom:8081/4DACTION/WEB_Logout/$key" &>/dev/null

  topixLine="$time Hours ($state)"
  hour=$(( 10#$(echo ${time} | cut -d : -f 1) ))
  minute=$(( 10#$(echo ${time} | cut -d : -f 2) ))
  second=$(( 10#$(echo ${time} | cut -d : -f 3) ))
  seconds=$(( $hour * 60 * 60 + $minute * 60 + $second ))

  if [[ ${state} != "Gehen" ]]
  then
    if [[ $seconds -ge $fullDay ]]
    then
      topixLine="%{F$color_green}$topixLine"
      notification="Go Home!"
      notification_options="-t 3600000"
    elif [[ $seconds -ge $maxDay ]]
    then
      topixLine="%{F$color_red}$topixLine"
      color="$color_good"
      notification="You can go Home"
    else
      topixLine="%{F$color_yellow}$topixLine"
      color="$color_degraded"
      notification=""
    fi
  fi

  if [[ ${#state} -gt 15 ]]
  then
    rm -f ${tmp}/notification
  else
    echo "$topixLine%{F-}" | tee $DIR/out
    # echo "$color"
    # if [[ ! -z ${notification} ]]
    # then
    #   echo ${notification}
    #   [[ ! -z ${notification_options} ]] && echo ${notification_options}
    #   echo "-u critical"
    # fi
  fi
}

RUN=true

while true
do
  RUN=$([ -e $DIR/PAUSE ] && echo false || echo $RUN )
  run || echo "%{F$color_red}Topix%{F-}"
  
  if run && interval 60
  then
    if timeout 0.4 ping -c 1 topixsrv.cm.dom &>/dev/null
    then
      until mkdir $DIR/LOCK &> /dev/null
      do
        USECACHE=true
        sleep 1
      done

      if [[ "$USECACHE" == "true" ]]
      then
        readCache
        USECACHE=false
      else
        update
      fi
      
      rmdir $DIR/LOCK || true &> /dev/null
    else
      echo
    fi
  fi
  sleep 1
done
