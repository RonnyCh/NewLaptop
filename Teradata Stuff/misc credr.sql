sel
a.MONTH_KEY
,a.AR_SOURCE_SYSTEM_CODE
,a.AR_SOURCE_SYSTEM_KEY
,b.cr_risk_asset_subclass_code
,AFL.Acct_Key
,AFL.LG_Relationship_Centre_Id
,a.DW_PDCT_ID                    
,a.DW_PDCT_KEY                   
,a.PDCT_SOURCE_SYSTEM_CODE       
,a.PDCT_SOURCE_SYSTEM_KEY        
,a.BS_CENTRE_ID                  
,a.RPRT_CNTR_ID                
,ECON_CAPL_AMT
,BASEL_RWA_AMT
from NW.DW_GRP_CR_RPRT_FACT a
left join NW.DW_CR_RISK_ASSET_SUBCLASS_DIM b
on b.CR_RISK_ASSET_SUBCLASS_key = a.CR_RISK_ASSET_SUBCLASS_key
and date '2021-02-28' between b.EFFV_FROM and b.EFFV_TO
inner join dwpviewa.Acct_Fin_LG_Link AFL
on AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY = AFL.Acct_Key
where Month_Key = '202102'
and '20210228' between AFL.From_Date and AFL.To_Date
and AR_SOURCE_SYSTEM_CODE = 'SLIS'
and AR_SOURCE_SYSTEM_KEY = '100212211561100'
;






select * from dwpviewa.Acct_Fin_LG_Link
where date between from_date and to_date
and acct_key = 'SLIS100311694639100'