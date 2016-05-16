#!/bin/bash

# bench.sh
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

action_get_uastring="lgeHiddedMenu.intent.action.GET_UASTRING"
action_get_uaprofile="lgeHiddedMenu.intent.action.GET_UAPROFILE"
action_change_uastring="lgeHiddedMenu.intent.action.CHANGE_UASTRING"
action_change_uaprofile="lgeHiddedMenu.intent.action.CHANGE_UAPROFILE"

unixName=$(uname -s)
linux="Linux"

fake_uastring="Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LG-LS980 Build/KOT49I.LS980ZVB) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.2 Chrome/30.0.1599.103 Mobile Safari/537.36"
fake_uaprofile="http://device.sprintpcs.com/LG/LS980-Chameleon/latest"
screen_brightness=0
screen_off_timeout=2147483647

if [ $unixName = $linux ]
then
    js_get_results="javascript:console.log(document.body.innerText);"
    js_run_browsermark="javascript:document.getElementsByClassName('launchBar')[0].click();"
    js_run_octane="javascript:Run()"
else
    js_get_results="javascript:console.log\(document.body.innerText\)\;"
    js_run_browsermark="javascript:document.getElementsByClassName\(\'launchBar\'\)[0].click\(\)\;"
    js_run_octane="javascript:Run\(\)"
fi

enter_key=66
power_key=26

cpu_temp_threshold=35

bench=(\
  "sunspider" \
  "v8" \
  "browsermark")

declare -A bench_name=(\
  [sunspider]="SunSpider 1.0.2" \
  [browsermark]="BrowserMark 2.1" \
  [v8]="V8 Benchmark v7" \
  [octane]="Octane 2.0")
declare -A bench_entry_url=(\
  [sunspider]="https://www.webkit.org/perf/sunspider/sunspider.html" \
  [browsermark]="http://web.basemark.com/" \
  [v8]="about:blank" \
  [octane]="http://octane-benchmark.googlecode.com/svn/latest/index.html")
declare -A bench_run_url=(\
  [sunspider]="https://www.webkit.org/perf/sunspider-1.0.2/sunspider-1.0.2/driver.html" \
  [browsermark]="http://web.basemark.com/tests/2.1" \
  [v8]="http://v8.googlecode.com/svn/data/benchmarks/v7/run.html" \
  [octane]="")
declare -A bench_results_url=(\
  [sunspider]="https://www.webkit.org/perf/sunspider-1.0.2/sunspider-1.0.2/results.html" \
  [browsermark]="http://web.basemark.com/results" \
  [v8]="" \
  [octane]="")
declare -A bench_results_str=(\
  [sunspider]="Total:" \
  [browsermark]="score was" \
  [v8]="Score:" \
  [octane]="Octane Score:")
declare -A bench_results_val=(\
  [sunspider]="{print \$4}" \
  [browsermark]="{print \$10}" \
  [v8]="{print \$4}" \
  [octane]="{print \$5}")
declare -A bench_results_polling_interval_sec=(\
  [sunspider]=10 \
  [browsermark]=60 \
  [v8]=90 \
  [octane]=90)

loop_count=5
break_time_sec=180

perf_mode=0

function usage()
{
  echo "Usage: `basename $0` [-s <device>] [-p] [-h] [<benchmark> <benchmark> ...]"
  echo "  -s <device>       set specific <device> for adb"
  echo "  -p                performance mode test"
  echo "  -h                help"
  echo "  <benchmark>       specify the list of <benchmark> to be run."
  echo "                    if <benchmark> does not specified, default benchmark list will be used."
  echo "                    default benchmarks are sunspider, v8 and browsermark."
  echo
  echo "<benchmark> keywords:"
  echo -e "  sunspider\n  browsermark\n  v8\n  octane\n\n"
}

while getopts ":s:ph" opt; do
  case $opt in
    s)
      device="-s $OPTARG"
      ;;
    p)
      perf_mode=1
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

