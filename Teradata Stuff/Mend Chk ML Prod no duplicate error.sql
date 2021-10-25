Select                               
FQA.Metric_Code,                     
FQA.LG_Entity_Id,                    
FQA.LG_Cost_Centre_Id,               
FQA.LG_Account_Id,                   
FQA.LG_Product_Id,                   
FQA.LG_Relationship_Centre_Id,       
FQA.LG_Location_Id,                  
FQA.LG_IntraGroup_Centre_Id,         
FQA.LG_Movement_Id,                  
FQA.LG_Currency_Id,                  
FQA.Reporting_Centre_Id,             
FQA.Reporting_Channel_Id,            
FQA.RO_ID,                           
FQA.Reporting_Segment_Id,            
FQA.Entry_Code,                      
FQA.Seq_No
From dwpatfqr.FQ_Manual_Alloc  FQA
where  trim(FQA.Entry_code) in ('MLA','MLC' , 'MLR')                
and reporting_mth = '201805'
--and fqa.lg_account_id = '146200'
--and fqa.lg_product_id = '11256'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
order by 1,2,3,4,5,6,7,8
having  Count(*)>1
