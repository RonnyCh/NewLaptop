sel  'PNL' (NAMED Metric_Code) 
,LG_Entity_Id
,LG_Cost_Centre_Id
,LG_Account_Id
,LG_Product_Id
,LG_Relationship_Centre_Id
,LG_Location_Id 
,LG_IntraGroup_Centre_Id
,LG_Movement_Id
,LG_Currency_Id
,LG_Cost_Centre_Id (NAMED Reporting_Centre_Id)
,0  (NAMED Reporting_Channel_Id)
,'0000000' (NAMED RO_ID)
,0 (NAMED Reporting_Segment_Id)
,'ALC' (NAMED Entry_Code)
,1 (NAMED Seq_No)
,201811 (NAMED Reporting_Mth)
,'SBG' (NAMED Bank_Group_Code)
,'I' (NAMED Reporting_Status_Code)
,0 (NAMED Statistical_Cnt)
,sum(Period_movement_Amt) (NAMED Metric_Amt)
,126 (NAMED Manual_Alloc_Group_No)
,'Cards Matrix' (NAMED Manual_Alloc_Desc)
,user (Named Authorising_Employee_id)
,current_timestamp(0)  (NAMED Authorising_Timestamp)      
,'Y' (NAMED Authorising_Ind)        
from dwpviewa.LG_Ledger                     
where date between from_date and to_date
and period_name = 'Nov-18'
--and period_name = 'Oct-18'
and LG_Account_Id in ('614310', '610833')
and LG_Cost_Centre_Id in ('218943', '218944')

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26;
 
                 
---DROP TABLE vt_Scheme;
CREATE VOLATILE TABLE vt_Scheme
(
Centre VARCHAR(6),
rate dec(6,4)
) ON COMMIT PRESERVE ROWS;;

INSERT INTO vt_Scheme select '848416' , 0.0306; /* ACT */ 
INSERT INTO vt_Scheme select '848315' , 0.1047; /* NSW Regional */
INSERT INTO vt_Scheme select '848059' , 0.3686; /* NSW Metro */
INSERT INTO vt_Scheme select '848729' , 0.1272; /* QLD */
INSERT INTO vt_Scheme select '848749' , 0.049; /* WA */
INSERT INTO vt_Scheme select '848554' , 0.215; /* WA */
INSERT INTO vt_Scheme select '848929' , 0.105; /* WA */


delete from finiq.fq_manual_alloc
where reporting_mth = '201812'
and Manual_Alloc_Desc = 'Cards Matrix';


insert into finiq.fq_manual_alloc
sel  'PNL' (NAMED Metric_Code) 
,LG_Entity_Id
,LG_Cost_Centre_Id
,LG_Account_Id
,LG_Product_Id
,LG_Relationship_Centre_Id
,LG_Location_Id
,LG_IntraGroup_Centre_Id
,LG_Movement_Id
,LG_Currency_Id
,vt.Centre (NAMED Reporting_Centre_Id)
,0  (NAMED Reporting_Channel_Id)
,'0000000' (NAMED RO_ID)
,0 (NAMED Reporting_Segment_Id)
,'ALC' (NAMED Entry_Code)
,1 (NAMED Seq_No)
,'201812' (NAMED Reporting_Mth)
,'SBG' (NAMED Bank_Group_Code)
,'I' (NAMED Reporting_Status_Code)
,0 (NAMED Statistical_Cnt)
,sum(Period_movement_Amt * vt.Rate) (NAMED Metric_Amt)
,126 (NAMED Manual_Alloc_Group_No)
,'Cards Matrix' (NAMED Manual_Alloc_Desc)
,user (Named Authorising_Employee_id)
,current_timestamp(0)  (NAMED Authorising_Timestamp)      
,'Y' (NAMED Authorising_Ind)        
from dwpviewa.LG_Ledger              
cross join vt_Scheme vt
where date between from_date and to_date
and period_name = 'Dec-18'
--and period_name = 'Oct-18'
and LG_Account_Id in ('614310', '610833')
and LG_Cost_Centre_Id in ('218943', '218944')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26;



