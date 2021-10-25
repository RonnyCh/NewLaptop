/*  
after running alloc engine, probably try to check against prior months to see there are no missing allocations
*/


DELETE 
FROM FINIQ.FQ_MANUAL_ALLOC
where manual_alloc_desc in ('Plug','Plug2')
and reporting_mth = '201805' ;


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
where a.reporting_mth in ('201905')
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
where a.reporting_mth in ('201905')
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
where a.reporting_mth in ('201905')
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


-- check the diff between imran vs the rec

select
tmp.lg_account_id,
tmp.lg_product_id,
sum(case when src = 'Imran' then amount else 0 end) as Imran,
sum(case when src = 'PLUG' then amount else 0 end) as PLUG,
(Imran - PLUG) as Var
from
(select 
'Imran' as src,
trim(repctr.LG_Centre_L14_name) as Division,
trim(acct.LG_Account_L09_Name) as AcctL9,
a.lg_account_id,
a.lg_product_id,
sum(tot_metric_amt) as amount
from
finiq.FQ_ADJ_LGR_RPT a
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where trim(acct.LG_Account_L09_Name) = 'Non-interest income'
and trim(repctr.LG_Centre_L14_name) = 'Business Bank'
and reporting_centre_id not in ('848702','848383','842009','842010','842205','842209','843880')
and reporting_mth = '201905'
group by 1,2,3,4,5
union all
select 
'PLUG' as src,
division,
acctl9,
lg_account_id,
lg_product_id,
sum(fiq) as amount
from fq_diff
where division = 'Business Bank'
and acctl9 = 'Non-interest income'
group by 1,2,3,4,5) tmp
group by 1,2
having abs(var) > 10




select 
'Imran' as src,
trim(repctr.LG_Centre_L14_name) as Division,
trim(acct.LG_Account_L09_Name) as AcctL9,
sum(tot_metric_amt) as amount
from
finiq.FQ_ADJ_LGR_RPT a
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where trim(acct.LG_Account_L09_Name) = 'Non-interest income'
and trim(repctr.LG_Centre_L14_name) = 'Business Bank'
and reporting_mth = '201905'
group by 1,2,3


select * from
finiq.FQ_ADJ_LGR_RPT
where reporting_mth = '201905'
and lg_account_id = '601202'
and reporting_centre_id not in ('848702','848383','842009','842010','842205','842209','843880')



insert into  FINIQ.FQ_MANUAL_ALLOC
Sel
Metric_Code
,'001' (Named LG_Entity_Id)
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named LG_Cost_Centre_Id)
, LG_Account_Id  
, LG_Product_Id    
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named LG_Relationship_Centre_Id) 
, '00' (Named LG_Location_Id)   
, '000000' (Named LG_IntraGroup_Centre_Id) 
, '00' (Named LG_Movement_Id)
, 'AUD' (Named LG_Currency_Id)
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named Reporting_Centre_Id)
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLN' (NAMED Entry_Code)                    
,'1' (NAMED Seq_No)  
,'201806' as Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(var) (NAMED Metric_Amt)              
,'101'  (NAMED Manual_Alloc_Group_No)
,'Plug' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from fq_DIFF A
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
having metric_amt <> 0;