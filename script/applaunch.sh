#!/bin/bash

# applaunch.sh
# seungjin.ju@lge.com
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

adb $device root || exit 1
adb $device wait-for-device

adb $device shell stop thermal-engine
adb $device shell 'echo 0 > /sys/module/msm_thermal/core_control/enabled'

show_info

if [ $unixName = $linux ]
then
    echo "Set screen_off_timeout to $screen_off_timeout"
    old_screen_off_timeout=$(adb $device shell content query --uri content://settings/system --projection value --where 'name="screen_off_timeout"' | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_off_timeout --where 'name="screen_off_timeout"'
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
sleep 1

adb $device shell am start -a $action_view -n $component -e $extra -d "http://m.daum.net"
sleep 5

#FUNCTION CONVERT DATE TYPE TO EPOCH TYPE
function convert (){

day=$1
year=$(date +%Y)
time=$year$day

epoch=$(date -d "$time" +%s.%N)

#date -d "2014-09-29 19:51:06.450" +%s.%N

echo $epoch
return
}

#START TEST
adb $device shell am force-stop com.android.browser
echo "**App Launching Time Measurement**"

#echo -n "count: "
#read count
count=10

echo "$count times running."
adb $device shell am force-stop com.android.browser

sumFistActionTime=0
sumTotalTime=0

#RUNNING USER INPUT COUNT TIMES
for ((i=0;i<$count;i++));do

adb $device logcat -c -b events
find . -name "events.txt" -exec rm {} \;

adb $device logcat -v time -b events > events.txt &
sleep 2
adb $device shell am start -a android.intent.action.VIEW -d 'http://m.daum.net' -n $component
sleep 7
adb $device shell am force-stop com.android.browser

launch_time=$(cat events.txt | grep am_activity_launch_time | grep BrowserActivity | tail -1 | awk -F " " '{print "-"$1" "$2}')
restart_time=$(cat events.txt | grep am_restart_activity | grep BrowserActivity | tail -1 | awk -F " " '{print "-"$1" "$2}')
create_time=$(cat events.txt | grep am_create_activity | grep BrowserActivity | tail -1 | awk -F " " '{print "-"$1" "$2}')

launch_time_i=$(convert "$launch_time")
restart_time_i=$(convert "$restart_time")
create_time_i=$(convert "$create_time")

launch_time_c=$(echo $launch_time_i | sed 's/\.//g' | sed 's/000000$//g')
restart_time_c=$(echo $restart_time_i | sed 's/\.//g' | sed 's/000000$//g')
create_time_c=$(echo $create_time_i | sed 's/\.//g' | sed 's/000000$//g')

firstActionTime=$(($restart_time_c-$create_time_c))
totalTime=$(($launch_time_c-$create_time_c))

echo "first action time = $firstActionTime" ms
echo "total time = $totalTime" ms
echo 

sumFistActionTime=$(($sumFistActionTime+$firstActionTime))
sumTotalTime=$(($sumTotalTime+$totalTime))

done

adb $device shell 'echo 1 > /sys/module/msm_thermal/core_control/enabled'
adb $device shell start thermal-engine

avgFirstActionTime=$(($sumFistActionTime/$count))
avgTotalTime=$(($sumTotalTime/$count))

if [ $unixName = $linux ]
then
    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where 'name="screen_off_timeout"'
else
    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where \"name=\'screen_off_timeout\'\"
fi

echo 
echo "avg FirstAction Time = $avgFirstActionTime" ms " avg Total Time = $avgTotalTime" ms


