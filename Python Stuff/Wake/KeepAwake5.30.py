import pyautogui
import time

import datetime
import time

pyautogui.FAILSAFE = False


mydate = datetime.date.today()
mytime = datetime.time(hour=17,minute=25)
mytime = datetime.datetime.combine(mydate,mytime)

while datetime.datetime.now() < mytime:
        pyautogui.click(28,1055)
        time.sleep(150)
	