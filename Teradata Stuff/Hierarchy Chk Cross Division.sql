

-- step 1 create temp table to see if centres move between BB and CB
create volatile table tmp1 as (
select
a.child_id,
a.parent3_id as LastMth,   -- parent 3 is BB/CB level
b.parent3_id as ThisMth
from
(select 
child_id,
parent3_id
from 
DWPVTBLA.LG_Hier 
where 1190430 between from_date and to_date   -- check the date to prior month
and parent1_id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2) a
left join 
(select 
child_id,
parent3_id
from 
DWPVTBLA.LG_Hier 
where date between from_date and to_date
and parent1_id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2) b
on a.child_id = b.child_id
where a.parent3_id <> b.parent3_id
group by 1,2,3) with data
primary index(child_id)
on commit preserve rows;


-- step 2 run the report
select 
'Before' as status,
lg_centre_id,
trim(lg_centre_name) as lg_centre_name,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13
from dwpviewa.LG_Hier_Centre
--where lg_centre_id in ('144354','144355','144356','144384','144429')
where lg_centre_id in (select child_id from tmp1 group by 1)
and 1190430 between from_date and to_date        -- check the date to prior month
group by 1,2,3,4,5
union all
select 
'After',
lg_centre_id,
trim(lg_centre_name) as lg_centre_name,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13
from dwpviewa.LG_Hier_Centre
--where lg_centre_id in ('144354','144355','144356','144384','144429')
where lg_centre_id in (select child_id from tmp1 group by 1)
and date between from_date and to_date
group by 1,2,3,4,5
order by 2