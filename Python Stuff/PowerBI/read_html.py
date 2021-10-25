import re # regular expression library to filter email
import os # directory management
import pandas as pd
import time
import datetime as dt
import glob
import teradatasql
import datetime


time.sleep(30)

os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\EWAS V2\attachments')

# first function to get column names from HTML file
def col1(st):
    col = ['Legal Business Name','ABN','ACN','First Name','Surname','Additional Phone number','Phone number',
                              'Email','Comments','Customer ID']
    for i in col:
        if i in st:
            m = i
            return m
            break
        else:
            pass
            
# second function to get customer information from HTML file
def string(a):
    if 'Legal Business Name' in a:
        m = a[20:]
    elif 'ABN' in a:
        m = a[4:]
    elif 'ACN' in a:
        m = a[4:]
    elif 'First Name' in a:
        m = a[11:]
    elif 'Surname' in a:
        m = a[8:]
    elif 'Phone number' in a:
        if 'Additional' in a:
            m = a[24:]
        else:
            m = a[13:]
    elif 'Email' in a:
        m = a[6:]
    elif 'Comments' in a:
        m = a[9:]
    elif 'Customer ID' in a:
        m = a[11:]
    else:
        m = ''
    return m


# import all html files in the directory
extension = 'html'
html_file = [i for i in glob.glob('*.{}'.format(extension))]
filter_HTML= []

for i in html_file:
        filter_HTML.append(i)


# create a dataframe to collect all data
mytbl = pd.DataFrame(columns=['Legal Business Name','ABN','ACN','First Name',
                              'Surname','Phone number','Additional Phone number',
                              'Email','Comments','Filename','Customer ID'])

for fileNo, file in enumerate(filter_HTML):
    
    try:
        x = pd.read_html(file)
        df = x[0]
        df.columns = ['Raw'] # initial data from html
        df['Info']=df.apply(lambda x:string(x['Raw']),axis=1)   # pick up customer info
        df['Column'] = df.apply(lambda x:col1(x['Raw']),axis=1) # pick those column names
        df.index = df['Column']                                 # create index based on column names
         
        df = df.dropna()
        

        # move from raw data and convert from column to row 
        for index, colName in enumerate(df.index):
            
            mytbl.loc[fileNo,colName] = df.loc[colName,'Info']
       
        mytbl.loc[fileNo,'Filename'] = file
     
    except:
        print (file)       

# just need to pick up two columns and save to csv for the next process
import pandas as pd
         
mytbl = mytbl[['Filename','Customer ID']]
mytbl['Customer ID'] = mytbl['Customer ID'].astype(str)

print (mytbl.info())

myexcel = pd.read_excel(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\EWAS V2\Excel.xls')
myexcel.columns = ['Subject','Received','Email','Count','Filename']
myexcel['Received'] = myexcel['Received'].astype(str)
myexcel['Count'] = myexcel['Count'].astype(str)



t1 = pd.merge(myexcel,mytbl,how='inner',on='Filename')





import time
import teradatasql
import math
#import progressbar
import pandas as pd
import os
import glob

# User Setup
os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\EWAS V2\EWAS RAW DATA')
tblname = 'bpabba1.ewas_digital_leads_raw'
myusername = 'M118954'
mypassword = 'Mygdw2028!'



# determine the no of column for insert into
values = ''
for i in t1.columns:
    values += '?' + ','
values = 'values (' + values[:len(values)-1] +')'



# create a list and batches of 10000 rows
df = t1.values.tolist()
batches = math.ceil(len(df)/10000) + 1

overall = time.time()

#bar = progressbar.ProgressBar(maxval=batches, \
#    widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])

#bar.start()
for count in range(1,batches):
    
    end = count * 10000
    #print (end)
    start = (end - 10000) + 1
    #print (start)
    batch = df[start:end]
    #print (start,end)
    with teradatasql.connect(host='tdp5dbcw.teradata.westpac.com.au', user=myusername, password=mypassword) as con:
            with con.cursor () as cur:
                watch = time.time()
                cur.execute ("insert into " +  tblname + ' ' + values, batch)
                duration = round((time.time() - watch))
#    bar.update(count+1)
    print ("batch " + str(count) + ' completed and took ' + str(duration) + ' seconds ' + 'from row ' + str(start) + ' to row ' + str(end))
#bar.finish()

totTime = round((time.time()-overall)/60,2)
    
print ('Full CSV loaded in ' + str(totTime) + ' minutes')










