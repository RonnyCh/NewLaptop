#!/usr/bin/env python
# coding: utf-8



import win32com.client # this library handles outlook integration
import re # regular expression library to filter email
import os # directory management
import pandas as pd
import time
import datetime as dt
import glob
import teradatasql
from datetime import datetime
###### REMEMBER TO RUN THIS CODE WITHOUT ADMIN ACCESS 


# In[3]:


host='tdp5dbcw.teradata.westpac.com.au'
uid = 'M040938'
pwd = 'W0rdpass53@'


# In[4]:


script = """
SEL 
MAX(receivedTime) max_date FROM 
bpabba1.ewas_digital_leads_raw
"""


# In[5]:


with teradatasql.connect(host=host,user=uid,password=pwd) as connect:
    df_max_date = pd.read_sql(script,connect)


# In[6]:


previous_max_date = datetime.fromisoformat(df_max_date['max_date'][0])


# In[7]:


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

    newMessages = messages.Restrict("[ReceivedTime] >= '" +start_datetime.strftime('%d/%m/%Y %H:%M %p')+"'")
    newWefMessages = wefMessages.Restrict("[ReceivedTime] >= '" +start_datetime.strftime('%d/%m/%Y %H:%M %p')+"'")

    message = newMessages.GetFirst()
    wefMessage = newWefMessages.GetFirst()

    while message:
        try:
            subjectRegex = re.compile(subject_keywords)
            if subjectRegex.search(message.Subject):
                result = dict()
                result["Subject"] = message.Subject
                result["ReceivedTime"] = message.ReceivedTime
                result["SenderEmailAddress"] = message.SenderEmailAddress
                result["Body"] = message.Body                
                result["AttachmentsCount"] = message.Attachments.Count

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
                result["ReceivedTime"] = wefMessage.ReceivedTime
                result["SenderEmailAddress"] = wefMessage.SenderEmailAddress
                # result["Body"] = wefMessage.Body                
                result["AttachmentsCount"] = wefMessage.Attachments.Count

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


# In[8]:


df_leads = pd.DataFrame(extract_leads('Business Loans', previous_max_date))


# In[11]:


df_leads["ReceivedTime"]=df_leads["ReceivedTime"].dt.tz_convert(None)


# In[12]:


df_leads = df_leads[['Subject', 'ReceivedTime', 'SenderEmailAddress', 'AttachmentsCount', 'AttachmentName', 'customerId']]


# In[13]:


df_leads.to_csv('leads.csv', sep="|", index = False)


# In[14]:


print("Job ran successfully!")


# In[15]:


#         ============================================================
#                  CREATING TABLE USING THE FOLLOWING SCHEMA
#         ============================================================


#         CREATE MULTISET TABLE bpabba1.ewas_leads_raw_02032021,
#             FALLBACK,
#             NO BEFORE JOURNAL,
#             NO AFTER JOURNAL,
#             CHECKSUM = DEFAULT,
#             DEFAULT MERGEBLOCKRATIO,
#             MAP = TD_MAP2
#             (
#                 "Subject" VARCHAR(71),
#         "ReceivedTime" VARCHAR(23),
#         "SenderEmailAddress" VARCHAR(45),
#         "AttachmentsCount" VARCHAR(1),
#         "AttachmentName" VARCHAR(31),
#         "customerId" VARCHAR(8)
#     )
# PRIMARY INDEX ( Subject );


# In[ ]:




