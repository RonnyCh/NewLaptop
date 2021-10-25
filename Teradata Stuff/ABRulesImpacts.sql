
drop table tbl;
drop table abrules;

create volatile table tbl as (
select
'CBPremium' as adj,
index1,
index2,
tocentre,
tocentreprincipalname as parentkey,
toscenario,
weight,
cast(toaccount as varchar(100)) as metric
from finiq.ab_adj_cbpremium
where tocentre <> 'None'
union all
select
'GrossUp' as adj,
index1,
index2,
tocentre,
tocentreprincipalname,
toscenario,
weight,
toproduct as metric
from  finiq.ab_adj_grossup
where tocentre <> 'None'
union all
select
'Journa1' as adj,
index1,
index2,
tocentre,
tocentreprincipalname,
toscenario,
weight,
toaccount
from finiq.ab_adj_journal1
where tocentre <> 'None') with data
primary index (adj,index1,index2,tocentre,parentkey,toscenario,metric)
on commit preserve rows;

create volatile table abrules as (
select
a.*,
case when substring(parentkey,1,2) = 'MI' then substring(parentkey,3,length(parentkey)) else parentkey end as newParentKey
from tbl a) with data
primary index (adj,index1,index2,tocentre,parentkey,toscenario,metric)
on commit preserve rows;

-- find the rules that have been impacted by the changes
select 
a.* 
from abrules a
left join finiq.lobfeb22 b
on a.newparentkey = b.centreid
where centreid is not null


