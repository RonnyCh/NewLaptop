select * from dwpviewa.FQ_Adjusted_Instr
where instr_key = 'STDA000000356659746'
and reporting_mth = '201809'
and date between from_date and to_date;




drop table finiq.fq_map_old;
drop table  finiq.fq_map_new


create table finiq.fq_map_new as (
select 
instr_key,
reporting_centre_id
from dwpviewa.FQ_Adjusted_Instr
where instr_key = 'STDA000000356659746'
and reporting_mth = '201809'
and date between from_date and to_date
group by 1,2) with data
primary index (instr_key,reporting_centre_id);


create table finiq.fq_map_old as (
select 
instr_key,
reporting_centre_id
from dwpviewa.FQ_Adjusted_Instr
where instr_key = 'STDA000000356659746'
and reporting_mth = '201808'
and 1180930 between from_date and to_date
group by 1,2) with data
primary index (instr_key,reporting_centre_id);


delete from  finiq.fq_map_old;
delete from  finiq.fq_map_new

 insert into finiq.fq_map_old
select 
instr_key,
reporting_centre_id
from dwpviewa.FQ_Adjusted_Instr
where 
instr_key in (select * from finiq.tmp)
and reporting_mth = '201808'
and 1180930 between from_date and to_date
group by 1,2;




insert into finiq.fq_map_new
select 
instr_key,
reporting_centre_id
from dwpviewa.FQ_Adjusted_Instr
where 
instr_key in (select * from finiq.tmp)
and reporting_mth = '201809'
and date between from_date and to_date
group by 1,2;




select 
a.instr_key,
a.reporting_centre_id as New_Ctr,
b.reporting_centre_id as Old_Ctr
from finiq.fq_map_new a
inner join finiq.fq_map_old b
on a.instr_key = b.instr_key
and a.reporting_channel_id = b.reporting_channel_id
where a.instr_key = 'SSOV00091772065'



select * from finiq.fq_map_new
where instr_key = 'SSOV00091772065'


select *
from dwpviewa.FQ_Adjusted_Instr
where instr_key = 'SSOV00091772065'
and reporting_mth = '201808'
and 1180930 between from_date and to_date
group by 1,2,3;

select *
from dwpviewa.FQ_Adjusted_Instr
where instr_key = 'SSOV00091772065'
and reporting_mth = '201809'
and date between from_date and to_date
group by 1,2,3


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
instr_key in (select * from finiq.tmp)
and reporting_mth = '201809'
and date between from_date and to_date
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
having amount <> 0
) with data
PRIMARY INDEX ( Alloc_Type, Instr_Key, Metric_Code ,LG_Entity_Id ,LG_Cost_Centre_Id ,
LG_Account_Id ,LG_Product_Id ,LG_Relationship_Centre_Id ,LG_Location_Id ,
LG_IntraGroup_Centre_Id ,LG_Movement_Id ,LG_Currency_Id ,Reporting_Centre_Id ,
Reporting_Channel_Id ,RO_ID ,Reporting_Segment_Id ,Reporting_Mth )
on commit preserve rows;



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
inner join  finiq.fq_map_old b
on a.instr_key = b.instr_key
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
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17






-- check from and to
select 
metric_code,
alloc_type,
sum(amount) as m
from
tmp
group by 1,2
order by 1,2



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
trim(repctr.LG_Centre_L13_name),
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
order by 1,2,3,4,5,6,7,8









select * from tmp 
where instr_key in ('STDA000000356615057')



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
inner join  finiq.fq_map_old b
on a.instr_key = b.instr_key
where a.instr_key in ('STDA000000356615057')
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17;

delete  from finiq.fq_map_old
where instr_key in ('STDA000000356615057')
and reporting_centre_id = '848359';


select * from tmp
where instr_key in ('STDA000000356615057')



