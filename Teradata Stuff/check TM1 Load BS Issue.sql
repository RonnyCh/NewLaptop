






select
Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,LG_Location_Id                
,'000000' as LG_IntraGroup_Centre_Id       
,LG_Movement_Id                
,LG_Currency_Id                
,Reporting_Centre_Id           
,'00' as Reporting_Channel_Id          
,RO_ID                         
,'0' as Reporting_Segment_Id          
,sum(case when tmp.reporting_mth = '201809' then tmp.amount else 0 end) as LastMth
,sum(case when tmp.reporting_mth = '201810' then tmp.amount else 0 end) as ThisMth
,(ThisMth-LastMth) as var
from
(select
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
,Reporting_Centre_Id           
,Reporting_Channel_Id          
,RO_ID                         
,Reporting_Segment_Id          
,Reporting_Mth                 
,Metric_Amt   as amount                 
,Metric_Type                   
from finiq.fq_consol_ledger a
where a.reporting_mth in ('201810')
and source_code in ('TO','FROM')
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
,Reporting_Centre_Id           
,Reporting_Channel_Id          
,RO_ID                         
,Reporting_Segment_Id          
,Reporting_Mth                 
,Metric_Amt                    
,Metric_Type          
from finiq.fq_consol_ledger a
where a.reporting_mth in ('201809')
and source_code in ('TO','FROM')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where trim(repctr.LG_Centre_L14_key) = 'RB4152'
and metric_code = 'EOP'
--and tmp.lg_account_id = '146207'
--and tmp.lg_product_id = '22443'
--and tmp.reporting_centre_id = '849275'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
having  ThisMth = 0 and LastMth <> 0

