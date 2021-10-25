


-- create temp table for mapping out the allocation rule
drop table ma;
create volatile table MA as
(
SELECT
CASE WHEN ALLOC_DESCRIPTION = 'BSA TD' THEN 103
WHEN ALLOC_DESCRIPTION = 'Bill Reclass Issue' THEN 104
ELSE CAST(ALLOC_RULE_ID AS INT) END AS ALLOC_RULE_ID,
ALLOC_DESCRIPTION
FROM finiq.FQ_ADJ_LGR_RPT
WHERE ENTRY_CODE IN ('ALC','ALT')
AND REPORTING_MTH = '201804'
GROUP BY 1,2)
with data
Primary index (ALLOC_RULE_ID, ALLOC_DESCRIPTION)
ON COMMIT PRESERVE ROWS;


/*  
after running alloc engine, probably try to check against prior months to see there are no missing allocations
*/
select
a.metric_code,
a.alloc_rule_id,
ma.ALLOC_DESCRIPTION,
trim(acct.LG_Account_L09_Name) as AcctL9,
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
else trim(repctr.LG_Centre_L13_name) end as ReportingGroup,
sum(case when reporting_mth = '201803' then metric_amt else 0 end) as P1,
sum(case when reporting_mth = '201804' then metric_amt else 0 end) as P2,
sum(case when reporting_mth = '201806' then metric_amt else 0 end) as P3
from 
(
select
a.reporting_mth
,'IMRAN' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.entry_code
,cast(a.alloc_rule_id as int) as alloc_rule_id
,a.tot_metric_amt as metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201803','201804')     -- check against the last 2 months or benchmark any two months
AND ENTRY_CODE IN ('ALC','ALT')
union all
select
a.reporting_mth
,'FINIQ_Prod' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.entry_code
,a.alloc_rule_id
,a.Alloc_Metric_Amt     -- this is current month alloc engine
from ALLOC_ENG.FQ_ALLOCATION_TODAY a  
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
left join MA ma
on ma.alloc_rule_id = a.alloc_rule_id
where reportinggroup not in ('SME','RAMS','St George - Lloyds','Group Operations')
and trim(acct.LG_Account_L09_Name) in ('Loans','Deposits at amortised cost','Net interest income','Non-interest income')
and trim(acct.LG_Account_L08_Name) not in ('Provisions on Loans - IB','Value Transfer - Net II')
and prodgrp not in ('Capital Benefit','Customer Margin Other','Non Customer Margin')
--and a.alloc_rule_id in ('235','335')
group by 1,2,3,4,5,6
order by 1,2,3,4,5
having P3 = 0;





/*  
check the comparison when alloc exists in latest month to see comparison
*/
select
a.metric_code,
a.alloc_rule_id,
ma.ALLOC_DESCRIPTION,
trim(acct.LG_Account_L09_Name) as AcctL9,
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
else trim(repctr.LG_Centre_L13_name) end as ReportingGroup,
sum(case when reporting_mth = '201803' then metric_amt else 0 end) as P1,
sum(case when reporting_mth = '201804' then metric_amt else 0 end) as P2,
sum(case when reporting_mth = '201806' then metric_amt else 0 end) as P3
from 
(
select
a.reporting_mth
,'IMRAN' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.entry_code
,cast(a.alloc_rule_id as int) as alloc_rule_id
,a.tot_metric_amt as metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201803','201804')  -- check against the last 2 months
AND ENTRY_CODE IN ('ALC','ALT')
union all
select
a.reporting_mth
,'FINIQ_Prod' as tblName
,metric_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.entry_code
,a.alloc_rule_id
,a.Alloc_Metric_Amt        -- this is current month alloc engine
from ALLOC_ENG.FQ_ALLOCATION_TODAY a
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
left join MA ma
on ma.alloc_rule_id = a.alloc_rule_id
where reportinggroup not in ('SME','RAMS','St George - Lloyds','Group Operations')
and trim(acct.LG_Account_L09_Name) in ('Loans','Deposits at amortised cost','Net interest income','Non-interest income')
and trim(acct.LG_Account_L08_Name) not in ('Provisions on Loans - IB','Value Transfer - Net II')
and prodgrp not in ('Capital Benefit','Customer Margin Other','Non Customer Margin')
--and a.alloc_rule_id in ('235','335')
group by 1,2,3,4,5,6
order by 1,2,3,4,5
having P3 <>  0;




/* check in IMRAN table to see NON vs ALC to make sure NON is clear off */
select
a.metric_code, 
a.alloc_rule_id,
a.ALLOC_DESCRIPTION,
sum(tot_metric_amt) as metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201805')
AND ENTRY_CODE IN ('ALC','NON')
and alloc_rule_id not in ('x','401')
group by 1,2,3
order by 1,2
having abs(metric_amt) > 100




