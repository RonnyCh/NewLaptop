import win32com.client

outlook = win32com.client.Dispatch('outlook.application')
mapi = outlook.GetNamespace("MAPI")

inbox = mapi.GetDefaultFolder(6)   # inbox folder

messages = inbox.Items



###################################### Email Body ##############################################
html_body = """
    <div>
        <h1 style="font-family: 'Calibri'; font-size: 17; font-weight: bold; color: #000000;">
            
            
        </h1>
        <span style="font-family: 'Calibri'; font-size: 14; color: #000000;">
            
            Hi all, <br> <br>
          
	    Daily EWAS tables have been updated in both BPA and SQL Server.

             <br>
	    Thanks, <br>
            Data Science and Innovation Team	
        </span>
    </div><br>
    <div>
    </div><br>
    <div>
    </div>	
    """
#############################################################################################################







####################### Distribution List ###################################################################


myto = 'norman.yan@stgeorge.com.au;ronny.christianto@westpac.com.au;annie.liao@westpac.com.au;Andy.Lay@btfinancialgroup.com'

######################### create email #####################################

outlook = win32com.client.Dispatch('outlook.application')
mail = outlook.CreateItem(0)

mail.To = myto  # use ; to add more names
mail.Subject = 'Daily notification - EWAS raw table'
mail.HTMLBody = html_body
#mail.Display()    # remove this once you ready to send
mail.Send()
