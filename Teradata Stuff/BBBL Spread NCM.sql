

-- step 1 create the rates based on instruments
create volatile table rate as (
select
a.metric_code,
a.reporting_centre_id, 
cast(a.amount as float)/cast(tot.amount as float) as alloc_rate
from
(
select 
a.metric_code,
reporting_centre_id,
sum(metric_amt) as amount
from dwpviewa.fq_adjusted_ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where a.reporting_mth in ('201906')
and date between a.from_date and a.to_date
and a.entry_code = 'INS'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')
group by 1,2
) a,
(
select 
a.metric_code,
sum(metric_amt) as amount
from dwpviewa.fq_adjusted_ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where a.reporting_mth in ('201906')
and date between a.from_date and a.to_date
and a.entry_code = 'INS'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')
group by 1
) tot
where a.metric_code = tot.metric_code)
with data
primary index (metric_code, reporting_centre_id)
on commit preserve rows;


--drop table fq_alc


-- grab the data from adjusted ledger from NON based on parameter above
create volatile table FQ_ALC as (
select 
a.reporting_mth,
a.metric_code,
'ALC' as entry_code,
a.lg_entity_id,
a.lg_cost_centre_id,
case when a.LG_Account_Id in ('491089','491030') then '410160'
 else '410190' end as lg_account_id, 
a.lg_product_id, 
LG_Relationship_Centre_Id,
a.reporting_centre_id,
sum(metric_amt) as metric_amt
from dwpviewa.FQ_Adjusted_Ledger a
where a.reporting_mth in ('201906')
and date between a.from_date and a.to_date
and a.reporting_centre_id = '844305'
and a.lg_product_id in ('15146','15147','15148')
and a.lg_account_id in ('492089','491089','492040','491030')
group by 1,2,3,4,5,6,7,8,9
)
with data
primary index (metric_code, lg_entity_id, lg_cost_centre_id, lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;



-- create final allocations
select
Reporting_Mth                 
,Entry_Code                    
,Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,Reporting_Centre_ID           
,'99' as Alloc_Rule_Id                 
,'BBBL Adjustment to spread the NCM' as Alloc_Description             
,-Metric_Amt                
from fq_alc
union all
select
Reporting_Mth                 
,'ALT' as Entry_Code                    
,a.Metric_Code                   
,LG_Entity_Id                  
,LG_Cost_Centre_Id             
,LG_Account_Id                 
,LG_Product_Id                 
,LG_Relationship_Centre_Id     
,b.Reporting_Centre_ID           
,'99' as Alloc_Rule_Id                 
,'BBBL Adjustment to spread the NCM'
,sum(Metric_Amt  * alloc_rate) as metric_amt           
from fq_alc a,
rate b
where a.metric_code = b.metric_code
group by 1,2,3,4,5,6,7,8,9,10,11