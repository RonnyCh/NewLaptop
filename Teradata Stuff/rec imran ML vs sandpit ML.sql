select 
a.process_date,
--a.manual_alloc_desc,
a.metric_code,
trim(acct.LG_Account_L09_Name),
case when trim(acct.LG_Account_L08_Name)  = 'Capital Benefit' then 'Capital Benefit'
when trim(acct.LG_Account_L09_Name) = 'Non-interest income' then trim(acct.LG_Account_L08_Name)
when trim(prod.LG_Product_L08_Name) in ('Business Debit Card', 'Personal Credit Cards') and mar.Parent8_Name <> 'Non Customer Margin' then 'Cards'
when trim(prod.LG_Product_L08_Name)  in ('Personal Loans Revolving Credit','Personal Term Loans') and mar.Parent8_Name <> 'Non Customer Margin' then 'Personal Loans'
when  trim(prod.LG_Product_L08_Name)  = 'Auto Finance' and mar.Parent8_Name <> 'Non Customer Margin' then 'Auto Finance'
when trim(prod.LG_Product_L10_Name) in ('Personal Deposits', 'Business Deposits') and mar.Parent8_Name <> 'Non Customer Margin' then trim(prod.LG_Product_L09_Name)
when trim(prod.LG_Product_L10_Name) = 'Business Finance' and mar.Parent8_Name <> 'Non Customer Margin'  then trim(prod.LG_Product_L10_Name)
when mar.Parent8_Name = 'Non Customer Margin' then 'Non Customer Margin'
when trim(prod.LG_Product_L10_Name) in ('Total Product for TPROD Hierarchy') then 'Customer Margin Other'
else trim(prod.LG_Product_L10_Name)  end as ProdGrp,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','840000') then repctr.LG_Centre_L12_name
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
sum(case when tblname = 'FINIQ_Prod' then metric_amt else 0 end) as FQ_ML_Alloc,
sum(case when tblname = 'FINIQ_Sum' then metric_amt else 0 end) as Control_Report,
(Control_Report - FQ_ML_Alloc) as Var
from 
(
select
a.reporting_mth as process_date
,'FINIQ_Prod' as tblName
,metric_code
,a.entry_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.metric_amt 
from finiq.fq_manual_alloc  a
where a.reporting_mth in ('201806')
union all
select
a.reporting_mth
,'FINIQ_Sum' as tblName
,metric_code
,a.entry_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.tot_metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201806')
and a.entry_code in ('MLN','MLA','ERR')
) a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as ctr
on a.lg_cost_centre_id = ctr.LG_Centre_ID
and date between ctr.from_date and ctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
left join finiq.FIQ_Ref_IFRS_Account_Map ifrs
on ifrs.lg_account_id = a.lg_account_id
left join finiq.fiq_wib_product fmap
on fmap.lg_product_id = a.lg_product_id
where reportinggroup not in ('SME','RAMS','St George - Lloyds')
and trim(acct.LG_Account_L09_Name) in ('Loans','Deposits at amortised cost','Net interest income','Non-interest income')
and trim(acct.LG_Account_L08_Name) not in ('Provisions on Loans - IB','Value Transfer - Net II')
and prodgrp not in ('Capital Benefit','Customer Margin Other','Non Customer Margin')
group by 1,2,3,4,5
order by 1,2,3,4
