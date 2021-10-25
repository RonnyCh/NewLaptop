
select 
a.metric_code,
a.lg_account_id,
a.agg_account_id,
trim(acct.LG_Account_L06_Name) as AcctL6,
trim(agg.LG_Account_L06_Name) as AcctL6_2,
--trim(repctr.lg_centre_l13_name) as rep13,
--trim(repctr.lg_centre_l12_name) as rep12
sum(metric_amt) as amount
from finiq.FQ_TM1_Final a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and 1181231 between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Account_EOP as agg
on agg.LG_Account_ID = a.agg_account_id
and '29991231' between agg.from_date and agg.to_date
where a.reporting_mth in ('201902')
and trim(lg_centre_l13_name) in ('Bank SA - Consumer','Bank of Melbourne - Consumer','St. George Retail')
and trim(acct.LG_Account_L06_Name) = 'Acquisition Fees'
group by 1,2,3,4,5




select * from 
finiq.FQ_TM1_Final
where lg_account_id = '601311'
and reporting_mth = '201902'

