drop table newmap;
drop table fintbl;


create volatile table newmap as (
select 
child_id as Grp,
parent4_id as LOB
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all


select 
parent4_id,
parent4_id
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2


union all

select 
parent5_id,
parent4_id as ParentKey
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2
union all

select 
parent6_id,
parent4_id as ParentKey
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all

select 
parent7_id,
parent4_id as ParentKey
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all

select 
parent8_id,
parent4_id as ParentKey
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2


union all

select 
parent9_id,
parent4_id as ParentKey
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all

select 
parent10_id,
parent4_id as ParentKey 
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all

select 
parent11_id,
parent4_id as ParentKey 
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2

union all

select 
parent12_id,
parent4_id as ParentKey 
from dwpviewa.lg_hier
where segment_type = 'centre'
and parent1_id = 'CNTINT'
and parent3_id in ('RB4892','RB4152')
and date between from_date and to_date
group by 1,2


) with data
primary index (grp,lob)
on commit preserve rows;

create volatile table fintbl as (
select 
a.centreid,
a.currentlob,
a.newlob,
c.lob as CurL13,
b.lob as NewL13
from finiq.lobfeb22 a
left join newmap c
on a.currentlob = c.grp
left join newmap b
on a.newlob = b.grp
where  
--a.currentlob = 'rb7279'
a.newlob <> a.currentlob
and parentflag = 'P'
group by 1,2,3,4,5) with data
primary index (centreid)
on commit preserve rows;


create volatile table l13 as (
select 
lg_centre_l13_key as l13key,
trim(lg_centre_l13_name) as L13name
from
dwpviewa.lg_hier_centre b
where date between from_date and to_date
--and lg_centre_l13_key in ('187100','RB7341','RB7136','352268','RB7063','RB7053')
group by 1,2) with data
primary index (l13key)
on commit preserve rows;



select 
a.*,
case when b.l13key in ('187100','RB7341','RB7136','352268','RB7063','RB7053') then 'Impacted' else 'None' end as FromL13,
case when c.l13key in ('187100','RB7341','RB7136','352268','RB7063','RB7053') then 'Impacted' else 'None' end as ToL13,
b.l13name as FromName,
c.l13name as ToName,
case when froml13 = 'None' and tol13 = 'None' then 'Ignore' 
when fromname = toname then 'Ignore'
else 'Check' end as Filter
from fintbl a
left join l13 b
on b.l13key = a.curl13
left join l13 c
on c.l13key = a.newl13


