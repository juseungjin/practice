#!/bin/bash

# mem.sh
# hyunseon.kim@lge.com
# v1.0

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

package="com.android.browser"
activity="com.android.browser.BrowserActivity"
component="$package""/""$activity"
extra="com.android.browser.application_id com.android.browser"
action_view="android.intent.action.VIEW"
screen_off_timeout=2147483647

unixName=$(uname -s)
linux="Linux"

tab_num=8
process_name="com.android.browser"

function usage()
{
  echo "Usage: `basename $0` [-s <device>] [-p <package>] [-t <tab num>] [-h]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -p <package>      <package> for test"
  echo "  -t <tab num>      number of new tabs"
  echo "  -h                help"
}

while getopts ":s:p:t:h" opt; do
  case $opt in
    s)
      device="-s $OPTARG"
      ;;
    p)
      process_name="$OPTARG"
      ;;
    t)
      tab_num=$OPTARG
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

# Initiazlie ...
#if [ $# -eq 3 ]
#then
    # Use user input
#    device_name=$1
#    process_name=$2
#    tab_num=$3
#else
    # Use default value
    #device_name=$(adb devices | grep -w device | awk '{print $1}')
    #device_name=$(echo $device_name | awk '{print $1}') # select first device

#    if [ $# -eq 2 ]
#    then
#        process_name=$1
#        tab_num=$2
#    else
#        process_name=$1
#        tab_num=8
#    fi
#fi

# Print testing information
#echo "[Device   ] $device_name"
#echo "[Process  ] $process_name"
#echo "[Iteration] $process_iteration"

# Remove result file
find . -name "result.txt" -exec rm {} \;

# Remove Browser windows & Kill Browser App
#p_id=$(adb -s $device_name shell ps | grep $process_name | awk '{print $2}')
#echo "p_id: $p_id"  
#adb shell kill $p_id

#adb shell am kill all $process_name
#adb shell am kill-all
#adb shell am force-stop $process_name
#sleep 3

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

# test URL
#declare -a test_url
test_url[0]='http://www.google.com'
test_url[1]='http://www.facebook.com'
test_url[2]='http://www.amazon.com'
test_url[3]='http://www.yahoo.com'
test_url[4]='http://m.naver.com'
test_url[5]='http://m.daum.net'
test_url[6]='http://m.nate.com'
test_url[7]='http://www.auction.co.kr'

# Find existing processes
process_query=$(adb $device shell ps | grep $process_name)
#echo "process_query: $process_query"

if [ "$process_query" != "" ]
then
    if [ $process_name == "com.android.browser" ]; then
        echo "Initialize $package"
        adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'` > /dev/null
        sleep 1
        adb $device logcat -b events -c
        adb $device shell am start -a $action_view -n $component -e $extra -d "about:blank"
        sleep 3
        adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'`
        sleep 1
    fi
    # Kill existing processes
    #p_id=$(echo -e "$process_query" | awk '{print $2}')
    #adb shell am force-stop $process_name    
    #sleep 5
    
#    if [ $process_name == "com.android.browser" ]; then
#        adb shell am start -a android.intent.action.VIEW -d 'http://www.google.com' -n $process_name/com.android.browser.BrowserActivity
#    fi
 
#    sleep 5
    
#    adb shell am force-stop $process_name    
#    sleep 5
    
else 
    echo "$process_name doesn't exist.."
fi

max=0
for ((i=0;i<$tab_num;i++))do
    sum=0 
    p_num=0

    echo ""
    # launch browser activity
    if [ $process_name == "com.android.browser" ]; then
        if [ $i -eq 0 ]; then
            adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.android.browser.BrowserActivity -e $extra
        else
            adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.android.browser.BrowserActivity
        fi
    elif [ $process_name == "com.android.chrome" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.google.android.apps.chrome.Main
    elif [ $process_name == "com.sec.android.app.sbrowser" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.sec.android.app.sbrowser.SBrowserMainActivity --ez create_new_tab true
    elif [ $process_name == "com.android.swe.browser" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.android.browser.BrowserLauncher
    elif [ $process_name == "com.chrome.beta" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/com.google.android.apps.chrome.Main 
    elif [ $process_name == "org.mozilla.firefox" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/.App    
    elif [ $process_name == "mobi.mgeek.TunnyBrowser" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/.BrowserActivity
    elif [ $process_name == "com.dolphin.browser" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/.BrowserActivity     
    elif [ $process_name == "com.nhn.android.search" ]; then
        adb $device shell am start -a android.intent.action.VIEW -d ${test_url[$i]} -n $process_name/.ui.pages.SearchHomePage     
    else
        echo "Please recheck...." 
    fi

    sleep 10

    # Find running processes
    p_id=$(adb $device shell ps | grep $process_name | awk '{print $2}')

    # Get Memory usage
    for p in $p_id
    do
        pname=$(adb $device shell dumpsys meminfo $p | grep MEMINFO | awk '{print $6}')
        m=$(adb $device shell dumpsys meminfo $p | grep TOTAL | awk '{print $2}')
        p_oom_adj=$(adb $device shell cat /proc/$p/oom_adj | grep "")
        p_oom_score=$(adb $device shell cat /proc/$p/oom_score | grep "")
        p_oom_adj_score=$(adb $device shell cat /proc/$p/oom_adj_score | grep "")
    
        sum=$(( $sum+$m ))
        p_num=$(( $p_num+1 ))
        
        echo "Pss Toal: $m(kB) [pid: $p, oom_adj: $p_oom_adj, oom_score: $p_oom_score] $pname"
        #echo "Pss Toal: $m(kB) [pid: $p] $pname"
        
        # log file
        p_mem_info=$(adb $device shell dumpsys meminfo $p)
        echo "$(( $i+1 )) step - memory info" >> result.txt
        echo "$p_mem_info" >> result.txt
        echo "" >> result.txt  
        
    done
        
    if [ $max -gt $sum ];then
        max=$max
    else
       max=$sum
    fi

echo "$(( $i+1 )) step sum : $sum"
echo "$(( $i+1 )) step max : $max"

done

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

# Get lmk info
lmk_minfree=$(adb $device shell cat /sys/module/lowmemorykiller/parameters/minfree | grep "")
lmk_adj=$(adb $device shell cat /sys/module/lowmemorykiller/parameters/adj | grep "")

# print result
echo ""
echo "num of processes: $p_num, Max memory usage: $max (kB)"
echo "lmk minfree: $lmk_minfree (KB)"
echo "lmk adj: $lmk_adj"
echo ""
    

# for test
adb $device shell cat /proc/meminfo | head -n 4
