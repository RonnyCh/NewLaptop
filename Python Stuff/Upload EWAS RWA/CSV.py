import time
import teradatasql
import math
#import progressbar
import pandas as pd
import os
import glob

# User Setup
os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\Upload EWAS RWA')
tblname = 'bpabba1.ewas_digital_leads_raw'
myusername = 'M118954'
mypassword = 'Mygdw2032!'



# get all the csv files
extension = 'csv'
csvFiles = [i for i in glob.glob('*.{}'.format(extension))]
t1 = pd.concat([pd.read_csv(file) for file in csvFiles ])
putCol = 'N'   ## need header???

# if no headers just populate dummy col1 col2 etc
if putCol == 'Y':   # need header
    col = []
    for i,n in enumerate(t1.columns):
         x = 'Col' + str(i)
         col += [x]
    t1.columns = col

    
# data wrangling to get rid off null values in object types, otherwise causing errors in GDW!    
for x,y in zip(t1.columns,t1.dtypes):
    if y == 'O':
        t1[x] = t1[x].fillna('None')   # just put default value BLNK (blank)
    elif y == 'float':
        t1[x] = t1[x].fillna(0)
    elif y == 'int64':
        t1[x] = t1[x].fillna(0)



# determine the no of column for insert into
values = ''
for i in t1.columns:
    values += '?' + ','
values = 'values (' + values[:len(values)-1] +')'


# convert attachment to string so it can load to GDW
t1['AttachmentsCount'] = t1['AttachmentsCount'].astype(str)


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