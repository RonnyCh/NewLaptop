


create volatile table tmp as (
select 
a.metric_code,
a.lg_account_id, 
a.lg_product_id, 
a.reporting_centre_id
from finiq.FQ_TM1_Final a
where a.dist_centre_id = '848880'
and a.agg_account_id = '148201'
and reporting_mth = '201909'
group by 1,2,3,4) with data
primary index (metric_code, lg_account_id, lg_product_id, reporting_centre_id)
on commit preserve rows;



select * from finiq.fiq_slicer_prod
where lg_account_id in (select lg_account_id from tmp group by 1)
and lg_product_id in (select lg_product_id from tmp group by 1)
and reporting_centre_id in (select reporting_centre_id from tmp group by 1)
