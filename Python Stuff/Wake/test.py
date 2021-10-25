import matplotlib.pyplot as plt
import seaborn as sns
import datetime
import warnings
warnings.filterwarnings("ignore")


import pandas as pd

stock = pd.read_csv(r'C:\Users\m118954\PowerBI\YahooFinance.csv',parse_dates=['Date'])


fig, ax = plt.subplots(2,6,figsize=(18,10))  # use figure size to enlarge the canvas (change to 1 row 2 columns)
fig.suptitle('Last 5 days movement', fontsize=16)
start = max(stock['Date']) - datetime.timedelta(10)

codes = ['^AORD','WPL.AX','ANN.AX','APX.AX','CSL.AX','WBC.AX','KGN.AX','A2M.AX','LNK.AX','AGL.AX','IAG.AX','TWE.AX']

for index, code in enumerate(codes):
    line = stock[(stock['Code']==code) & (stock['Date']>start)]['Close']
    #date = stock[(stock['Code']==code) & (stock['Date']>start)]['Date']
    
    if index <= 5:
        col = index
        row = 0
    else:
        col = index - 6
        row = 1
    
    ax[row,col].plot(line,color='tab:red', marker='o', linestyle='--')
    #ax[row,col].set(title=code)
    #ax[row,col].set_xticklabels(date.dt.strftime('%d-%m-%y'), rotation = 45)
    ax[row,col].set_xlabel(code)
    ax[row,col].set_xticks([])
plt.show()


#ANN = stock[(stock['Code']=='ANN.AX') & (stock['Date']>start)]['Close']
#AGL = stock[(stock['Code']=='AGL.AX') & (stock['Date']>start)]['Close']
#ax[0].plot(ANN)
#ax[1].plot(AGL)



