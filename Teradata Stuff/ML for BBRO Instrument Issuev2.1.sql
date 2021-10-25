



drop table tmp;


create volatile table tmp as (
-- step 1 grab the sept data
select
'FROM' as Alloc_Type
,instr_key
,Metric_Code
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
,SUM(-TOTAL_AMT) as amount
from dwpviewa.FQ_Adjusted_Instr
where 
instr_key in (select * from finiq.tmp 
)
and reporting_mth = '201810'
and date between from_date and to_date
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
having amount <> 0
) with data
PRIMARY INDEX ( Alloc_Type, Instr_Key, Metric_Code ,LG_Entity_Id ,LG_Cost_Centre_Id ,
LG_Account_Id ,LG_Product_Id ,LG_Relationship_Centre_Id ,LG_Location_Id ,
LG_IntraGroup_Centre_Id ,LG_Movement_Id ,LG_Currency_Id ,Reporting_Centre_Id ,
Reporting_Channel_Id ,RO_ID ,Reporting_Segment_Id ,Reporting_Mth )
on commit preserve rows;


-- only pick up SG1479 instrument
delete from tmp
where reporting_centre_id in (select lg_centre_id from dwpviewa.LG_Hier_Centre where trim(LG_Centre_L12_key) <> 'SG1479' and date between from_date and to_date)



insert into tmp
select 
'TO1' as Alloc_Type
,a.instr_key
,a.Metric_Code
,a.LG_Entity_Id
,a.LG_Cost_Centre_Id
,a.LG_Account_Id
,a.LG_Product_Id
,a.LG_Relationship_Centre_Id
,a.LG_Location_Id
,a.LG_IntraGroup_Centre_Id
,a.LG_Movement_Id
,a.LG_Currency_Id
,b.Reporting_Centre_Id
,a.Reporting_Channel_Id
,a.RO_ID
,a.Reporting_Segment_Id
,a.Reporting_Mth
,sum(-a.Amount) as Amount
from m118954.tmp a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
inner join  finiq.fq_map_old b
on a.instr_key = b.instr_key
where trim(repctr.LG_Centre_L12_key) = 'SG1479'
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17;



-- take care where rep ctr blank last month and replace with rel cente
insert into tmp
select 
'TO2' as Alloc_Type
,a.instr_key
,a.Metric_Code
,a.LG_Entity_Id
,a.LG_Cost_Centre_Id
,a.LG_Account_Id
,a.LG_Product_Id
,a.LG_Relationship_Centre_Id
,a.LG_Location_Id
,a.LG_IntraGroup_Centre_Id
,a.LG_Movement_Id
,a.LG_Currency_Id
,a.LG_Relationship_Centre_Id as Reporting_Centre_Id
,a.Reporting_Channel_Id
,a.RO_ID
,a.Reporting_Segment_Id
,a.Reporting_Mth
,sum(-a.Amount) as Amount
from m118954.tmp a
left join  finiq.fq_map_old b
on a.instr_key = b.instr_key
where b.Reporting_Centre_Id is null
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17;


-- change default centre 844304(retail) as agreed with Paul So
update tmp
set reporting_centre_id = '844304'
where reporting_centre_id in ('842105','848781','848788','848795','849584');


-- check from and to
select 
metric_code,
case when alloc_type in ('TO1','TO2') then 'TO' else alloc_type end as alloc_type,
sum(amount) as m
from
tmp
group by 1,2
order by 1,2;



-- find out which instrument causing issues
select 
instr_key,
lg_account_id,
sum(amount) as m
from
tmp
group by 1,2
having m <> 0;



-- create report to analyse overall number

select 
metric_code,
TRIM(acct.LG_Account_L09_Name) ,
TRIM(acct.LG_Account_L08_Name) ,
trim(prod.LG_Product_L09_Name),
case when alloc_type in ('TO1','TO2') then 'TO' else alloc_type end as alloc_type,
trim(repctr.LG_Centre_L14_name),
trim(repctr.LG_Centre_L12_name),
trim(repctr.LG_Centre_L11_name),
sum(amount)
from tmp a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
group by 1,2,3,4,5,6,7,8
order by 1,2,3,4,5,6,7,8;



delete from finiq.fq_manual_alloc
where reporting_mth = '201809'
and manual_alloc_desc = 'BBRO Instrument Reversal';



-- INSERT INTO ML TABLE
insert into finiq.FQ_MANUAL_ALLOC
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
,'MLA' as Entry_Code
,'1' (NAMED Seq_No)  
,Reporting_Mth
,'SBG' as Bank_Group_Code
,'Y' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)         
,sum(amount) as metric_amt
,99 as Manual_Alloc_Group_No
,'BBRO Instrument Reversal' as Manual_Alloc_Desc
,'M118954' (NAMED Authorising_Employee_id)        
,current_timestamp(0) (NAMED Authorising_Timestamp         )      
,'N' (NAMED Authorising_Ind)   
from tmp
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,13,14,15,16,17,18,19,20,22,23,24,25;