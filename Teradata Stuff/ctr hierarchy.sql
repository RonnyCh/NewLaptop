

create volatile table tmp as (
select
a.parent_id,
a.description as Latest,
b.description as LastMth,
case when Latest = LastMth then 'OK' else 'Issue' end Checking
from
(select 
distinct
'New' as status,
PARENT4_ID as parent_id,
'Parent04_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT5_ID as parent_id,
'Parent05_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT6_ID as parent_id,
'Parent06_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT7_ID as parent_id,
'Parent07_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT8_ID as parent_id,
'Parent08_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT9_ID as parent_id,
'Parent09_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'New' as status,
PARENT10_ID as parent_id,
'Parent10_ID' as description
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
) A
full join
(
select 
distinct
'Old' as status,
PARENT4_ID as parent_id,
'Parent04_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT5_ID as parent_id,
'Parent05_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT6_ID as parent_id,
'Parent06_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT7_ID as parent_id,
'Parent07_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT8_ID as parent_id,
'Parent08_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT9_ID as parent_id,
'Parent09_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
union all
select 
distinct
'Old' as status,
PARENT10_ID as parent_id,
'Parent10_ID' as description
from DWPVTBLA.LG_Hier
where ?Date between from_date and to_date
and segment_type = 'Centre'
AND PARENT1_ID IN ('CNTINT')
and child_id in (select child_id from dwpviewa.FQ_LG_Inclusions
where segment_type = 'Centre'
and date between from_date and to_date group by 1)
) B
on a.parent_id = b.parent_id
where a.parent_id is not null and a.parent_id <> ''
and checking = 'Issue') with data
primary index (parent_id)
on commit preserve rows;




-- show the results
select 
a.*, 
mp.l14,
mp.l13,
mp.l12
from tmp a
left join 
(select 
lg_centre_l02_key as parent_id,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13,
trim(lg_centre_l12_name) as L12
from
dwpviewa.lg_hier_centre b
where date between from_date and to_date
group by 1,2,3,4) mp
on mp.parent_id = a.parent_id
order by 5,6,7;


-- report based on normal hierarchy
select 
'New' as status,
lg_centre_l02_key as parent_id,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13,
trim(lg_centre_l12_name) as L12,
trim(lg_centre_l11_name) as L11,
trim(lg_centre_l10_name) as L10
from
dwpviewa.lg_hier_centre b
where date between from_date and to_date
and lg_centre_l02_key in (select parent_id from tmp group by 1)
group by 1,2,3,4,5,6,7
union all
select 
'Old' as status,
lg_centre_l02_key as parent_id,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13,
trim(lg_centre_l12_name) as L12,
trim(lg_centre_l11_name) as L11,
trim(lg_centre_l10_name) as L10
from
dwpviewa.lg_hier_centre b
where 1181031 between from_date and to_date
and lg_centre_l02_key in (select parent_id from tmp group by 1)
group by 1,2,3,4,5,6,7

