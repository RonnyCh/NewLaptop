
drop table tmp1;
drop table tmp2;

-- create volatile table for this month and last month
create volatile table tmp1 as (
select 
a.*
from DWPVTBLA.LG_Hier a
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT'))
with data
primary index(child_id,parent6_id,parent7_id)
on commit preserve rows;


create volatile table tmp2 as (
select 
a.*
from DWPVTBLA.LG_Hier a
where 1190331 between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT'))
with data
primary index(child_id,parent6_id,parent7_id)
on commit preserve rows;


-- view the report
-- if it can't find matches from parent 6 to 9, then it willl populate the results to the right... as null or question marks.

-- how to relate this to AB Maintenance....... If you see some null values on the right... that means something changing... hence need to drill
-- down more using the query below..... you can even go down to account level if required. 
-- you can run a query for that specific parent and see the changes over time.
select
a.parent6_id,
a.parent7_id,
a.parent8_id,
a.parent9_id,
b.parent6_id,
b.parent7_id,
b.parent8_id,
b.parent9_id
from
(select a.*, 'Current' as Status
from DWPVTBLA.LG_Hier a
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')) a
left join
(select a.*, 'Old' as Status
from DWPVTBLA.LG_Hier a
where 1180331 between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')) b
on a.parent6_id = b.parent6_id
and a.parent7_id = b.parent7_id
and a.parent8_id = b.parent8_id
and a.parent9_id = b.parent9_id
where b.parent6_id is null
--where a.parent8_id <> b.parent8_id
--or a.parent7_id <> b.parent7_id)
group by 1,2,3,4,5,6,7,8




