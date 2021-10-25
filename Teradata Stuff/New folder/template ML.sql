
delete from FINIQ.FQ_MANUAL_ALLOC
where reporting_mth in ('?RepMth')
and Manual_Alloc_Desc = 'CID Exclusion';


drop table finiq.tmp_CID;

create table finiq.tmp_CID as (
Sel
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,LG_Account_Id  
,LG_Product_Id    
,LG_Relationship_Centre_Id 
,LG_Location_Id   
,LG_IntraGroup_Centre_Id 
,'00' as LG_Movement_Id
,'AUD' as LG_Currency_Id
,Reporting_Centre_Id
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,Entry_Code               
,'1' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(metric_amt) (NAMED Metric_Amt)              
,'102'  (NAMED Manual_Alloc_Group_No)
,'CID Exclusion' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from
dwpviewa.fq_adjusted_ledger a
where 
(a.reporting_mth = '?RepMth' and ?fromDate between a.from_date and a.to_date) 
and a.entry_code not in ('ALC','ALT')
and a.lg_product_id in ('42124','45125')
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
union all
Sel
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,LG_Account_Id  
,LG_Product_Id    
,LG_Relationship_Centre_Id 
,LG_Location_Id   
,LG_IntraGroup_Centre_Id 
,'00' as LG_Movement_Id
,'AUD' as LG_Currency_Id
,Reporting_Centre_Id
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,Entry_Code                    
,'1' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(a.Alloc_Metric_Amt) (NAMED Metric_Amt)              
,'102'  (NAMED Manual_Alloc_Group_No)
,'CID Exclusion' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from
FINIQ_DEV.fq_allocation_runs a
where a.current_run='Y'
and a.reporting_mth in ('?RepMth')
and trim(a.Alloc_Rule_Id) not in ('9','12','15','56','57','82','201',3,6,18,21,24,27,30,33,77,78)
and a.lg_product_id in ('42124','45125')
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
) with data
primary index (lg_account_id, lg_product_id, reporting_centre_id);






insert into FINIQ.FQ_MANUAL_ALLOC
select 
Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,LG_Location_Id                
,LG_IntraGroup_Centre_Id       
,LG_Movement_Id                
,LG_Currency_Id                
,reporting_centre_id         
,Reporting_Channel_Id          
,RO_ID                         
,Reporting_Segment_Id          
,'MLN' as Entry_Code                    
,Seq_No                        
,Reporting_Mth                 
,Bank_Group_Code               
,Reporting_Status_Code         
,Statistical_Cnt               
,Metric_Amt * -1                    
,Manual_Alloc_Group_No         
,Manual_Alloc_Desc             
,Authorising_Employee_id       
,Authorising_Timestamp         
,Authorising_Ind               
from finiq.tmp_CID a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date		
union all
select 
Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,LG_Location_Id                
,LG_IntraGroup_Centre_Id       
,LG_Movement_Id                
,LG_Currency_Id                
,'112063' as Reporting_Centre_Id           
,Reporting_Channel_Id          
,RO_ID                         
,Reporting_Segment_Id          
,'MLN' as Entry_Code                    
,Seq_No                        
,Reporting_Mth                 
,Bank_Group_Code               
,Reporting_Status_Code         
,Statistical_Cnt               
,Metric_Amt                
,Manual_Alloc_Group_No         
,Manual_Alloc_Desc             
,Authorising_Employee_id       
,Authorising_Timestamp         
,Authorising_Ind               
from finiq.tmp_CID a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date


--drop table finiq.tmp_CID



