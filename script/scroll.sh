#!/bin/bash

# scroll.sh
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
  echo "Usage: `basename $0` [-s <device>] [-d] [-f] [-h]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -d                test for drag"
  echo "  -f                test for flick"
  echo "  -h                help"
}

while getopts ":s:dfh" opt; do
  case $opt in
    d)
      input=1
      type="drag_fps"
      ;;
    f)
      input=2
      type="flick_fps"
      ;;
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

resolution=$(adb $device shell dumpsys display | grep PhysicalDisplayInfo | sed 's/\,//g' |awk -F " " '{print $3}')

#echo resolution: $resolution

adb $device shell mkdir data/data/com.android.browser/config/
adb $device shell 'echo '\''chrome --enable-fps-log '\'' > /data/data/com.android.browser/config/swe-command-line'
adb $device shell 'echo '\''chrome --enable-fps-log '\'' > /data/local/tmp/swe-command-line'


adb $device shell am start -a $action_view -n $component -e $extra -d "http://m.daum.net"
sleep 5

# Remove result file
find . -name "log.txt" -exec rm {} \;
find . -name "fps.txt" -exec rm {} \;
find . -name "stdev.txt" -exec rm {} \;

adb $device shell setprop debug.fpslog.enable 1

sleep 1

# adb $device shell getprop debug.fpslog.enable

if [ "$input" == "" ]; then
  echo "1. Drag"
  echo "2. Flick"

  while [ 1 ]
  do
    echo -n "Input type: "
    read input

    if [ $input -eq 1 ]
    then
        type="drag_fps"
        break
    elif [ $input -eq 2 ]
    then
        type="flick_fps"
        break
    else
        echo "retry"
        continue
    fi
  done
fi

echo "your input : $type"

adb $device logcat -c

#adb $device logcat | grep $type | tee > fps.txt &
adb $device logcat > log.txt &

echo "monkeyrunner start"


unixName=$(uname -s)
linux="Linux"

if [ $unixName = $linux ]
then
    command="./monkeyrunner"
else
    command="./monkeyrunner.bat"
fi

if [ $input -eq 1 ]
then
if [ $resolution -ge 2560 ]
then
    #./monkeyrunner drag/drag_2560.py
    file_name="drag/drag_2560.py"
elif [ $resolution -ge 1920 ]
then
    #./monkeyrunner drag/drag_1920.py
    file_name="drag/drag_1920.py"
elif [ $resolution -ge 1280 ]
then
    #./monkeyrunner drag/drag_1280.py
    file_name="drag/drag_1280.py"
elif [ $resolution -ge 800 ]
then
    #./monkeyrunner drag/drag_800.py
    file_name="drag/drag_800.py"
elif [ $resolution -ge 480 ]
then
    #./monkeyrunner drag/drag_480.py
    file_name="drag/drag_480.py"
fi
elif [ $input -eq 2 ]
then
if [ $resolution -ge 2560 ]
then
    #./monkeyrunner flick/flick_2560.py
    file_name="flick/flick_2560.py"
elif [ $resolution -ge 1920 ]
then
    #./monkeyrunner flick/flick_1920.py
    file_name="flick/flick_1920.py"
elif [ $resolution -ge 1280 ]
then
    #./monkeyrunner flick/flick_1280.py
    file_name="flick/flick_1280.py"
elif [ $resolution -ge 800 ]
then
    #./monkeyrunner flick/flick_800.py
    file_name="flick/flick_800.py"
elif [ $resolution -ge 480 ]
then
    #./monkeyrunner flick/flick_480.py
    file_name="flick/flick_480.py"
fi
fi
IFS=' ' read -ra ARG <<< $device
num_of_args=${#ARG[@]}
if [ $num_of_args > 1 ]
then
    eval $command $file_name ${ARG[1]}
else
    eval $command $file_name
fi

if [ $input -eq 1 ]
then
    grep drag_fps log.txt > fps.txt
    grep stdev log.txt > stdev.txt
elif [ $input -eq 2 ]
then
    grep flick_fps log.txt > fps.txt
fi

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

# print reslut
echo "Result"
cat fps.txt
cat fps.txt | grep fps | awk -F " " 'BEGIN{TOTAL=0;COUNT=0}{if($5==null){TOTAL+=$4;}else{TOTAL+=$5;}COUNT+=1.0}END{printf"\nfps avg : %.1f fps\n", TOTAL/COUNT}'
if [ $input -eq 1 ]
then
    cat stdev.txt
    cat stdev.txt | grep stdev | awk -F " " 'BEGIN{TOTAL=0;COUNT=0}{if($5==null){TOTAL+=$4;}else{TOTAL+=$5;}COUNT+=1.0}END{printf"drag stdev : %.1f mm/s\n", TOTAL/COUNT}'
fi

adb $device shell rm /data/data/com.android.browser/config/swe-command-line
adb $device shell rm /data/local/tmp/swe-command-line
# kill grep process
#ps -ef | grep tee | awk '{print "kill -9",$2}' | sh -vaa

