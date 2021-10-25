import pandas as pd
import time
import teradatasql
import math


####################################setup###############################################################
t1 = pd.read_csv(r'C:\Users\m118954\OneDrive - Westpac Group\_MyPython\CSV Create Tbl and Upload\CBPremium.csv')
NeedHeader = 'n'   
tblname = 'finiq.AB_ADJ_CBPremium'
createTable = 'y'   # if not it will just insert into existing table
nrows = 10000
########################################################################################################



# if no headers just populate dummy col1 col2 etc
if NeedHeader.lower() == 'y':   # need header
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


# fix column names so no white spaces... again causing errors in GDW!
mycol = []
for x in t1.columns:
    mycol += [''.join(x.split())]
t1.columns = mycol


# error table
error = pd.DataFrame(columns=mycol)


# Create a template for fixing up the data types
mylist = ''
for m,n in zip(t1.columns,t1.dtypes):
    mylength = t1[m].astype(str).str.len().max()
    
    if n == 'object':
        mylist += m + ' varChar' + '(' + str(mylength) + '),' +'\n'
    elif n == 'float':
        mylist += m + ' float' + ',' +'\n'
    elif n == 'bool':
        mylist += m + ' varChar' + '(5),' +'\n'
    elif n == 'int64':
        if mylength < 5:
            mylist += m + ' INTEGER' + ',' +'\n'
        else:
            mylist += m + ' BIGINT' + ',' +'\n'
            
datatype = mylist[:len(mylist)-2]  # get rid of the last , 
    
# section for primary index
primaryindex =''
for m,n in enumerate(t1.columns):
    if m < 5:
        primaryindex += n + ','
    
primaryindex = primaryindex[:len(primaryindex)-1]  # get rid of the last , 

        
# the header of the SQL
text1 = """
CREATE MULTISET TABLE {} ,FALLBACK ,
 NO BEFORE JOURNAL,
 NO AFTER JOURNAL,
 CHECKSUM = DEFAULT,
 DEFAULT MERGEBLOCKRATIO,
 MAP = TD_MAP2
( 
{}
)
PRIMARY INDEX ({});
""".format(tblname,datatype,primaryindex)


print (text1)


# determine the no of column for insert into
values = ''
for i in t1.columns:
    values += '?' + ','
values = 'values (' + values[:len(values)-1] +')'

if createTable.lower() == 'y':
    with teradatasql.connect (host="tdp5dbcw.teradata.westpac.com.au", user="m118954", password="Mygdw2032!") as con:

        with con.cursor () as cur:

            try:
                cur.execute ('drop table ' + tblname)
                cur.execute (text1)
                print ('Previous table dropped and re-created')
            except:
                cur.execute (text1)
                print ('A new table created')


values = ''
for i in t1.columns:
    values += '?' + ','
values = 'values (' + values[:len(values)-1] +')'



df = t1.values.tolist()
batches = math.ceil(len(df)/nrows) + 1

overall = time.time()

#bar = progressbar.ProgressBar(maxval=batches, \
#    widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])

#bar.start()
for count in range(1,batches):
    
    end = count * nrows
    #print (end)
    start = (end - nrows) + 1
    #print (start)
    batch = df[start:end]
    #print (start,end)
    with teradatasql.connect(host='tdp5dbcw.teradata.westpac.com.au', user='M118954', password='Mygdw2032!') as con:
            with con.cursor () as cur:
                try:
                    watch = time.time()
                    cur.execute ("insert into " +  tblname + ' ' + values, batch)
                    duration = round((time.time() - watch))
                except:
                    x = pd.DataFrame(batch)
                    x.columns = mycol
                    error = error.append(x)
                    print ('batch error, check in error table')
#    bar.update(count+1)
    print ("batch " + str(count) + ' completed and took ' + str(duration) + ' seconds ' + 'from row ' + str(start) + ' to row ' + str(end))
#bar.finish()

totTime = round((time.time()-overall)/60,2)
error.to_csv(r'C:\Users\m118954\OneDrive - Westpac Group\_MyPython\CSV Create Tbl and Upload\error.csv',index=False)


print ('Full CSV loaded in ' + str(totTime) + ' minutes')







