



insert into finiq.fq_manual_alloc
-- step 1 apply the negative revenue back to distribution using instruments.
select
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,case when LG_Account_Id in ('491089','491030') then '410160'
 else '410190' end as lg_account_id 
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
,Entry_Code
,Seq_No  
,Reporting_Mth
,'SBG' as Bank_Group_Code
,'Y' (NAMED Reporting_Status_Code)  
,Statistical_Cnt         
,metric_amt
,'99' as Manual_Alloc_Group_No
,'BBBL Reclass' as Manual_Alloc_Desc
,'M118954' (NAMED Authorising_Employee_id)        
,current_timestamp(0) (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from dwpviewa.fq_adjusted_ledger a
where reporting_mth = '201906'
and date between a.from_date and a.to_date
and a.entry_code = 'INS'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')


union all


select
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,case when LG_Account_Id in ('491089','491030') then '410160'
 else '410190' end as lg_account_id 
,LG_Product_Id
,LG_Relationship_Centre_Id
,LG_Location_Id
,LG_IntraGroup_Centre_Id
,LG_Movement_Id
,LG_Currency_Id
,'844305' as Reporting_Centre_Id
,Reporting_Channel_Id
,RO_ID  
,Reporting_Segment_Id  
,Entry_Code
,Seq_No  
,Reporting_Mth
,'SBG' as Bank_Group_Code
,'Y' (NAMED Reporting_Status_Code)  
,Statistical_Cnt         
,sum(-metric_amt) as amount
,'99' as Manual_Alloc_Group_No
,'BBBL Reclass' as Manual_Alloc_Desc
,'M118954' (NAMED Authorising_Employee_id)        
,current_timestamp(0) (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from dwpviewa.fq_adjusted_ledger a
where reporting_mth = '201906'
and date between a.from_date and a.to_date
and a.entry_code = 'INS'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20

union all


--- run the second step to put the contra amount in consol so when plug runs, the BB Consol will be zero and SGB BB H/O will contain the numbers

select
Metric_Code
,LG_Entity_Id
,LG_Cost_Centre_Id
,case when LG_Account_Id in ('491089','491030') then '410160'
 else '410190' end as lg_account_id 
,LG_Product_Id
,'849466' as LG_Relationship_Centre_Id
,'00' as LG_Location_Id
,LG_IntraGroup_Centre_Id
,LG_Movement_Id
,LG_Currency_Id
,'849466' as Reporting_Centre_Id
,Reporting_Channel_Id
,'00000' as RO_ID  
,Reporting_Segment_Id  
,Entry_Code
,Seq_No  
,Reporting_Mth
,'SBG' as Bank_Group_Code
,'Y' (NAMED Reporting_Status_Code)  
,Statistical_Cnt         
,sum(metric_amt) as amount
,'99' as Manual_Alloc_Group_No
,'Second Step of BBBL Reclass' as Manual_Alloc_Desc
,'M118954' (NAMED Authorising_Employee_id)        
,current_timestamp(0) (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from dwpviewa.fq_adjusted_ledger a
where reporting_mth = '201906'
and date between a.from_date and a.to_date
and a.entry_code = 'INS'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
;
