
### debug ###

## add new



import pandas as pd
import glob
import os

consol  = pd.DataFrame(columns=['Name','Title','Location'])


os.chdir(r'C:\Users\m118954\OneDrive - Westpac Group\_sharing\LinkedIn')
extension = 'xlsx'
files = [i for i in glob.glob('*.{}'.format(extension))]

 
mycities = ['Sydney','Perth','Melbourne','Brisbane','Canberra','New South Wales','Victoria','ACT','NSW']
myrole = ['Property','Government','Education','Prof Services','Agri','Health','Professional Services']
myprofile = ['View','LinkedIn Member']
mylist = []
final = pd.DataFrame(columns = ['Name','Title','Industry','Location'])


for file in files:
    df = pd.read_excel(file)
    
    # get the bank name
    if 'ANZ' in file:
        bank = 'ANZ'
    elif 'CBA' in file:
        bank = 'CBA'
    elif 'MAC' in file:
        bank = 'Macquarie'
    elif 'NAB' in file:
        bank = 'NAB'
    elif 'RABO' in file:
        bank = 'Rabobank'
    else:
        bank = 'Other'
    
    
    mylist2 = []
    for x,y in enumerate(df.columns):
        z = 'Col' + str(x)
        mylist.append(z)

    df.columns = mylist
    mylist = []

    df.dropna(axis=0,how='all',inplace=True)
    #print (df)
    #df.drop('Col0',axis=1,inplace=True)
    df.reset_index(drop=True, inplace=True)
    
    #print(df)

    
    
    for i in df.columns:
    
            mydf = df[i]
            mydf.dropna(inplace=True)
            mydf = mydf.astype(str)
        

            # remove unwanted words 
            mydf = mydf[~mydf.str.contains('Current|Past|Connect|Summary|Message|University|Results|nan',case=False)]
            mydf.reset_index(drop=True,inplace=True)
            for row in range(mydf.shape[0]):
                string = mydf.loc[row].lower()
                for word in myprofile:

                    if word.lower() in string:
                        try:
                            name = 'NA'
                            role = 'NA'
                            location = 'NA'
                            industry = 'NA'

                            name = mydf.loc[row]
                            row1 = mydf.loc[row+1]
                            row2 = mydf.loc[row+2]
                            

                            for title in myrole:
                                if title.upper() in row1.upper():
                                    role = row1
                                    industry = title
                                elif title.upper() in row2.upper():
                                    role = row2
                                    industry = title

                            for city in mycities:
                                if city.upper() in row1.upper():
                                    location = city
                                elif city.upper() in row2.upper():
                                    location = city

                            if role == 'NA':
                                role = 'Non-Keywords'
                            elif location == 'NA':
                                location = 'Unknown'

                            mylist2.append([name,role,industry,location,bank])
                            
                        except:
                            continue
                            
                            
    final = pd.DataFrame(mylist2)       
    final.columns = ['Name','Title','Industry','Location','Bank']    
    final = final[final['Title']!='Non-Keywords']
    final['Name'] = final.apply(lambda x:x['Name'].split('View')[0],axis=1)
    #final.to_csv(file[:-5] + '_CSV' + '.csv',index=False)
    consol = consol.append(final)
    
consol.to_csv('Summary.csv', index=False)
            
               
    
           