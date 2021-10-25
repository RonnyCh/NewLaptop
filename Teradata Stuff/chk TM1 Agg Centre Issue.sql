
drop table tmp2;

create volatile table tmp2 as (
select 
reporting_centre_id,
dist_centre_id,
trim(repctr.lg_centre_l13_name) as rep13,
trim(repctr.lg_centre_l12_name) as rep12
from finiq.FQ_TM1_Final a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where a.reporting_mth in ('201902')
--and trim(lg_centre_l13_name) in ('Bank SA - Consumer','Bank of Melbourne - Consumer','St. George Retail')
group by 1,2,3,4) with data
primary index (reporting_centre_id, dist_centre_id)
on commit preserve rows;


-- find the differences
select 
a.*, 
trim(repctr.lg_centre_l13_name) as rep13_agg,
trim(repctr.lg_centre_l12_name) as rep12_agg
from tmp2 a
left join dwpviewa.LG_Hier_Centre as repctr
on a.dist_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where trim(repctr.lg_centre_l12_name) <> a.rep12