

-- build dataset
call finiq.rafc_sme_adj_led('20200531')


-- check where there are variances dr vs cr
select 
acct,
prod,
sum(debit) as dr,
sum(credit) as cr,
(dr - cr) as var
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth = '202003'
--and acct = '146200'
--and prod = '40109'
group by 1,2
having var <> 0



-- check ctr
select 
cent,
sum(case when reporting_mth = '202003' then debit else 0 end) as dr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as dr2,
sum(case when reporting_mth = '202003' then debit else 0 end) as cr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as cr2
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth in ('202003','202004')
--and acct = '146200'
--and prod = '40109'
group by 1;


-- chk acct
select 
acct,
sum(case when reporting_mth = '202003' then debit else 0 end) as dr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as dr2,
sum(case when reporting_mth = '202003' then debit else 0 end) as cr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as cr2
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth in ('202003','202004')
--and acct = '146200'
--and prod = '40109'
group by 1;



-- chk prod
select 
prod,
sum(case when reporting_mth = '202003' then debit else 0 end) as dr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as dr2,
sum(case when reporting_mth = '202003' then debit else 0 end) as cr1,
sum(case when reporting_mth = '202004' then debit else 0 end) as cr2
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth in ('202003','202004')
--and acct = '146200'
--and prod = '40109'
group by 1



