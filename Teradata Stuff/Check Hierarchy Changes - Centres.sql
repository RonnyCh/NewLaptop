select
a.lg_centre_id,
a.l14,
a.l13,
a.l12,
a.l11,
a.l10,
b.l14,
b.l13,
b.l12,
b.l11,
b.l10
from
(select 
lg_centre_id,
lg_centre_l14_key,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13,
trim(lg_centre_l12_name) as L12,
trim(lg_centre_l11_name) as L11,
trim(lg_centre_l10_name) as L10,
concat(trim(lg_centre_id),trim(lg_centre_l14_key),trim(lg_centre_l13_key),trim(lg_centre_l12_key),trim(lg_centre_l11_key),trim(lg_centre_l10_key)) as id
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5,6,7,8,9,10,11
) a,
(select 
lg_centre_id,
lg_centre_l14_key,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key,
trim(lg_centre_l14_name) as L14,
trim(lg_centre_l13_name) as L13,
trim(lg_centre_l12_name) as L12,
trim(lg_centre_l11_name) as L11,
trim(lg_centre_l10_name) as L10,
concat(trim(lg_centre_id),trim(lg_centre_l14_key),trim(lg_centre_l13_key),trim(lg_centre_l12_key),trim(lg_centre_l11_key),trim(lg_centre_l10_key)) as id
from dwpviewa.lg_hier_centre
where 1200331 between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5,6,7,8,9,10,11) b
where a.lg_centre_id = b.lg_centre_id
and a.id <> b.id
--and a.lg_centre_l14_key <> b.lg_centre_l14_key    --- use this fitler to filter down on which level you want to check
group by 1,2,3,4,5,6,7,8,9,10,11;