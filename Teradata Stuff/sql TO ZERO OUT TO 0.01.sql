

-- CREATE TEMP TABLE TO FIGURE OUT DATA THAT NEEDS TO BE ZERO OUT
create volatile table temp as(
select
metric_code
,lg_entity_id
,a.lg_cost_centre_id
,a.lg_account_id
,a.lg_product_id
,a.lg_relationship_centre_id
,a.lg_location_id
,a.lg_intragroup_centre_id
,a.lg_movement_id
,a.lg_currency_id
,a.reporting_centre_id
,a.reporting_channel_id
,a.reporting_segment_id
,a.manual_alloc_desc
,a.seq_no
,TRIM(acct.LG_Account_L09_Name) as Acctl9
,TRIM(acct.LG_Account_L08_Name) as Acctl8
,trim(repctr.LG_Centre_L14_name) as division
,case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','84000') then trim(repctr.LG_Centre_L12_name)
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup
,sum(case when tblname = 'Run1' then metric_amt else 0 end) as Run1
,sum(case when tblname = 'Run2' then metric_amt else 0 end) as Run2
,sum(case when tblname = 'Run3' then metric_amt else 0 end) as Run3
,case when run3 = 0 and run1 <> 0 then 'Select'
when run3=0 and run2<> 0 then 'Select'
else 'ignore' end as Filter
from
(
select
a.reporting_mth
,'Run1' as tblName
,metric_code
,lg_entity_id
,a.lg_cost_centre_id
,a.lg_account_id
,a.lg_product_id
,a.lg_relationship_centre_id
,a.lg_location_id
,a.lg_intragroup_centre_id
,a.lg_movement_id
,a.lg_currency_id
,a.reporting_centre_id
,a.reporting_channel_id
,a.reporting_segment_id
,substr(a.manual_alloc_desc,1,16) as manual_alloc_desc
,a.seq_no
,a.metric_amt as metric_amt
from dwpviewa.zfq_manual_alloc a
where a.reporting_mth in ('201807')
and process_Date = 1180807
union all
select
a.reporting_mth
,'Run2' as tblName
,metric_code
,lg_entity_id
,a.lg_cost_centre_id
,a.lg_account_id
,a.lg_product_id
,a.lg_relationship_centre_id
,a.lg_location_id
,a.lg_intragroup_centre_id
,a.lg_movement_id
,a.lg_currency_id
,a.reporting_centre_id
,a.reporting_channel_id
,a.reporting_segment_id
,substr(a.manual_alloc_desc,1,16) as manual_alloc_desc
,a.seq_no
,a.metric_amt as metric_amt
from dwpviewa.zfq_manual_alloc a
where a.reporting_mth in ('201807')
and process_Date = 1180808
union all
select
a.reporting_mth
,'Run3' as tblName
,metric_code
,lg_entity_id
,a.lg_cost_centre_id
,a.lg_account_id
,a.lg_product_id
,a.lg_relationship_centre_id
,a.lg_location_id
,a.lg_intragroup_centre_id
,a.lg_movement_id
,a.lg_currency_id
,a.reporting_centre_id
,a.reporting_channel_id
,a.reporting_segment_id
,substr(a.manual_alloc_desc,1,16) as manual_alloc_desc
,a.seq_no
,a.metric_amt as metric_amt
from dwpviewa.zfq_manual_alloc a
where a.reporting_mth in ('201807')
and process_Date = 1180810
) a
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
--where lg_account_id = '492408'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
--having run3 = 0 
--having var = 0
having filter = 'select') with data
on commit preserve rows;


-- INSERT DATA TO PRODUCTION  MANUAL TABLE
INSERT INTO dwpatfqr.FQ_MANUAL_ALLOC
select
Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Cost_Centre_Id      
,LG_Location_Id   
,LG_IntraGroup_Centre_Id 
,LG_Movement_Id
,LG_Currency_Id
,Reporting_Centre_Id
,Reporting_Channel_Id
,'1000000' (NAMED RO_ID) 
,Reporting_Segment_Id
,'MLA' (NAMED Entry_Code)          
,Seq_No  
,'201807' as Reporting_Mth 
,'SBG' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)
,0.00 (NAMED Statistical_Cnt)           
,0.01 as metric_amt   
,'101'  (NAMED Manual_Alloc_Group_No)
,'PUT DEFAULT VALUE TO 0.01 FOR DATA WITH NOTHING' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'Y' (NAMED Authorising_Ind)   
from temp;


-- INSERT DUMMY RECORD
  INSERT INTO dwpatfqr.fq_manual_alloc
				SELECT TOP 1
				Metric_Code                   
				,'800'  (NAMED LG_Entity_Id  )                
				,LG_Cost_Centre_Id             
				,LG_Account_Id                 
				,LG_Product_Id                 
				,LG_Relationship_Centre_Id     
				,LG_Location_Id                
				,LG_IntraGroup_Centre_Id       
				,LG_Movement_Id                
				,LG_Currency_Id                
				,Reporting_Centre_Id           
				,Reporting_Channel_Id          
				,RO_ID                         
				,Reporting_Segment_Id          
				,'ALC' (NAMED Entry_Code)                    
				,1 (NAMED Seq_No)               
				,Reporting_Mth                 
				,Bank_Group_Code               
				,'I'   (NAMED Reporting_Status_Code)
				,0 (NAMED Statistical_Cnt) 
				,0.01 (NAMED Metric_Amt      )              
				,'996'  (NAMED Manual_Alloc_Group_No         )
				,'Dummy rec' (NAMED Manual_Alloc_Desc             )
				,user (NAMED Authorising_Employee_id)
				,current_timestamp(0) (NAMED Authorising_Timestamp         )      
				,'Y' (NAMED Authorising_Ind   )            
				FROM finiq_dev.FQ_Allocation_today    
				