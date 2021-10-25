import win32com.client
#other libraries to be used in this script
import os
from datetime import datetime, timedelta
import time
import pyautogui as s
import Setup as x


# maximise the arvo png file for python to do the next step
import pyautogui as s
import time
s.hotkey('win','up')

# let power bi server refresh the data
time.sleep(20)


# take snapshots
s.screenshot('Morning.png',region = (558,241,1052,776))


time.sleep(2)
# close the web
s.hotkey('alt','f4')


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
          
	    Please use the following <a href='https://login.microsoftonline.com/57c64fd4-66ca-49f5-ab38-2e67ef58e724/oauth2/authorize?client_id=871c010f-5e61-4fb1-83ac-98610a7e9110&response_type=code%20id_token&scope=openid%20profile%20offline_access&state=OpenIdConnect.AuthenticationProperties%3DEAVmT4UNgSM9fteaAPoLJ8XhpkAhtpFz6XfOiG3bv6x2sZCsUtllshmDN33Y1gNm9pj3SbHfi0Qm4n4zvtJry8Uh4lWVzfO1GOi2GrCmfwkaQgDFifHZruaw0dMUGP3fBnJFfWSha8RiettFY2LSIq19jQjimfQJEZ6uup5yCq_2iHHoUoxSuHg_pjOMltXzMEHS2KZohYwPoG0T1GMLFOdaPgQidk4jXqAdG6tdxU_DJvUb8-PcqSPdmRz3UtvnecMtwsqs_-KQa39Cb_AOIo1WezvoYqjmwD5rQxz8kMyVDW18pF6J_n5YF0vzYYOQHEiyqLq3CFsKr0sfYzzPMg&response_mode=form_post&nonce=637604778523625037.MmM5ZjJkOGMtNzM4MC00YmE4LWIwODgtYTc3ZDE2NzMxNTA4YWE1MTEyNTAtMjIwNS00OTMwLWE1MTEtMWI3ZTRiODkwNDRh&site_id=500453&redirect_uri=https%3A%2F%2Fapp.powerbi.com%2Flinks%2FE00gKLfJBf%3Fctid%3D57c64fd4-66ca-49f5-ab38-2e67ef58e724%26pbi_source%3DlinkShare&post_logout_redirect_uri=https%3A%2F%2Fapp.powerbi.com%2Flinks%2FE00gKLfJBf%3Fctid%3D57c64fd4-66ca-49f5-ab38-2e67ef58e724%26pbi_source%3DlinkShare&resource=https%3A%2F%2Fanalysis.windows.net%2Fpowerbi%2Fapi&nux=1&x-client-SKU=ID_NET461&x-client-ver=5.6.0.0&sso_reload=true'
>link</a> to access the Growth Campaign Tracker report. 
	    The underlying excel data files that were provided in the SMEG and SMERLS daily emails can be found in the Downloads page of the power BI report. 

             <br>

        </span>
    </div><br>
    <div>
	
        <img src="C:\\Users\\m118954\\OneDrive - Westpac Group\\_sharing\\Power BI Email\\Morning.png" width=50%> 

