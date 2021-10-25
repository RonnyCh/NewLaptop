

/* missing allocation

use prior month rates and spread the non (use imran table to do this)

you should know whicl alloc id is missing....
just use imran table to work out the rates for those missing allocation id and re-run the table
maybe create a dummy table like alloc engine with ALC/ALT
*/

/* work out ALC based on prior month */

drop table alc;
drop table fq_alc;
drop table rate;
drop table finiq.tmp_FQ_Alloc;

CREATE TABLE finiq.tmp_FQ_Alloc ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Reporting_Mth CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      Entry_Code CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
      Metric_Code CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
      LG_Entity_Id CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
      LG_Cost_Centre_Id CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      LG_Account_Id CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      LG_Product_Id CHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC,
      LG_Relationship_Centre_Id CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      Reporting_Centre_ID VARCHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      Alloc_Rule_Id VARCHAR(10) CHARACTER SET UNICODE NOT CASESPECIFIC,
      Alloc_Description VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
      Tot_Metric_Amt DECIMAL(38,4))
PRIMARY INDEX ( Reporting_Mth ,Entry_Code ,Metric_Code ,LG_Entity_Id ,
LG_Cost_Centre_Id ,LG_Account_Id ,LG_Product_Id ,LG_Relationship_Centre_Id ,
Reporting_Centre_ID ,Alloc_Rule_Id );


-- create parameter table to determine code block to be picked up. You should idenfify whic allocation ids got errors in allocating engine first.
create volatile table ALC as (
select 
alloc_rule_id,
alloc_description,
metric_code,
lg_entity_id,
lg_cost_centre_id,
lg_account_id, 
lg_product_id, 
reporting_centre_id
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201804')
--AND ENTRY_CODE IN ('ALC','NON')
and a.alloc_rule_id in ('111','106')
and entry_code = 'ALC'
group by 1,2,3,4,5,6,7,8) with data
primary index (lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;

-- create rate table
create volatile table rate as (
select
a.alloc_rule_id,
a.reporting_centre_id, 
cast(a.amount as float)/cast(tot.amount as float) as alloc_rate
from
(select 
alloc_rule_id,
reporting_centre_id,
sum(tot_metric_amt) as amount
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201804')
and a.alloc_rule_id in ('111','106')
and entry_code = 'ALT'
group by 1,2) a,
(select 
alloc_rule_id,
sum(tot_metric_amt) as amount
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201804')
and a.alloc_rule_id in ('111','106')
and entry_code = 'ALT'
group by 1) tot
where a.alloc_rule_id = tot.alloc_rule_id
) with data
primary index (alloc_rule_id, reporting_centre_id)
on commit preserve rows;



-- grab the data from adjusted ledger from NON based on parameter above
create volatile table FQ_ALC as (
select 
a.reporting_mth,
b.alloc_rule_id,
b.alloc_description,
a.metric_code,
'ALC' as entry_code,
a.lg_entity_id,
a.lg_cost_centre_id,
a.lg_account_id, 
a.lg_product_id, 
LG_Relationship_Centre_Id,
a.reporting_centre_id,
sum(metric_amt) as metric_amt
from dwpviewa.FQ_Adjusted_Ledger a
left join alc b
on a.metric_code = b.metric_code
and a.lg_entity_id = b.lg_entity_id
and a.lg_cost_centre_id = b.lg_cost_centre_id
and a.lg_account_id = b.lg_account_id
and a.lg_product_id = b.lg_product_id
and a.reporting_centre_id = b.reporting_centre_id
where a.reporting_mth = '201805'
and date between a.from_date and a.to_date
and a.entry_code = 'NON'
and b.lg_account_id is not null
and b.lg_product_id is not null
and b.reporting_centre_id is not null
group by 1,2,3,4,5,6,7,8,9,10,11
)
with data
primary index (metric_code, lg_entity_id, lg_cost_centre_id, lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;


insert into finiq.tmp_FQ_Alloc
select
Reporting_Mth                 
,Entry_Code                    
,Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,Reporting_Centre_ID           
,Alloc_Rule_Id                 
,Alloc_Description             
,-Metric_Amt                
from fq_alc
union all
select
Reporting_Mth                 
,'ALT' as Entry_Code                    
,Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,b.Reporting_Centre_ID           
,a.Alloc_Rule_Id                 
,Alloc_Description             
,sum(Metric_Amt  * alloc_rate) as metric_amt           
from fq_alc a,
rate b
where a.alloc_rule_id = b.alloc_rule_id
group by 1,2,3,4,5,6,7,8,9,10,11 ;


-- delete previous entries
delete
from finiq.FQ_MANUAL_ALLOC 
where reporting_mth = '201805'
and manual_alloc_group_no in (select alloc_rule_id from finiq.tmp_FQ_Alloc group by 1)
and manual_alloc_desc in (select alloc_description from finiq.tmp_fq_alloc group by 1);


-- INSERT INTO ML TABLE
insert into finiq.FQ_MANUAL_ALLOC
select
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,LG_Account_Id
,LG_Product_Id
,LG_Relationship_Centre_Id
,'00' as LG_Location_Id
,Reporting_Centre_Id as LG_IntraGroup_Centre_Id
,'00' as LG_Movement_Id
,'AUD' as LG_Currency_Id
,Reporting_Centre_Id
,0 as Reporting_Channel_Id
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLA' as Entry_Code
,'1' (NAMED Seq_No)  
,Reporting_Mth
,'SBG' as Bank_Group_Code
,'Y' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)         
,TOT_METRIC_AMT as metric_amt
,alloc_rule_id as Manual_Alloc_Group_No
,alloc_description as Manual_Alloc_Desc
,'M118954' (NAMED Authorising_Employee_id)        
,current_timestamp(0) - interval '24' hour (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from finiq.tmp_FQ_Alloc
where reporting_mth = '201805';


-- review 
select
a.metric_code,
a.alloc_rule_id,
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
sum(case when reporting_mth = '201805' then metric_amt else 0 end) as CORRECTION
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
where a.reporting_mth in ('201803','201804')     -- check against the last 2 months
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
,cast(a.alloc_rule_id as int) as alloc_rule_id
,a.tot_Metric_Amt     -- this is current month alloc engine
from finiq.tmp_FQ_Alloc a  
where reporting_mth = '201805'
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
where reportinggroup not in ('SME','RAMS','St George - Lloyds','Group Operations')
and trim(acct.LG_Account_L09_Name) in ('Loans','Deposits at amortised cost','Net interest income','Non-interest income')
and trim(acct.LG_Account_L08_Name) not in ('Provisions on Loans - IB','Value Transfer - Net II')
and prodgrp not in ('Capital Benefit','Customer Margin Other','Non Customer Margin')
and a.alloc_rule_id in ('111','106')
group by 1,2,3,4,5
order by 1,2,3,4,5





