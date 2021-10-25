


drop table newmap;

create volatile table newMap as (
select 
child_id,
parent2_id as parent_key,
'Parent2' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent3_id as parent_key,
'Parent3' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent4_id as parent_key,
'Parent4' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent5_id as parent_key,
'Parent5' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent6_id as parent_key,
'Parent6' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent7_id as parent_key,
'Parent7' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent8_id as parent_key,
'Parent8' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent9_id as parent_key,
'Parent9' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent10_id as parent_key,
'Parent10' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
) with data
primary index(child_id,parent_key,id)
on commit preserve rows;



drop table oldmap;

create volatile table oldMap as (
select 
child_id,
parent2_id as parent_key,
'Parent2' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent3_id as parent_key,
'Parent3' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent4_id as parent_key,
'Parent4' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent5_id as parent_key,
'Parent5' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent6_id as parent_key,
'Parent6' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent7_id as parent_key,
'Parent7' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent8_id as parent_key,
'Parent8' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent9_id as parent_key,
'Parent9' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
union all
select 
child_id,
parent10_id as parent_key,
'Parent10' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Product'
and Parent1_Id = 'TPROD'
group by 1,2,3 
) with data
primary index(child_id,parent_key,id)
on commit preserve rows;


--run final report to see the movement 
select 
a.child_id,
a.id,
a.parent_key as Fr,
b.parent_key as To_
from oldmap a
left join 
newmap b
on a.child_id = b.child_id
where a.id = b.id
and a.child_id = b.child_id
and a.parent_key <> b.parent_key
group by 1,2,3,4








