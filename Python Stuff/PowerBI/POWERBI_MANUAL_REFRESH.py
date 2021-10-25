
import time
import pyautogui as s

# allow power bi to open
time.sleep(25) 


s.click(1909,986)
time.sleep(2)

s.moveTo(1000,1000)


y = [261,324,353,440,740,833,891,955,980]   # stuff I can refresh
#y = [502,534,566,593,619,649,688]  # Annie can refresh


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
            print ('This coordinate ',i,'refreshed in ',duration)
        else:
            k = s.locateOnScreen('Spool.png')
            l = s.locateOnScreen('Run.png')
            if k is not None :
               s.click('Close.png')
               print ('Spool Space Issue in this coordinate ',i)
            elif l is not None:
               s.click('Run.png') 
               print ('Had to click run on this coordinate ',i)               		
            z = 'Refresh'

    
    ############# Wait until it finishes ###############
    
 

