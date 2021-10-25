select 
metric_code,
trim(acct.LG_Account_L09_Name) as AcctL9,
trim(acct.LG_Account_L08_Name) as AcctL8,
trim(prod.LG_Product_L10_Name) ,
trim(prod.LG_Product_L09_Name) ,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','840000') then repctr.LG_Centre_L12_name
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
trim(repctr.LG_Centre_L12_name) as repctr12,
trim(repctr.LG_Centre_L11_name) as repctr11,
mar.Parent8_Name,
a.lg_account_id,
a.lg_product_id,
a.entry_code,
sum(metric_amt)
from 
dwpviewa.FQ_Adjusted_Ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
where a.lg_product_id in ('15146','15147','15148','15145')
and reporting_mth = '201809'
and date between a.from_date and a.to_date
group by 1,2,3,4,5,6,7,8,9,10,11,12
order by 1,2,3,4,5;