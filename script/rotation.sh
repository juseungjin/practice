#!/bin/bash

# rotation.sh
# hyunseon.kim@lge.com
# v1.0

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

# define variable ( mode 0=portrait, 1=landscape )
count=4
mode=0
package="com.android.browser"
activity="com.android.browser.BrowserActivity"
component="$package""/""$activity"
extra="com.android.browser.application_id com.android.browser"
action_view="android.intent.action.VIEW"
screen_off_timeout=2147483647

unixName=$(uname -s)
linux="Linux"

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

# remount 
adb $device root || exit 1
adb $device wait-for-device
adb $device remount
adb $device wait-for-device

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

# turn off rotation setting
adb $device shell "content update --uri content://settings/system --bind value:i:0 --where name=\'accelerometer_rotation\'"

# user_rotation query
db_query=$(adb $device shell "content query --uri content://settings/system --projection name:value --where name=\'user_rotation\'" | awk -F " " '{print $1}')

echo "db query : $db_query"

if [ "$db_query" == "No" ]
then
    # insert into system user_rotation 
    adb $device shell "content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:0"
else 
    echo "$db_query"
fi

sleep 1

echo ""
echo "start test!"
echo ""

# launch browser 
#adb $device shell am start -a android.intent.action.VIEW -d 'http://www.google.com' -n com.android.browser/com.android.browser.BrowserActivity
#sleep 2

# change PC UA agent
#echo ""
#echo "change PC UA String!"
#echo ""
#adb $device shell am broadcast -a "lgeHiddedMenu.intent.action.CHANGE_UASTRING" -e uastring  "Mozilla/5.0 (X11;Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.118 Safari/537.36"
#sleep 1

# open page -> daum.net 
adb $device shell am start -a android.intent.action.VIEW -d 'http://m.daum.net' -n com.android.browser/com.android.browser.BrowserActivity
sleep 5

# Clear logcat
adb $device logcat -c

for ((i=0;i<$count;i++))do
if [ "$mode" == 0 ]
then
    # landscape
    adb $device shell "content update --uri content://settings/system --bind value:i:1 --where name=\'user_rotation\'"
    mode=1
else
    # portrait
    adb $device shell "content update --uri content://settings/system --bind value:i:0 --where name=\'user_rotation\'"
    mode=0
fi

# Print log message
echo ""
adb $device logcat -v time -d | grep --line-buffered Reconfiguring | tail -1
echo ""

sleep 1

echo ""
adb $device logcat -v time -d | grep --line-buffered completion | tail -1
echo ""

done

echo ""
#duration=$(adb $device logcat -v time -d | grep completion | awk -F " " '{print $8}' | cut -c -3 | tr '\n' ' ')
#duration=$(adb $device logcat -v time -d | grep completion | awk -F " " '{print $8}' | cut -c -3 | tee > rotation.txt)
duration=$(adb $device logcat -v time -d | grep completion | awk -F " " '{print $8}' | tr -d '\r' | tee > rotation.txt )
sed 's/ms//g' rotation.txt > test.txt

i=0
for line in `awk '{print $1}' test.txt`; do
  arr[$i]=$line
  i=`expr $i + 1`
done

echo "Rotation completion time : ${arr[*]}"


total=0
for i in "${arr[@]}"; do
    total=$(( $total+$i ))
done

# print result
echo ""
echo "total rotation time: $total (ms)"
echo ""

# Remove result file
find . -name "rotation.txt" -exec rm {} \;
find . -name "test.txt" -exec rm {} \;

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
