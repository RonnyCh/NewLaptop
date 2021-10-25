select
a.lg_product_id,
a.l10,
a.l9,
a.l8,
a.l7,
a.l6,
b.l10,
b.l9,
b.l8,
b.l7,
b.l6
from
(select 
lg_product_id,
lg_product_l10_key,
lg_product_l09_key,
lg_product_l08_key,
lg_product_l07_key,
lg_product_l06_key,
trim(lg_product_l10_name) as L10,
trim(lg_product_l09_name) as L9,
trim(lg_product_l08_name) as L8,
trim(lg_product_l07_name) as L7,
trim(lg_product_l06_name) as L6,
concat(trim(lg_product_id),trim(lg_product_l10_key),trim(lg_product_l09_key),trim(lg_product_l08_key),trim(lg_product_l07_key),trim(lg_product_l06_key)) as id
from dwpviewa.LG_Hier_Product
where date between from_date and to_date
and lg_product_l11_key = 'TPROD'
group by 1,2,3,4,5,6,7,8,9,10,11
) a,
(select 
lg_product_id,
lg_product_l10_key,
lg_product_l09_key,
lg_product_l08_key,
lg_product_l07_key,
lg_product_l06_key,
trim(lg_product_l10_name) as L10,
trim(lg_product_l09_name) as L9,
trim(lg_product_l08_name) as L8,
trim(lg_product_l07_name) as L7,
trim(lg_product_l06_name) as L6,
concat(trim(lg_product_id),trim(lg_product_l10_key),trim(lg_product_l09_key),trim(lg_product_l08_key),trim(lg_product_l07_key),trim(lg_product_l06_key)) as id
from dwpviewa.LG_Hier_Product
where 1190930 between from_date and to_date
and lg_product_l11_key = 'TPROD'
group by 1,2,3,4,5,6,7,8,9,10,11) b
where a.lg_product_id = b.lg_product_id
and a.id <> b.id
--and a.lg_centre_l14_key <> b.lg_centre_l14_key    --- use this fitler to filter down on which level you want to check
group by 1,2,3,4,5,6,7,8,9,10,11;