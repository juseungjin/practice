#!/bin/bash

# testall.sh
# saejoon.chung@lge.com
# v1.0

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

test_script_list=("rotation.sh" "mem.sh" "applaunch.sh" "scroll.sh" "bench.sh" )
break_time_sec=300
power_key=26

perf_mode=0

function usage()
{
  echo "Usage: `basename $0` [-s <device>] [-p] [-t <hour>] [-h]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -p                add performance mode test for benchmark"
  echo "  -t                start test at <hour> (00~23)"
  echo "  -h                help"
}

while getopts ":s:pt:h" opt; do
  case $opt in
    s)
      device="-s $OPTARG"
      ;;
    p)
      perf_mode=1
      ;;
    t)
      test_start_time="$OPTARG"
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

function print_title()
{
  title="[$1]"
  title_len=${#title}
  echo
  echo -n "$title"
  for((i=0; i<$((80-title_len)); i++)); do
    echo -n "-"
  done
  echo
  echo
}

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
  #echo "break_time arg1=$1"
  local sleep_time_sec=$break_time_sec
  if [ -n "$1" ]; then
    sleep_time_sec=$1
  fi
  echo "Break time for $sleep_time_sec (sec)"
  adb $device shell input keyevent $power_key
  sleep $sleep_time_sec
  adb $device shell input keyevent $power_key
  unlock_screen
}

function vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

print_title "`basename $0`"

if [ -n "$test_start_time" ]; then
  echo "Test will be started at $test_start_time o'clock"
  while [ "`date +%H`" != "$test_start_time" ]; do
    sleep 60
  done
fi

android_version=$(adb $device shell getprop ro.build.version.release | tr -d '\r')
#echo "android_version=$android_version"
vercomp "$android_version" "5.0"
if [ $? == 2 ]; then
  #echo "$android_version < 5.0"
  screen_state=$(adb $device shell dumpsys power | grep 'mScreenOn=' | grep -oE '(true|false)')
  #echo "screen_state=$screen_state"
else
  #echo "$android_version >= 5.0"
  screen_state=$(adb $device shell dumpsys power | grep 'Display Power' | grep -oE '(ON|OFF)')
  #echo "screen_state=$screen_state"
fi
if [ $screen_state == "true" ] || [ $screen_state == "ON" ]; then
  adb $device shell input keyevent $power_key
  sleep 1
fi
adb $device shell input keyevent $power_key
sleep 1
unlock_screen

for test_script in "${test_script_list[@]}"; do
  start_time=$(date +%s)
  echo "START pageload.sh"
  #echo "start_time=$start_time"
  time ./pageload.sh $device
  echo "END pageload.sh"
  echo "START $test_script"
  if [ "$test_script" == "mem.sh" ]; then
    for((i=0; i<10; i++)); do
      time ./$test_script $device
    done
  elif [ "$test_script" == "rotation.sh" ]; then
    for((i=0; i<10; i++)); do
      time ./$test_script $device
    done
  elif [ "$test_script" == "scroll.sh" ]; then
    time ./$test_script $device -d
    break_time
    time ./$test_script $device -f
  elif [ "$test_script" == "bench.sh" ]; then
    time ./$test_script $device
    if [ $perf_mode -eq 1 ]; then
      break_time
      time ./$test_script $device -p
    fi
  else
    time ./$test_script $device
  fi
  echo "END $test_script"
  end_time=$(date +%s)
  #echo "end_time=$end_time"
  elapsed_time=$((end_time - start_time))
  #echo "elapsed_time=$elapsed_time"
  time_sec=$((3600 - elapsed_time))
  #echo "time_sec=$time_sec"
  break_time $time_sec
done

readarray -t pageload_results < <(cat `basename $0`.log | grep "PageLoad Avg" | awk '{print $3}')
pageload_total=0
echo "Pageload Final Results"
for i in ${pageload_results[@]}; do
  echo "$i"
  pageload_total=$((total+i))
done
pageload_count=${#pageload_results[@]}
pageload_avg=$((pageload_total / pageload_count))
echo "Pageload Final Avg: $pageload_avg (ms)"
