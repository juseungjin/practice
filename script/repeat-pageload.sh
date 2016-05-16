#!/bin/bash

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

count=24
break_time_sec=3600
power_key=26

function usage()
{
  echo "Usage: `basename $0` [-s <device>] [-h]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -h                help"
}

while getopts ":s:h" opt; do
  case $opt in
    s)
      device="-s $OPTARG"
      ;;
    h)
      usage
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument"
      usage
      exit 1
      ;;
  esac
done

function unlock_screen()
{
  screen_w=$(adb $device shell dumpsys display | grep "mDefaultViewport" | sed 's/.*deviceWidth=//g' | awk -F[,] '{print $1}')
  screen_h=$(adb $device shell dumpsys display | grep "mDefaultViewport" | sed 's/.*deviceHeight=//g' | awk -F[}] '{print $1}')
  start_x=$((screen_w/2))
  start_y=$((screen_h-1))
  end_x=$start_x
  end_y=$((screen_h/2))
  adb $device shell input swipe $start_x $start_y $end_x $end_y
}

function break_time()
{
  echo "Break time for $break_time_sec (sec)"
  adb $device shell input keyevent $power_key
  sleep $break_time_sec
  adb $device shell input keyevent $power_key
  unlock_screen
}

for((i=0;i<$count;i++)); do
  echo
  echo "Test $((i+1)) of $count"
  echo "`date -R`"
  echo
  time ./pageload.sh -c 30 $device
  break_time
done
