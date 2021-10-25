


create volatile table ALC as (
select 
metric_code,
lg_account_id,
lg_product_id,
reporting_centre_id,
sum(p20) as amount
from finiq.fiq_slicer_prod
where reportinggroup = 'Support'
and lg_account_id in ('202200','421100')
and lg_product_id in ('41403')
and reporting_centre_id <> '000000'
group by 1,2,3,4)
with data
primary index (metric_code,lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;






create volatile table rate as (
select
a.reporting_centre_id, 
cast(a.amount as float)/cast(tot.amount as float) as alloc_rate
from
(select 
reporting_centre_id,
sum(p20) as amount
from finiq.fiq_slicer_prod
where reportinggroup <> 'Support'
and lg_account_id in ('202200')
and lg_product_id in ('41403')
and reporting_centre_id <> '000000'
and metric_code = 'MAB'
group by 1)  a,
(select 
sum(p20) as amount
from finiq.fiq_slicer_prod
where reportinggroup <> 'Support'
and lg_account_id in ('202200')
and lg_product_id in ('41403')
and reporting_centre_id <> '000000'
and metric_code = 'MAB')  tot)
with data
primary index (reporting_centre_id)
on commit preserve rows;


delete from finiq.tmp_fq_alloc;

insert into finiq.tmp_FQ_Alloc
select
'201905' as Reporting_Mth                 
,'ALC' as Entry_Code                    
,Metric_Code                   
,'999' as LG_Entity_Id                  
,reporting_centre_id as LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,reporting_centre_id as LG_Relationship_Centre_Id     
,Reporting_Centre_ID           
,99 as Alloc_Rule_Id                 
,'41403 Exception Issue' as Alloc_Description             
,-amount                
from alc
union all
select
'201905' as Reporting_Mth                 
,'ALT' as Entry_Code                    
,Metric_Code                   
,'999' as LG_Entity_Id                  
,b.reporting_centre_id as LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,b.reporting_centre_id as LG_Relationship_Centre_Id     
,b.Reporting_Centre_ID           
,99 as Alloc_Rule_Id                 
,'41403 Exception Issue' as Alloc_Description             
,sum(amount*alloc_rate)                 
from alc a,
rate b
--where a.reporting_centre_id = b.reporting_centre_id
group by 1,2,3,4,5,6,7,8,9,10,11 ;


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
where reporting_mth = '201905';

