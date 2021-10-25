import win32com.client # this library handles outlook integration
import re # regular expression library to filter email
import os # directory management
import pandas as pd
import time
import datetime as dt
import glob
import teradatasql
import datetime


os.chdir(r'C:\Users\M118954\OneDrive - Westpac Group\_sharing\Upload EWAS RWA')


################ get data from GDW ############################

import time
import teradatasql
import math
#import progressbar
import pandas as pd


with teradatasql.connect(host='tdp5dbcw.teradata.westpac.com.au', user='M118954', password='Mygdw2032!') as con:
    with con.cursor () as cur:
        t1 = pd.read_sql('select * from bpabba1.ewas_digital_leads_raw',con)

t1['ReceivedTime'] = pd.to_datetime(t1['ReceivedTime'],utc=True)

start = t1['ReceivedTime'].max() + pd.Timedelta(minutes=2)


###############################################################


def extract_leads(subject_keywords, start_datetime):
    """Get emails from outlook."""
    items = []
    outlook = win32com.client.Dispatch("Outlook.Application").GetNamespace("MAPI")
    folder = outlook.Folders.Item("Business Digital Sales")

    # code below extract leads from the main inbox folder of "Business Digital Sales"
    inbox = folder.Folders.Item("Inbox")
    wefInbox = inbox.Folders['WEF']


    messages = inbox.Items
    wefMessages = wefInbox.Items

    messages.Sort("[ReceivedTime]", True)
    wefMessages.Sort("[ReceivedTime]", True)

    newMessages = messages.Restrict("[ReceivedTime] > '" +start_datetime.strftime('%d/%m/%Y %H:%M %p')+"'")
    newWefMessages = wefMessages.Restrict("[ReceivedTime] > '" +start_datetime.strftime('%d/%m/%Y %H:%M %p')+"'")

    message = newMessages.GetFirst()
    wefMessage = newWefMessages.GetFirst()

    while message:
        try:
            subjectRegex = re.compile(subject_keywords)
            if subjectRegex.search(message.Subject):
                result = dict()
                result["Subject"] = message.Subject
                result["ReceivedTime"] = str(message.ReceivedTime)
                result["SenderEmailAddress"] = message.SenderEmailAddress
                result["Body"] = message.Body                
                result["AttachmentsCount"] = str(message.Attachments.Count)

                attachment = message.Attachments.Item(1)
                result["AttachmentName"] = str(attachment)
                path = os.getcwd()+'\\attachments\\'+str(attachment)
                attachment.SaveAsFile(path+ str(attachment))
                result["attachmentContent"] = pd.read_html(path+str(attachment))[0]
                result["customerId"] = result["attachmentContent"][0].iloc[1][-8:]
                items.append(result)
        except Exception as ex:
            print("Error processing mail: ", ex)
        message = newMessages.GetNext()

    # code below extract leads from the WEF folder of "Business Digital Sales"       
    while wefMessage:
        try:
            subjectRegex = re.compile(subject_keywords)
            if subjectRegex.search(wefMessage.Subject):
                result = dict()
                result["Subject"] = wefMessage.Subject
                result["ReceivedTime"] = str(wefMessage.ReceivedTime)
                result["SenderEmailAddress"] = wefMessage.SenderEmailAddress
                # result["Body"] = wefMessage.Body                
                result["AttachmentsCount"] = str(wefMessage.Attachments.Count)

                attachment = wefMessage.Attachments.Item(1)
                result["AttachmentName"] = str(attachment)
                path = os.getcwd()+'\\attachments\\'+str(attachment)
                attachment.SaveAsFile(path+ str(attachment))
                result["attachmentContent"] = pd.read_html(path+str(attachment))[0]
                result["customerId"] = result["attachmentContent"][0].iloc[1][-8:]
                items.append(result)
        except Exception as ex:
            print("Error processing mail: ", ex)
            print(result["Subject"])
        wefMessage = newWefMessages.GetNext()


    return items


df_leads = pd.DataFrame(extract_leads('Business Loans', start))



t2 = df_leads[['Subject', 'ReceivedTime', 'SenderEmailAddress','AttachmentsCount','AttachmentName', 'customerId']]

t2.to_csv('ewas.csv',index=False)

