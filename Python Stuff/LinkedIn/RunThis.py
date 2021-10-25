
import pyautogui as s
import pandas as pd
import time

def findLink(img,conf):
    
    # bring the screen up
    dft = s.locateOnScreen('Link.png',confidence=conf)
    dft = s.center(dft)
    #s.click(dft[0],dft[1]+500) # just click 500 pixels below linked in logo to activate window
    s.click(dft[0],dft[1])
    s.hotkey('pgup')
    time.sleep(0.5)
    
    mylist = []
    #image = ['About','Thumbs','Excel','Link','Next']
    image = img

    for i in image:
        t = s.locateOnScreen(i+'.png',confidence=conf)
        
        if t is None:
            s.hotkey('pgdn')  # try to find at the bottom of screen
            time.sleep(0.5)
            t = s.locateOnScreen(i+'.png',confidence=conf)
            
            
            try:
                t = s.center(t)
                #print (t)
                screen = 'pgdn'
                mylist.append([i,t[0],t[1],screen])
                s.hotkey('pgup')
                time.sleep(0.5)
            except:
                
                # try to search in excel tab
                excel = s.locateOnScreen('Excel.png',confidence=conf)
                #print (excel)
                excel = s.center(excel)
                s.click(excel[0],excel[1])
                s.hotkey('pgup')
                time.sleep(1)
                
                # search the image again
                t = s.locateOnScreen(i+'.png',confidence=conf)
                #t = s.center(t)
                        

                if t is None:
                    screen = 'pgdn'
                    mylist.append([i,0,0,screen]) # cant find it, default 0,0
            
                    # BACK TO LINKED IN
                    s.click(dft[0],dft[1])
                    s.hotkey('pgup')
                else :
                    screen = 'pgup'   
                    mylist.append([i,t[0],t[1]+25,screen])
                    # BACK TO LINKED IN
                    s.click(dft[0],dft[1])
                    s.hotkey('pgup')
                    time.sleep(0.5)

        else:
            t = s.center(t)
            screen = 'pgup'
            mylist.append([i,t[0],t[1],screen])
        

    df = pd.DataFrame(mylist)
    df.columns = ['Name','X','Y','Location']
    df.index = df['Name']
    df.drop(['Name'],axis=1,inplace=True)
    
    
    return df


    


# figure out coordinates
df = findLink(['Thumbs','Excel','Link','Link2','Next','Results'],0.7)
#df = findLink(['A1'],0.7)
# bring the screen up
dft = s.locateOnScreen('Link.png',confidence=0.6)
dft = s.center(dft)
#s.click(dft[0],dft[1]+500)
s.hotkey('pgup')



for i in df.index:
    
    x = (df.loc[i][0])
    y = (df.loc[i][1])
    z = (df.loc[i][2])
    s.hotkey(z)
    
    if i != 'A1':        
        if x != 0 and y != 0 :
            #s.alert(text='Show ' + i, title='Confirmation', button='OK')
            s.moveTo(x,y,1.5)
    else:
        s.click(df.loc['Excel'][0],df.loc['Excel'][1])
        s.moveTo(df.loc['A1'][0],df.loc['A1'][1],1.5)

s.click(dft[0],dft[1])



# check how many pages from user

page = s.prompt(text='How many pages in the results', title='Title' , default='')
page = int(page)

count = 0

while count < page:
    
        count += 1

        s.click(df.loc['Results'][0],df.loc['Results'][1])


        if df.loc['Thumbs'][0] > 0:
            s.dragTo(df.loc['Thumbs'][0],df.loc['Thumbs'][1]+25,2,button='left')
        else:
            s.dragTo(df.loc['Next'][0],df.loc['Next'][1]+20,2,button='left')

        time.sleep(0.5)
        s.hotkey('ctrl','c')
        time.sleep(0.5)
        s.click() # clear the selection

        s.click(df.loc['Excel'][0],df.loc['Excel'][1])
        time.sleep(0.5)


        # go to excel and paste


        if count == 1:          # logic for first instance
            s.click(228,429)
            s.hotkey('ctrl','home')
            s.hotkey('ctrl','v')
        elif count == 2:        # logic for second instance
            s.click(228,429)
            s.hotkey('ctrl','home')
            s.press('right')
            s.hotkey('ctrl','v')
        else:                   # logic for the rest
            s.click(228,429)    
            s.hotkey('ctrl','home')
            s.hotkey('ctrl','right')
            time.sleep(1)
            s.press('right')
            s.hotkey('ctrl','v')

        s.click(df.loc['Link'][0],df.loc['Link'][1]) # back to linked in
        time.sleep(0.5)

        s.click(df.loc['Next'][0],df.loc['Next'][1])
        time.sleep(5)

        # debugg find new coordinates
        try :
            df.drop(['Next','Results','Thumbs'],inplace=True)
            df2 = findLink(['Next','Results','Thumbs'],0.7)
            df = df.append(df2)
        except:
            df2 = findLink(['Next','Results','Thumbs'],0.7)
            df = df.append(df2)

s.alert(text='Done!!', title='', button='OK')            