<br>

        <img src="C:\\Users\\m118954\\OneDrive - Westpac Group\\_sharing\\Power BI Email\\Morning.png" width=50%> 
	

    </div><br>

    <div>
     Please click <a href='https://teams.microsoft.com/l/channel/19%3ab292fdbaac6b4be8aed09ca7b0910466%40thread.tacv2/Growth%2520Campaign%2520Queries?groupId=31770276-b120-4404-b54b-c1bf40690aa5&tenantId=57c64fd4-66ca-49f5-ab38-2e67ef58e724'>here</a> to chat with us on teams. <br> <br>

     Thanks, <br>
     Data Science and Innovation Team
	
    </div>	
    """
#############################################################################################################







####################### Distribution List ###################################################################


myto = 'norman.yan@stgeorge.com.au;anthony.mathews@westpac.com.au;samantha.edwards@westpac.com.au;Andy.Lay@btfinancialgroup.com'



mybcc = 'Monique.Trivas@westpac.com.au;nwaring@westpac.com.au;migorman@westpac.com.au;milton.chia@westpac.com.au;steven.jeroncic@westpac.com.au;gburgess@westpac.com.au;michael.bergamin@westpac.com.au;steven.cuthbert@westpac.com.au;jpearce@westpac.com.au;nicolemoore@westpac.com.au;nuppal@westpac.com.au;skye.mckenzie@westpac.com.au;amcrae@westpac.com.au;DL.DFC.Micro.SME.GTM@westpac.com.au;jadamson@westpac.com.au;kerryn.beltran@westpac.com.au;lchurch@westpac.com.au;kim.cook@westpac.com.au;david.creanor@westpac.com.au;sarah.croxton@westpac.com.au;lfellowes@westpac.com.au;natalie.frazer@westpac.com.au;antoinette.harb@stgeorge.com.au;diane.hockridge@banksa.com.au;matthew.millar@westpac.com.au;MILLARDS@stgeorge.com.au;dmynott@westpac.com.au;vperrins@westpac.com.au;sharon.sykes@westpac.com.au;jsymonds@westpac.com.au;nancy.yedgar@westpac.com.au;alexander.stevenson@westpac.com.au;pramishetty@westpac.com.au;shane.howell@westpac.com.au;erica.belluccini@westpac.com.au;sameera.madhani@westpac.com.au;longsan.wong@westpac.com.au;davidmillar@westpac.com.au;magdalena.sikora@westpac.com.au;donella.fardoulis@westpac.com.au;anna.mcliesh@westpac.com.au;marisa.marconi@westpac.com.au;annie.liao@westpac.com.au;ronny.christianto@westpac.com.au;syusman@westpac.com.au;diana.thai@westpac.com.au;sudeepdas@westpac.com.au;lltay@westpac.com.au;phogan@westpac.com.au;lmullen@westpac.com.au;Hsien.Chin@westpac.com.au;guyziino@westpac.com.au;abhishek.mathur1@westpac.com.au;Tamara.Bryden@westpac.com.au;jane.watts@westpac.com.au;martin.green@stgeorge.com.au;llivis@westpac.com.au;jhurdis@westpac.com.au;david.firth@banksa.com.au;nicole.backhouse@westpac.com.au;shannan@westpac.com.au;gpell@westpac.com.au;grandl@westpac.com.au;mstafford@westpac.com.au;jaywatson@westpac.com.au;diane.wilson@westpac.com.au;sharon.andrews@westpac.com.au;adam.cuschieri@westpac.com.au;cbonavia@westpac.com.au;diana.pelea@westpac.com.au;michael.twohig@westpac.com.au;thuyvankhoa.nguyen@westpac.com.au;james.treacy@stgeorge.com.au;peter.tran@westpac.com.au;jayapradha.edavalath@westpac.com.au;timrouvray@westpac.com.au;Antony.Blake@westpac.com.au;vhee@westpac.com.au;courtenay.stewart@westpac.com.au;jonathan.saunders@westpac.com.au;ashwin.balakumar@westpac.com.au;konrad.jungwirth@stgeorge.com.au;monica.namer@westpac.com.au;claire.parker@banksa.com.au;ben.baker@westpac.com.au;melanie.portelli@westpac.com.au'



myteam = 'ronny.christianto@westpac.com.au'



######################### create email #####################################

outlook = win32com.client.Dispatch('outlook.application')
mail = outlook.CreateItem(0)

mail.To = myto   # use ; to add more names
mail.BCC = mybcc
mail.Subject = 'Growth Campaign Tracker'
mail.HTMLBody = html_body
mail.Display()    # remove this once you ready to send





### change the from to team mailbox ###

time.sleep(3)

Fr = s.locateOnScreen('From.png',confidence=0.7)
Fr = s.center(Fr)

s.click(Fr[0],Fr[1])
time.sleep(2)
s.click(Fr[0],Fr[1]+70)
time.sleep(2)

# change label
s.click(715,537)

# agreed
time.sleep(2)
s.click(1083,606)




	





