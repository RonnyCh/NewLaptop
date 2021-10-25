
import time
import pyautogui as s

y = [261,324,353,440,740,833,891,955,980]

for i in y:
    s.click(1891,i)  # find the table to refresh
    time.sleep(3)
    s.click('RefreshData.png')  # move to refresh button
      
    
    ############# Wait until it finishes ###############
    
    time.sleep(5)
    begin = time.time()
    z = 'Refresh'
 
    while z == 'Refresh':   # loop until finishes
        duration = (time.time() - begin)/60

        m = s.locateOnScreen('Refresh.png')
       

        if m is None:
            z = 'Completed'
            print (z,duration,i)
        else:
            z = 'Refresh'

    
    ############# Wait until it finishes ###############
    
    

# cant see, scroll up and do the rest
s.click(1911,436)
time.sleep(5)

y = [567,778,657,685]


for i in y:
    s.click(1891,i)  # find the table to refresh
    time.sleep(3)
    s.click('RefreshData.png')  # move to refresh button
      
    time.sleep(5)    
    ############# Wait until it finishes ###############
    
    begin = time.time()
    z = 'Refresh'
 
    while z == 'Refresh':   # loop until finishes
        duration = (time.time() - begin)/60

        m = s.locateOnScreen('Refresh.png')
       

        if m is None:
            z = 'Completed'
            print (z,duration,i)
        else:
            z = 'Refresh'
               

    
    ############# Wait until it finishes ###############

