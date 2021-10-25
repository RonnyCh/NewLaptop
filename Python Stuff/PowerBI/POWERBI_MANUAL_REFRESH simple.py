
import time
import pyautogui as s

y = [740,833,891,955,980]

for i in y:
    s.click(1891,i)  # find the table to refresh
    time.sleep(3)
    s.click('RefreshData.png')  # move to refresh button
    time.sleep(70)
    

# cant see, scroll up and do the rest
s.click(1911,436)
time.sleep(5)

y = [567,778,657,685]


for i in y:
    s.click(1891,i)  # find the table to refresh
    time.sleep(3)
    s.click('RefreshData.png')  # move to refresh button
    time.sleep(70)