function is_max_freq_down()
{
  cpuinfo_max_freq=$(adb $device shell cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
  scaling_max_freq=$(adb $device shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
  echo "cpuinfo_max_freq=$cpuinfo_max_freq"
  echo "scaling_max_freq=$scaling_max_freq"
  if [ "$scaling_max_freq" != "$cpuinfo_max_freq" ]; then
    echo "CPU max freq down from $(echo $cpuinfo_max_freq | tr -d '\r') to $(echo $scaling_max_freq | tr -d '\r')"
    return 0
  fi
  return 1
}

function is_screen_off()
{
  local android_version=$(get_prop 'ro.build.version.release')
  local screen_on

  if [ $android_version == "L" ]; then
    screen_on=$(adb $device shell dumpsys power | grep 'Display Power' | awk -F[=] '{print $2}')
  else
    screen_on=$(adb $device shell dumpsys power | grep mScreenOn= | grep -oE '(true|false)')
  fi
  if [ "$screen_on" == "true" -o "$screen_on" == "ON" ]; then
    return 1
  else
    return 0
  fi
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

function break_time_if_needed()
{
  while true; do
    cpu_temp=$(get_cpu_temp)
    echo "cpu_temp = $cpu_temp (threshold: $cpu_temp_threshold)"
    if [ $cpu_temp == "" ]; then
        echo "Warning: cpu temp is not available. Instead scaling max freq will be checked"
        if [ !is_max_freq_down ]; then
            break;
        fi
    fi
    if [ $cpu_temp -le $cpu_temp_threshold ]; then
        break;
    fi
    echo "Break time for $break_time_sec (sec)"
    adb $device shell input keyevent $power_key
    sleep $break_time_sec
    adb $device shell input keyevent $power_key
    unlock_screen
  done
}

function tap_url_input()
{
  statusbar_w=$(adb $device shell dumpsys window StatusBar | grep "Requested" | awk '{print $2}' | awk -F[=] '{print $2}')
  statusbar_h=$(adb $device shell dumpsys window StatusBar | grep "Requested" | awk '{print $3}' | awk -F[=] '{print $2}')
  urlinput_x=$((statusbar_w/2))
  urlinput_y=$((statusbar_h+20))
  adb $device shell input tap $urlinput_x $urlinput_y
}

function do_perf_mode()
{
  echo "Start performance mode"
  adb $device shell stop thermal-engine
  adb $device shell stop mpdecision
  adb $device shell 'echo 0 > /sys/module/msm_thermal/core_control/enabled'
  core_num=$(adb $device shell cat /proc/cpuinfo | grep -c "processor")
  echo "cpu core: $core_num"
  for((i=0; i<$core_num; i++)); do
    adb $device shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
    adb $device shell "echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
    adb $device shell "echo cpu$i online: $(adb $device shell cat /sys/devices/system/cpu/cpu$i/online)"
    adb $device shell echo cpu$i scaling_governor: $(adb $device shell cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
    adb $device shell "cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
  done
}

function undo_perf_mode()
{
  echo "Stop performance mode"
  core_num=$(adb $device shell cat /proc/cpuinfo | grep -c "processor")
  echo "cpu core: $core_num"
  for((i=0; i<$core_num; i++)); do
    #adb $device shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
    adb $device shell "echo interactive > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
    #adb $device shell "echo cpu$i online: $(adb $device shell cat /sys/devices/system/cpu/cpu$i/online)"
    adb $device shell echo cpu$i scaling_governor: $(adb $device shell cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)
    #adb $device shell "cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
  done

  adb $device shell 'echo 1 > /sys/module/msm_thermal/core_control/enabled'
  adb $device shell start thermal-engine
  adb $device shell start mpdecision
}

function wait_for_loading()
{
  wait_url="$1"
  loaded_log=""
  while [ -z "$loaded_log" ]; do
    loaded_log=$(adb $device logcat -b events -d | grep browser_page_loaded | tail -1 | grep "$wait_url")
    adb $device logcat -b events -c
    sleep 1
  done
}

function get_cpu_temp()
{
  adb shell cat sys/class/hwmon/hwmon2/device/xo_therm | awk -F[": "] '{print $2}' 2> /dev/null
}

adb $device root || exit 1
adb $device wait-for-device

show_info

shift $((${OPTIND}-1))
if [ -n "$(echo ${*})" ]; then
  readarray bench < <(echo "${*}")
fi
echo "Benchmark to be run:"
for i in ${bench[@]}; do
  echo "${bench_name[$i]}"
done
echo
num_of_benchmark=${#bench[@]}

if [ $unixName = $linux ]
then
    echo "Set screen_off_timeout to $screen_off_timeout"
    old_screen_off_timeout=$(adb $device shell content query --uri content://settings/system --projection value --where 'name="screen_off_timeout"' | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_off_timeout --where 'name="screen_off_timeout"'

    echo "Set screen_brightness to $screen_brightness"
    old_screen_brightness=$(adb $device shell content query --uri content://settings/system --projection value --where 'name="screen_brightness"' | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_brightness --where 'name="screen_brightness"'
else
    echo "Set screen_off_timeout to $screen_off_timeout"
    old_screen_off_timeout=$(adb $device shell content query --uri content://settings/system --projection value --where \"name=\'screen_off_timeout\'\" | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_off_timeout --where \"name=\'screen_off_timeout\'\"

    echo "Set screen_brightness to $screen_brightness"
    old_screen_brightness=$(adb $device shell content query --uri content://settings/system --projection value --where \"name=\'screen_brightness\'\" | awk -F[=] '{print $2+0}')
    adb $device shell content update --uri content://settings/system --bind value:i:$screen_brightness --where \"name=\'screen_brightness\'\"
fi

echo "Initialize $package"
adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'` > /dev/null
sleep 1
adb $device logcat -b events -c
adb $device shell am start -a $action_view -n $component -e $extra -d "about:blank"
sleep 5
if [ -z "$(adb $device logcat -b events -d | grep -o browser_page_loaded)" ]; then
  echo "Error: browser_page_loaded not found"
  exit 1
fi
adb $device shell ps | grep "$package" | grep -v "sandboxed_process" | adb $device shell kill `awk '{print $2}'`
sleep 5

echo "Set uastring to $fake_uastring"
adb $device logcat -c
adb $device shell am broadcast -a $action_get_uastring
old_uastring="$(adb $device logcat -d | grep GET_UASTRING | tail -1 | sed 's/.*= //g')"
echo "old_uastring=$old_uastring"
adb $device shell "am broadcast -a $action_change_uastring -e uastring '$fake_uastring'"
adb $device logcat -c
adb $device shell am broadcast -a $action_get_uastring
new_uastring="$(adb $device logcat -d | grep GET_UASTRING | tail -1 | sed 's/.*= //g')"
echo "new_uastring=$new_uastring"
if [ "$new_uastring" == "$old_uastring" ]; then
  echo "Error: Fail to set fake uastring"
  exit 1
fi

adb $device logcat -c
adb $device shell am broadcast -a $action_get_uaprofile
old_uaprofile="$(adb $device logcat -d | grep GET_UAPROFILE | tail -1 | sed 's/.*= //g')"
echo "old_uaprofile=$old_uaprofile"
if [ -n "$old_uaprofile" ]; then
  echo "Set uaprofile to $fake_uaprofile"
  adb $device shell am broadcast -a "$action_change_uaprofile" -e uaprofile "$fake_uaprofile"
  adb $device logcat -c
  adb $device shell am broadcast -a $action_get_uaprofile
  new_uaprofile="$(adb $device logcat -d | grep GET_UAPROFILE | tail -1 | sed 's/.*= //g')"
  echo "new_uaprofile=$new_uaprofile"
  if [ "$new_uaprofile" == "$old_uaprofile" ]; then
    echo "Error: Fail to set fake uaprofile"
    exit 1
  fi
fi
sleep 5

echo "Start $package"
adb $device shell am start -a $action_view -n $component -e $extra -d "about:blank"
sleep 5

if [ $perf_mode -eq 1 ]; then
  do_perf_mode
fi

for i in ${bench[@]}; do

  echo "Load ${bench_name[$i]}"
  bench_entry_url_t=${bench_entry_url[$i]}"?t="$(date +%s)
  echo "bench_entry_url_t=$bench_entry_url_t"
  adb $device shell am start -a $action_view -d $bench_entry_url_t -n $component -e $extra
  sleep 5

  total=0
  for((j=0;j<$loop_count;j++)); do

    break_time_if_needed

    echo "Run #$((j+1))/$loop_count"
    if [ "${bench_name[$i]}" == "BrowserMark 2.1" ]; then
      tap_url_input
      adb $device shell input text "$js_run_browsermark"
      adb $device shell input keyevent $enter_key
    elif [ "${bench_name[$i]}" == "Octane 2.0" ]; then
      wait_for_loading "$bench_entry_url_t"
      tap_url_input
      adb $device shell input text "$js_run_octane"
      adb $device shell input keyevent $enter_key
    else
      adb $device shell am start -a $action_view -d ${bench_run_url[$i]} -n $component -e $extra
    fi

    results_url=""
    while [ -z "$results_url" ]
    do
      sleep ${bench_results_polling_interval_sec[$i]}
      if [ "${bench_name[$i]}" == "Octane 2.0" ]; then
        results_url=$(adb $device logcat -d | grep "I/browser" | tail -1 | grep "Console: Typescript:")
      else
        results_url=$(adb $device logcat -b events -d | grep browser_page_loaded | tail -1 | grep "${bench_results_url[$i]}")
      fi
      if [ -n "$results_url" ]; then
        echo "$results_url"
      fi
    done

    tap_url_input
    adb $device shell input text "$js_get_results"
    adb $device logcat -c
    adb $device shell input keyevent $enter_key
    results_val[$j]=$(adb $device logcat -v tag -d | grep "I/browser" | grep "${bench_results_str[$i]}" | tail -1 | awk "${bench_results_val[$i]}" | tr -d '\r' | sed 's/ms//g')

    if [[ -z "${results_val[$j]}" ]]
    then
        results_val[$j]=0
    fi

    echo "Results: ${results_val[$j]}"

    total=$((total+$(echo ${results_val[$j]} | sed 's/\..*//g')))

    bench_entry_url_t=${bench_entry_url[$i]}"?t="$(date +%s)
    echo "bench_entry_url_t=$bench_entry_url_t"

    if [ "${bench_name[$i]}" == "BrowserMark 2.1" ]; then
      adb $device shell am start -a $action_view -d $bench_entry_url_t -n $component -e $extra
    fi
    if [ "${bench_name[$i]}" == "Octane 2.0" ]; then
      adb $device shell am start -a $action_view -d $bench_entry_url_t -n $component -e $extra
    fi
    sleep 5

  done # loop_count

  echo
  #echo "${bench_name[$i]} Results"
  results_count=1
  for res in ${results_val[@]}; do
    echo "Benchmark Results [${bench_name[$i]}] $results_count/$loop_count: $res"
    ((results_count++))
  done
  results_val_avg=$(($total/$loop_count))
  echo "Benchmark Results [${bench_name[$i]}] Avg: $results_val_avg"
  echo

done # ${bench[@]}

if [ $perf_mode -eq 1 ]; then
  undo_perf_mode
fi

# Restore uastring and uaprofile
echo "Reset uastring to $old_uastring"
adb $device shell "am broadcast -a $action_change_uastring -e uastring '$old_uastring'"
if [ -n "$old_uaprofile" ]; then
  echo "Reset uaprofile to $old_uaprofile"
  adb $device shell am broadcast -a "$action_change_uaprofile" -e uaprofile "$old_uaprofile"
fi

if [ $unixName = $linux ]
then
    # Restore screen_brightness
    echo "Reset screen_brightness to $old_screen_brightness"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_brightness --where 'name="screen_brightness"'

    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where 'name="screen_off_timeout"'
else
    # Restore screen_brightness
    echo "Reset screen_brightness to $old_screen_brightness"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_brightness --where 'name="screen_brightness"'

    # Restore screen_off_timeout
    echo "Reset screen_off_timeout to $old_screen_off_timeout"
    adb $device shell content update --uri content://settings/system --bind value:i:$old_screen_off_timeout --where 'name="screen_off_timeout"'
fi
