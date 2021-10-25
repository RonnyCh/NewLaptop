



select
tmp.metric_code, 
tmp.lg_cost_centre_id,
tmp.lg_product_id,
sum(case when status = 'LastMth' then amt else 0 end) as LastMth,
sum(case when status <> 'LastMth' then amt else 0 end) as ThisMth,
(LastMth - ThisMth) as Var
from
(select 
'LastMth' as status,
metric_code, 
lg_cost_centre_id,
lg_product_id,
sum(period_amt) as amt
from dwpviewa.fin_iq_lg_ledger
where lg_account_id = '146207'
and reporting_mth in ('202002')
group by 1,2,3,4
union all
select 
'ThisMth' as status,
metric_code, 
lg_cost_centre_id,
lg_product_id,
sum(period_amt) as amt
from dwpviewa.fin_iq_lg_ledger
where lg_account_id = '146207'
and reporting_mth in ('202003')
group by 1,2,3,4) tmp
group by 1,2,3
order by 1,2,3
--and lg_cost_centre_id = '848328'