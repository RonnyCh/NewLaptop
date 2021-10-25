
-- step 1 drop prevfous table
drop table fq_ml;

-- step 2 create a temporary table
create volatile table FQ_ML as (
		SELECT 
		* from finiq.fq_manual_alloc) with no data
		PRIMARY INDEX ( Metric_Code ,LG_Entity_Id ,LG_Cost_Centre_Id ,
		LG_Account_Id ,LG_Product_Id ,LG_Relationship_Centre_Id ,LG_Location_Id ,
		LG_IntraGroup_Centre_Id ,LG_Movement_Id ,LG_Currency_Id ,Reporting_Centre_Id ,
		Reporting_Channel_Id ,RO_ID ,Reporting_Segment_Id ,Entry_Code ,
		Seq_No ,Reporting_Mth )
		ON COMMIT PRESERVE ROWS;


-- step 3 reverse the current manual load in production table zfq manual load
INSERT INTO  FQ_ML
				SELECT 
				Metric_Code                   
				,LG_Entity_Id                  
				,LG_Cost_Centre_Id             
				,LG_Account_Id                 
				,LG_Product_Id                 
				,LG_Relationship_Centre_Id     
				,LG_Location_Id                
				,Reporting_Centre_Id as LG_IntraGroup_Centre_Id       
				,LG_Movement_Id                
				,LG_Currency_Id                
				,Reporting_Centre_Id           
				,Reporting_Channel_Id          
				,RO_ID                        
				,Reporting_Segment_Id          
				,Entry_Code                    
				,'1' (NAMED Seq_No)  
				,Reporting_Mth                 
				,Bank_Group_Code               
				,Reporting_Status_Code
				,Statistical_Cnt            
				,sum(-Metric_Amt)
				,'999'  (NAMED Manual_Alloc_Group_No)
				,'Reverse' (NAMED Manual_Alloc_Desc)
				,Authorising_Employee_id
				,current_timestamp(0) - interval '24' hour (NAMED Authorising_Timestamp)
				,'Y' Authorising_Ind               
				FROM dwpviewa.ZFQ_Manual_Alloc   
				where reporting_mth = '201804'
				GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
				HAVING SUM(Metric_Amt) <> 0;


-- step 3 put the new data in
INSERT INTO FQ_ML
				select
				Metric_Code
				,'999' as LG_Entity_Id
				,LG_Cost_Centre_Id
				,LG_Account_Id
				,LG_Product_Id
				,Reporting_Centre_Id as LG_Relationship_Centre_Id
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
				,'I' (NAMED Reporting_Status_Code)  
				,0.00 (NAMED Statistical_Cnt)         
				,sum(a.tot_metric_amt) as metric_amt
				,'999'  (NAMED Manual_Alloc_Group_No)
				,'New ' (NAMED Manual_Alloc_Desc)
				,'M118954' (NAMED Authorising_Employee_id)        
				,current_timestamp(0) - interval '24' hour (NAMED Authorising_Timestamp         )      
				,'N' (NAMED Authorising_Ind)   
				FROM finiq.FQ_ADJ_LGR_RPT a
				where reporting_mth = '201804'
				and entry_code not in ('INS','ADJ','NON')
				GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
				HAVING metric_amt <> 0;



-- step 5  group everything so the delta can be worked on, use treshold of 100 dollars
insert into fq_ml
select
Metric_Code                   
,'999' as LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,reporting_centre_id as LG_Relationship_Centre_Id     
, '00' (Named LG_Location_Id)   
, '000000' (Named LG_IntraGroup_Centre_Id) 
, '00' (Named LG_Movement_Id)
, 'AUD' (Named LG_Currency_Id)
,Reporting_Centre_Id
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLN' (NAMED Entry_Code)                    
,'3' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(metric_amt) as amt   
,'101'  (NAMED Manual_Alloc_Group_No)
,'Delta prod against sandpit' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) - interval '24' hour (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from fq_ml
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
having abs(amt) > 100;

-- step 6 delete the previous data at granular level since they have now been aggregated.
delete from fq_ml
where manual_alloc_desc <> 'Delta prod against sandpit';

-- step 7 force the overall numbers to make sure netting off to zero due to small discrepancies and threshold\
create volatile table grp as (
select
reporting_mth,
metric_code, 
lg_cost_centre_id,
lg_account_id, 
lg_product_id,
sum(metric_amt) as amount
from fq_ml
group by 1,2,3,4,5
having amount <> 0) with data
Primary index (metric_code, lg_account_id, lg_product_id)
on commit preserve rows ;


insert into fq_ml
select
Metric_Code                   
,'999' as LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Cost_Centre_Id  as LG_Relationship_Centre_Id     
, '00' (Named LG_Location_Id)   
, '000000' (Named LG_IntraGroup_Centre_Id) 
, '00' (Named LG_Movement_Id)
, 'AUD' (Named LG_Currency_Id)
,LG_Cost_Centre_Id  as Reporting_Centre_Id
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLN' (NAMED Entry_Code)                    
,'4' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(-amount) as amt   
,'101'  (NAMED Manual_Alloc_Group_No)
,'Delta prod against sandpit' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) - interval '24' hour (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from grp
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26








