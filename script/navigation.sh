#!/bin/bash

# for log
exec > >(tee `basename $0`.log)
exec 2>&1

# user input - page url
test_url=$1

# declare array
name=(navigationStart unloadEventStart unloadEventEnd redirectStart redirectEnd fetchStart domainLookupStart domainLookupEnd connectStart connectEnd secureConnectionStart requestStart responseStart responseEnd domLoading domInteractive domContentLoadedEventStart domContentLoadedEventEnd domComplete loadEventStart loadEventEnd)

# launch browser 
adb shell am start -a android.intent.action.VIEW -d "http://"$test_url -n com.android.browser/com.android.browser.BrowserActivity
sleep 2


for ((i=0;i<21;i++))do

	# Clear logcat
	adb logcat -c
	
	adb shell input tap 878 207
	
	
	adb shell input text "javascript:console.log\(window.performance.timing[\'${name[$i]}\']\)"
	
	#adb shell input text "javascript:console.log\(performance.timing.${name[$i]}-performance.timing.navigationStart\)"
	
	sleep 1
	
	adb shell input tap 1311 2292
	sleep 0.5
	
	echo ""
	adb logcat -v time -d | grep --line-buffered Console: | tail -1 
	time[$i]=$( adb logcat -v time -d | grep --line-buffered Console: | tail -1 | awk -F " " '{print $7}' )
	
	echo "${name[$i]} = ${time[$i]}"
	
	if [ ${time[$i]} -ne 0 ]
	then
	    delta[$i]=$((${time[$i]}-${time[0]}))
	else
	    delta[$i]=0
	fi
	
	echo "${name[$i]} delta = ${delta[$i]}"
	
	sleep 1

done
