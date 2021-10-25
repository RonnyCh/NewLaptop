

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


-- create rate table
create volatile table rate as (
select
a.metric_code,
a.reporting_centre_id, 
cast(a.amount as float)/cast(tot.amount as float) as alloc_rate
from
(
select 
a.metric_code,
reporting_centre_id,
sum(metric_amt) as amount
from dwpviewa.fq_adjusted_ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where a.reporting_mth in ('201806')
and entry_code = 'INS'
and lg_product_id = '13363'
and lg_account_id = '202200'
--and repctr.lg_centre_l14_key = 'RB4892' 
group by 1,2
) a,
(
select 
a.metric_code,
sum(metric_amt) as amount
from dwpviewa.fq_adjusted_ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where a.reporting_mth in ('201806')
and entry_code = 'INS'
and lg_product_id = '13363'
and lg_account_id = '202200'
--and repctr.lg_centre_l14_key = 'RB4892' 
group by 1
) tot
where a.metric_code = tot.metric_code
) with data
primary index (metric_code, reporting_centre_id)
on commit preserve rows;



-- grab the data from adjusted ledger from NON based on parameter above
create volatile table FQ_ALC as (
select 
a.reporting_mth,
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
where lg_product_id = '41359'
and lg_account_id = '202200'
and lg_relationship_centre_Id = '846724'
and reporting_mth = '201806'
and date between a.from_date and a.to_date
group by 1,2,3,4,5,6,7,8,9
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
,'99' as Alloc_Rule_Id                 
,'ML for Adjustment' as Alloc_Description             
,-Metric_Amt                
from fq_alc
union all
select
Reporting_Mth                 
,'ALT' as Entry_Code                    
,a.Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,b.Reporting_Centre_ID           
,'99' as Alloc_Rule_Id                 
,'ML for Adjustment'
,sum(Metric_Amt  * alloc_rate) as metric_amt           
from fq_alc a,
rate b
where a.metric_code = b.metric_code
group by 1,2,3,4,5,6,7,8,9,10,11 ;


-- delete previous entries
delete
from finiq.FQ_MANUAL_ALLOC 
where reporting_mth = '201806'
and manual_alloc_group_no = '99'
and manual_alloc_desc = 'ML for Adjustment';


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
,current_timestamp(0) (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from finiq.tmp_FQ_Alloc
where reporting_mth = '201806';


