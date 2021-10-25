

-- check where there are variances dr vs cr
select 
acct,
prod,
sum(debit) as dr,
sum(credit) as cr,
(dr - cr) as var
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth = '202007'
--and acct = '146200'
--and prod = '40109'
group by 1,2
having var <> 0




select 
accounting_date,
acct,
prod,
cent,
sum(debit) as dr,
sum(credit) as cr,
(dr - cr) as var
from
finiq.RAFC_sme_fq_adjusted_instr_v
where reporting_mth = '202007'
and acct = '202200'
and prod = '40109'
group by 1,2,3,4
--having var <> 0



--show view finiq.RAFC_sme_fq_adjusted_instr_v

--select * from finiq.sme_journal_mapping


select 
metric_code,
sme_debit_centre_id,
sme_account_id,
lg_product_id,
description,
--sme_credit_centre_id,
sum(metric_amt)
from
finiq.rafc_sme_fq_adjusted_instr
where  reporting_mth = '202007'
and lg_product_id = '40109'
and sme_account_id = '202200'
 --and sme_account_id in ('202200','421100','492408')
--and sme_credit_centre_id is null
--and reporting_centre_id = '848624'
group by 1,2,3,4,5




-- check credit
select 
metric_code,
reporting_centre_id,
sme_credit_centre_id,
sme_account_id,
lg_product_id,
description,
--sme_credit_centre_id,
sum(metric_amt)
from
finiq.rafc_sme_fq_adjusted_instr
where  reporting_mth = '202007'
and lg_product_id = '40109'
and sme_account_id = '202200'
 --and sme_account_id in ('202200','421100','492408')
--and sme_credit_centre_id is null
--and reporting_centre_id = '848624'
group by 1,2,3,4,5,6




