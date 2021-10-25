select 
sum(debit),
sum(credit)
from finiq.rafc_sme_fq_adjusted_instr_v
where reporting_mth = '202001'
and acct = '410010'




select 
sum(metric_amt)
From 
finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
and lg_account_id = '410010'







select 
lg_account_id,
sme_account_id,
sum(metric_amt)
From 
finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
and sme_account_id = '410010'
group by 1,2



select
lg_account_id,
sme_account_id,
sum(metric_amt)
From 
finiq.RAFC_sme_fq_adjusted_instr
where lg_account_id = '410010'
and reporting_mth = '202001'
group by 1,2






select
lg_account_id,
lg_product_id,
sum(metric_amt)
From 
finiq.RAFC_sme_fq_adjusted_instr
where lg_account_id = '410010'
and reporting_mth = '202001'
group by 1,2



select 
a.lg_account_id, 
a.lg_product_id,
b.lg_account_id,
b.lg_product_id,
sum(a.amount),
sum(b.metric_amt)
from m118954.tmp a
left join finiq.RAFC_sme_fq_adjusted_instr b
on a.lg_account_id = b.lg_account_id
and a.lg_product_id = b.lg_product_id
where b.lg_account_id = '410010'
and b.reporting_mth = '202001'
and b.lg_product_id = '41359'
group by 1,2,3,4






select
trim(mar.parent6_name) as MAR9,
trim(mar.parent8_name) as MARAACT,
a.lg_account_id,
a.lg_product_id,
sum(case when a.src = 'myjrnl' then amt else 0 end) as myjrnl,
sum(case when a.src <> 'myjrnl' then amt else 0 end) as nick,
(nick - myjrnl) as var
from
(select 
'myjrnl' as src,
lg_account_id, 
lg_product_id, 
sum(amount) as amt
from tmp
--where lg_account_id = '410010'
--and lg_product_id = '41359'
group by 1,2,3
union all
select 
'rafc' as src,
lg_account_id, 
lg_product_id, 
-sum(metric_amt)
from finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
--and lg_account_id = '410010'
--and lg_product_id = '41359'
group by 1,2,3) a
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
where lg_account_id = '146207'
group by 1,2,3,4
--having var <> 0






select * from finiq.FIQ_Ref_MARACT






select *
from finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
and lg_account_id like '6%'






select *
from finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
and lg_account_id = '146207'



select *
from finiq.rafc_sme_fq_adjusted_instr_v
where reporting_mth = '202001'
and acct = '146207'









select
trim(mar.parent6_name) as MAR9,
trim(mar.parent8_name) as MARAACT,
a.lg_account_id,
a.lg_product_id,
sum(case when a.src = 'myjrnl' then amt else 0 end) as myjrnl,
sum(case when a.src <> 'myjrnl' then amt else 0 end) as nick,
(nick - myjrnl) as var
from
(

select 
'myjrnl' as src,
acct as lg_account_id, 
prod as lg_product_id, 
sum(debit) as amt
from from finiq.rafc_sme_fq_adjusted_instr_v
where acct = '146207'
--and lg_product_id = '41359'
group by 1,2,3
union all
select 
'rafc' as src,
lg_account_id, 
lg_product_id, 
-sum(metric_amt)
from finiq.RAFC_sme_fq_adjusted_instr
where reporting_mth = '202001'
and lg_account_id = '146207'
and metric_code = 'EOP'
--and lg_product_id = '41359'
group by 1,2,3

) a
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
--where lg_account_id = '146207'
group by 1,2,3,4
--having var <> 0


