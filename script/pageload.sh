#!/bin/bash

# pageload.sh
# saejoon.chung@lge.com
# v1.0

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

package="com.android.browser"
activity="com.android.browser.BrowserActivity"
component="$package""/""$activity"
extra="com.android.browser.application_id com.android.browser"
action_view="android.intent.action.VIEW"

unixName=$(uname -s)
linux="Linux"

screen_off_timeout=2147483647

url="http://m.daum.net"
count=14
excluded_percent=20

function usage()
{
  echo "Usage: `basename $0` [-s <device>] [-u <url>] [-c <count>] [-e <percent>] [-h]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -u <url>          set <url> to test url"
  echo "  -c <count>        set <count> to repeat count"
  echo "  -e <percent>      exclude numbers that are in <percent> of higher and lower results"
  echo "  -h                help"
}

while getopts ":u:c:s:e:h" opt; do
  case $opt in
    u)
      url="$OPTARG"
      ;;
    c)
      count=$OPTARG
      ;;
    s)
      device="-s $OPTARG"
      ;;
    e)
      excluded_percent="$OPTARG"
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

function get_prop()
{
  local prop="$1"
  adb $device shell getprop | grep "\[$prop\]" | sed 's/.*: //g' | tr -d '[]'
}

function show_info()
{
  echo
  echo "Date: $(date +"%Y-%m-%d %H:%M:%S")"
  echo "Product: $(get_prop 'ro.product.name')"
  echo "Build: $(get_prop 'ro.build.type')"
  echo "Version: $(get_prop 'ro.lge.swversion')"
  echo "Factory: $(get_prop 'ro.lge.factoryversion')"
  echo
}

echo "--------------------------------------"
echo "`basename $0`"
echo "--------------------------------------"

echo "url=$url"
echo "count=$count"
echo "excluded_percent=$excluded_percent%"
echo

adb $device root || exit 1
adb $device wait-for-device

show_info

if [ $unixName = $linux ]
then
    echo "Set screen_off_timeout to $screen_off_timeout"
    old_screen_off_timeout=$(adb $device shell content query --uri content://settings/system --projection value --where "name='screen_off_timeout'" | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_off_timeout --where "name='screen_off_timeout'"
else
    echo "Set screen_off_timeout to $screen_off_timeout"
    old_screen_off_timeout=$(adb $device shell content query --uri content://settings/system --projection value --where \"name=\'screen_off_timeout\'\" | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_off_timeout --where \"name=\'screen_off_timeout\'\"
fi

echo "Initialize $package"
adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'` > /dev/null
sleep 1
adb $device logcat -b events -c
adb $device shell am start -a $action_view -n $component -e $extra -d "about:blank"
sleep 3
adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'`
sleep 5

echo "Go home screen"
adb $device shell "input keyevent 3"
sleep 3

echo "Starting $package"
adb $device shell am start -a android.intent.action.VIEW -d 'about:blank' -n $component -e $extra
adb $device shell am start -a android.intent.action.VIEW -d $url -n $component -e $extra
sleep 10

echo
declare -A time=()
for((i=0; i<$count; i++)); do
    echo "Loop $((i+1)) of $count"
    echo "Clearing cache"
    adb $device logcat -c
    adb $device shell am broadcast -a "com.lge.browser.CLEAR_CACHE"
    adb $device logcat -v time -d | grep "CLEAR_CACHE"
    sleep 5
    echo "Loading $url"
    adb $device logcat -b events -c
    adb $device shell am start -a android.intent.action.VIEW -d $url -n $component -e $extra
    sleep 3
    output=$(adb $device logcat -v time -b events -d | grep browser_page_loaded | tr -d '\r' | tail -1)
    echo $output
    IFS='|' read -ra results <<< "$output"
    time[$i]=${results[1]}
    echo "Results: ${time[$i]} (ms)"
    echo
    sleep 3
done


if [ $unixName = $linux ]
then
    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where "name='screen_off_timeout'"
else
    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where \"name=\'screen_off_timeout\'\"
fi

echo
echo "PageLoad Results (Raw)"
echo
results_count=1
for i in "${time[@]}"; do
    echo "PageLoad Results $results_count/$count: $i"
    ((results_count++))
done

echo
echo "PageLoad Results (Exclude $excluded_percent% of upper and lower)"
echo
readarray -t sorted < <(for i in "${time[@]}"; do echo $i; done | sort --numeric-sort)
excluded_count=$(($count*$excluded_percent/100))
lower_index=$(($excluded_count-1))
upper_index=$(($count-$excluded_count))
#echo "excluded_count=$excluded_count"
#echo "lower_index=$lower_index"
#echo "upper_index=$upper_index"

index=0
total=0
results_count=1
for i in ${sorted[@]}; do
    echo -n "PageLoad Results $results_count/$count: $i"
    if [ "$index" -gt "$lower_index" ] && [ "$index" -lt "$upper_index" ]; then
        total=$((total+i))
        echo
    else
        echo " (excluded)"
    fi
    ((index++))
    ((results_count++))
done

#echo "total=$total"
valid_count=$((${#sorted[@]}-($excluded_count*2)))
#echo "valid_count=$valid_count"
avg=$(($total/$valid_count))
echo
echo "PageLoad Results Avg: $avg (ms)"
