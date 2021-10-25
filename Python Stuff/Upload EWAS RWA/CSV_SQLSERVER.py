import time
import teradatasql
import math
#import progressbar
import pandas as pd
import os
import glob



os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\Upload EWAS RWA')


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



# insert into SQL server

import pyodbc
import pandas
# Connection Parameters to sql server
server_name = '10.32.21.184,1435' 
db_name = 'BL_DSI'
retry_flag = True
retry_count = 0

conn = pyodbc.connect(r"Driver={SQL Server};Server="+server_name+";Database="+db_name)
cursor = conn.cursor()



for row in t1.itertuples():
    cursor.execute('''
                INSERT INTO stg.ewas_digital_leads_raw VALUES (?,?,?,?,?,?)
                ''',
                row.Subject, 
                row.ReceivedTime,
                row.SenderEmailAddress,
                row.AttachmentsCount,
                row.AttachmentName,
                row.customerId
                  )
conn.commit()