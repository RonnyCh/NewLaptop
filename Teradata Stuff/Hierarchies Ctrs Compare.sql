


-- check level 10
select
a.lg_centre_id,
a.lg_centre_l10_key as ThisMth,
b.lg_centre_l10_key as LastMth,
case when thismth <> lastmth then 'Diff' else 'Same' end as chk
from
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) a,
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where ?PriorMth between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) b
where a.lg_centre_id = b.lg_centre_id
and chk = 'Diff'
group by 1,2,3;


-- check level 11
select
a.lg_centre_id,
a.lg_centre_l11_key as ThisMth,
b.lg_centre_l11_key as LastMth,
case when thismth <> lastmth then 'Diff' else 'Same' end as chk
from
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) a,
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where ?PriorMth between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) b
where a.lg_centre_id = b.lg_centre_id
and chk = 'Diff'
group by 1,2,3;

-- check level 12
select
a.lg_centre_id,
a.lg_centre_l12_key as ThisMth,
b.lg_centre_l12_key as LastMth,
case when thismth <> lastmth then 'Diff' else 'Same' end as chk
from
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) a,
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where ?PriorMth between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) b
where a.lg_centre_id = b.lg_centre_id
and chk = 'Diff'
group by 1,2,3;


-- check level 13
select
a.lg_centre_id,
a.lg_centre_l13_key as ThisMth,
b.lg_centre_l13_key as LastMth,
case when thismth <> lastmth then 'Diff' else 'Same' end as chk
from
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) a,
(select 
lg_centre_id,
lg_centre_l13_key,
lg_centre_l12_key,
lg_centre_l11_key,
lg_centre_l10_key
from dwpviewa.lg_hier_centre
where ?PriorMth between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2,3,4,5) b
where a.lg_centre_id = b.lg_centre_id
and chk = 'Diff'
group by 1,2,3;