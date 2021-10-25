

drop table fq_diff;

create volatile table FQ_Diff as (
select
a.metric_code,
trim(acct.LG_Account_L09_Name) as AcctL9,
trim(repctr.LG_Centre_L14_name) as Division,
lg_centre_l14_key ,
a.lg_cost_centre_id,
a.reporting_centre_id,
a.lg_account_id,
a.lg_product_id,
sum(case when tblname = 'FIQ' then metric_amt else 0 end) as FIQ,
sum(case when tblname = 'LG' then metric_amt else 0 end) as LG,
(LG - FIQ) as Var
from 
(
select
a.reporting_mth
,'FIQ' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.metric_amt as metric_amt
from dwpviewa.fq_Adjusted_ledger a
where a.reporting_mth in ('201907')
and date between a.from_date and a.to_date
and entry_code not in ('ALC','ALT')
UNION ALL
select
a.reporting_mth
,'FIQ' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.metric_amt as metric_amt
from FINIQ.FQ_MANUAL_ALLOC a
where a.reporting_mth in ('201907')
UNION ALL
select
a.reporting_mth
,'FIQ' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.alloc_metric_amt as metric_amt
from alloc_eng.FQ_ALLOCATION_TODAY a
UNION ALL
select
a.reporting_mth
,'lg' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.lg_cost_centre_id
,case when metric_code in ('PNL') then period_movement_amt else period_amt end as metric_amt
from dwpviewa.Fin_IQ_LG_Ledger a
where a.reporting_mth in ('201907')
) a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
WHERE trim(acct.LG_Account_L09_Name) in ('Loans','Deposits at amortised cost','Net interest income','Non-interest income')
and trim(acct.LG_Account_L08_Name) not in ('Provisions on Loans - IB','Value Transfer - Net II')
AND case when trim(acct.LG_Account_L08_Name)  = 'Capital Benefit' then 'Capital Benefit'
when trim(acct.LG_Account_L09_Name) = 'Non-interest income' then trim(acct.LG_Account_L08_Name)
when trim(prod.LG_Product_L08_Name) in ('Business Debit Card', 'Personal Credit Cards') and mar.Parent8_Name <> 'Non Customer Margin' then 'Cards'
when trim(prod.LG_Product_L08_Name)  in ('Personal Loans Revolving Credit','Personal Term Loans') and mar.Parent8_Name <> 'Non Customer Margin' then 'Personal Loans'
when  trim(prod.LG_Product_L08_Name)  = 'Auto Finance' and mar.Parent8_Name <> 'Non Customer Margin' then 'Auto Finance'
when trim(prod.LG_Product_L10_Name) in ('Personal Deposits', 'Business Deposits') and mar.Parent8_Name <> 'Non Customer Margin' then trim(prod.LG_Product_L09_Name)
when trim(prod.LG_Product_L10_Name) = 'Business Finance' and mar.Parent8_Name <> 'Non Customer Margin'  then trim(prod.LG_Product_L10_Name)
when mar.Parent8_Name = 'Non Customer Margin' then 'Non Customer Margin'
when trim(prod.LG_Product_L10_Name) in ('Total Product for TPROD Hierarchy') then 'Customer Margin Other'
else trim(prod.LG_Product_L10_Name)  end not in ('Capital Benefit','Customer Margin Other','Non Customer Margin')
and case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when a.reporting_centre_id in ('848702','848383','842009','842010','842205','842209','843880') then 'SME Alloc'
when repctr.LG_Centre_L12_Key in ('400150','840000') then repctr.LG_Centre_L12_name
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else trim(repctr.LG_Centre_L13_name) end  not in ('SME','RAMS','St George - Lloyds','SME Alloc')
and a.lg_cost_centre_id not in ('842009','842010','848702','848383','842186')
group by 1,2,3,4,5,6,7,8
) with data
Primary index (LG_Account_Id, LG_Product_Id, LG_Cost_Centre_id, Reporting_centre_id)
ON COMMIT PRESERVE ROWS;




select 
metric_code,
division,
acctl9,
sum(fiq),
sum(lg),
sum(var)
from fq_diff
where division in ('Business','Consumer')
group by 1,2,3
order by 1,2,3