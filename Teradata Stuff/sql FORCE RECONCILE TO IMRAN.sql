drop table tmp;


create volatile table tmp as (
select
a.reporting_mth,
a.metric_code,
TRIM(acct.LG_Account_L09_Name) as AcctL9 ,
TRIM(acct.LG_Account_L08_Name) as AcctL8,
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
repctr.LG_Centre_L14_name as Division,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','84000') then trim(repctr.LG_Centre_L12_name)
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
a.lg_account_id, 
a.lg_product_id,
a.reporting_centre_id,
case when a.entry_code in ('INS','ADJ','NON','ADJL') then 'ADJL' else 'MANL' end as revisedEntryCode,
sum(case when a.tblname = 'FIQ_Prod' then a.metric_amt else 0 end) as FIQProd,
sum(case when a.tblname = 'Consol' then a.metric_amt else 0 end) as FQ_Consol,
(FIQProd - FQ_Consol) as Var
from 
(
select
a.reporting_mth
,'FIQ_Prod' as tblName
,metric_code
,a.entry_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.tot_metric_amt as metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201807')
--and a.alloc_description not in ('Plug')
union all
select
a.reporting_mth
,'Consol' as tblName
,metric_code
,a.source_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.metric_amt as metric_amt
from dwpviewa.FQ_Consol_Ledger a
where a.reporting_mth in ('201807')
and date between from_date and to_date
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
left join finiq.fq_non_map mp
on mp.lg_account_id = a.lg_account_id 
and mp.lg_product_id = a.lg_product_id
where a.lg_cost_centre_id not in ('842009','842010','848702','848383','842186','844024')
and a.reporting_centre_id not in ('842009','842010','848702','848383','842186','844024')
and trim(acct.LG_Account_L09_Key) in ('ALOANS','INETII','NOINTE','LCUSDP') 
and trim(acct.LG_Account_L08_Key) not in ('ALPRO1') 
and reportinggroup not in ('RAMS','St George - Lloyds')
and a.entry_code <> 'AGGR'
group by 1,2,3,4,5,6,7,8,9,10,11
--order by 1,2,3,4
having abs(var) > 10
) with data
PRIMARY INDEX ( Metric_Code, LG_Account_ID, LG_Product_ID, Reporting_Centre_id )
on commit preserve rows;




INSERT INTO dwpatfqr.fq_manual_alloc
				select
				Metric_Code
				,'999' as LG_Entity_Id
				,Reporting_centre_id as LG_Cost_Centre_Id
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
				,'7' (NAMED Seq_No)  
				,Reporting_Mth
				,'SBG' as Bank_Group_Code
				,'I' (NAMED Reporting_Status_Code)  
				,0.00 (NAMED Statistical_Cnt)         
				,sum(a.var) as metric_amt
				,'999'  (NAMED Manual_Alloc_Group_No)
				,'FINAL ADJUSTMENT TO REC TO SANDPIT ' (NAMED Manual_Alloc_Desc)
				,'M118954' (NAMED Authorising_Employee_id)        
				,current_timestamp(0)  (NAMED Authorising_Timestamp         )      
				,'Y' (NAMED Authorising_Ind)   
				FROM tmp a
				where reporting_mth = '201807'
				GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
				HAVING metric_amt <> 0;


-- put conta


INSERT INTO dwpatfqr.fq_manual_alloc
select
				Metric_Code
				,'999' as LG_Entity_Id
				,Reporting_centre_id as LG_Cost_Centre_Id
				,LG_Account_Id
				,LG_Product_Id
				,Reporting_Centre_Id as LG_Relationship_Centre_Id
				,'00' as LG_Location_Id
				,Reporting_Centre_Id as LG_IntraGroup_Centre_Id
				,'00' as LG_Movement_Id
				,'AUD' as LG_Currency_Id
				,'000000' as Reporting_Centre_Id
				,0 as Reporting_Channel_Id
				,'1000000' (NAMED RO_ID)  
				,'20' (NAMED Reporting_Segment_Id)  
				,'MLA' as Entry_Code
				,'8' (NAMED Seq_No)  
				,Reporting_Mth
				,'SBG' as Bank_Group_Code
				,'I' (NAMED Reporting_Status_Code)  
				,0.00 (NAMED Statistical_Cnt)         
				,sum(-a.var) as metric_amt
				,'999'  (NAMED Manual_Alloc_Group_No)
				,'FINAL ADJUSTMENT TO REC TO SANDPIT ' (NAMED Manual_Alloc_Desc)
				,'M118954' (NAMED Authorising_Employee_id)        
				,current_timestamp(0)  (NAMED Authorising_Timestamp         )      
				,'Y' (NAMED Authorising_Ind)   
				FROM tmp a
				where reporting_mth = '201807'
				GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26
				HAVING metric_amt <> 0;






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





