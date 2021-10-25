
--drop table tmp;

create volatile table tmp as (
select 
distinct
PARENT10_ID as parent_id,
'Parent05' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
child_ID as Parent_ID,
'ChildID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT2_ID as Parent_ID,
'Parent13' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT3_ID,
'Parent12' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT4_ID,
'Parent11' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT5_ID,
'Parent10' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT6_ID,
'Parent09' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT7_ID,
'Parent08' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT8_ID,
'Parent07' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
union all
select 
distinct
PARENT9_ID,
'Parent06' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
) with data
primary index(parent_id)
on commit preserve rows