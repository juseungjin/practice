import time, sys
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

repeat = 5
startPos = (100,900)
endPos = (100,500)
steps = 60
duration = 0.8
wait = 1

if len(sys.argv) > 1:
    device = MonkeyRunner.waitForConnection(10, sys.argv[1])
else:
    device = MonkeyRunner.waitForConnection()
package = 'com.android.browser'
activity = 'com.android.browser.BrowserActivity'
runComponent = package + '/' + activity

# Start Activity

device.startActivity(component=runComponent)
time.sleep(1)

#
for i in range(0, repeat) :
	device.drag(startPos,endPos,duration,steps)
	time.sleep(1)
	device.drag(endPos,startPos,duration,steps)
	time.sleep(1)
