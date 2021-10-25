select 
--Reporting_Centre__L11_Name,
case when metric_code = 'MAB' then 'Bal_Avg'
when metric_code = 'IEX' then 'Cust_Int'
when metric_code = 'CCF' then 'Cust_zCOF' else metric_code end as metric_code,
sum(case when reporting_mth = 1200430 then metric_amt else 0 end) as P1,
sum(case when reporting_mth = 1200531 then metric_amt else 0 end) as P2,
sum(case when reporting_mth = 1200630 then metric_amt else 0 end) as P3,
(p1-p2),
(p2-p3)
--TM/LM as pct
from test_env.tdro_fq_adjusted_instr
where reporting_mth in (1200531,1200430,1200630)
--and pct < 0.9
group by 1
order by 1