
import pyautogui as s
import os
import time

os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\Power BI Email')

time.sleep(20)

s.hotkey('win','up')

s.screenshot('Arvo.png',region = (558,241,1052,776))
s.screenshot('Arvo1.png',region = (595,311,235,295))

s.hotkey('alt','f4')
