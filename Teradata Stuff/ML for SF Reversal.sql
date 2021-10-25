

/* missing allocation

use prior month rates and spread the non (use imran table to do this)

you should know whicl alloc id is missing....
just use imran table to work out the rates for those missing allocation id and re-run the table
maybe create a dummy table like alloc engine with ALC/ALT
*/

/* work out ALC based on prior month */

drop table alc;
drop table fq_alc;
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
left join dwpviewa.LG_Hier_Centre as repctr
on a.lg_relationship_centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where trim(repctr.LG_Centre_L12_key) = 'SG1479'
and reporting_mth = '201811'
and date between a.from_date and a.to_date
group by 1,2,3,4,5,6,7,8,9
)
with data
primary index (metric_code, lg_entity_id, lg_cost_centre_id, lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;



insert into finiq.tmp_FQ_Alloc
select
Reporting_Mth                 
,'ALC' as Entry_Code                    
,Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,Reporting_Centre_ID           
,'99' as Alloc_Rule_Id                 
,'SF Reversal' as Alloc_Description             
,sum(-Metric_Amt)                 
from fq_alc
group by 1,2,3,4,5,6,7,8,9,10,11 
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
,LG_Relationship_Centre_Id     as Reporting_Centre_ID           
,'99' as Alloc_Rule_Id                 
,'SF Reversal'
,sum(Metric_Amt) as metric_amt           
from fq_alc a
group by 1,2,3,4,5,6,7,8,9,10,11 ;




-- report

select 
a.metric_code,
trim(repctr.LG_Centre_L13_name), 
trim(repctr.LG_Centre_L12_name),
trim(repctr.LG_Centre_L11_name),
trim(repctr.LG_Centre_L10_name),
sum(case when a.entry_code = 'ALC' then a.tot_metric_amt else 0 end) as FR_,
sum(case when a.entry_code = 'ALT' then a.tot_metric_amt else 0 end) as TO_
from  finiq.tmp_FQ_Alloc a
left join dwpviewa.LG_Hier_Centre as repctr
on a.reporting_centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
group by 1,2,3,4,5
order by 1,2,3,4,5;

-- report2
select
metric_code, 
trim(relctr.LG_Centre_L11_name),
sum(metric_amt) as metric_amt
from dwpviewa.FQ_Adjusted_Ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as relctr
on a.reporting_centre_id = relctr.LG_Centre_ID
and date between relctr.from_date and relctr.to_date
where trim(repctr.LG_Centre_L12_key) = 'SG1479'
and reporting_mth = '201811'
and date between a.from_date and a.to_date
group by 1,2;



-- delete previous entries
delete
from finiq.FQ_MANUAL_ALLOC 
where reporting_mth = '201811'
and manual_alloc_group_no = '99'
and manual_alloc_desc = 'SF Reversal';


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
,'000000' as LG_IntraGroup_Centre_Id
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
from finiq.tmp_FQ_Alloc;




