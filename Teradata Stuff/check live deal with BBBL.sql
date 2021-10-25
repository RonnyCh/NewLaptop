

-- step1 find all the live deals in new products
select 
instr_key,
metric_code,
case when lg_account_id = '410010' then 'Customer Interest'
when lg_account_id = '410135' then 'Interest Adj Collective Prov'
when lg_account_id in ('500017','501009') then 'Impairment'
when lg_account_id in ('492089','491089') then 'NCM - Swaps'
when lg_account_id in ('492040','491030') then 'NCM - Break Costs'
when metric_code in ('EOP','MAB') then 'Balance Sheet'
else 'Other' end as Description,
lg_account_id,
lg_product_id,
case when lg_product_id = '15145' then 'Variable'
else 'Fixed' end as ProductGrp,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','840000') then repctr.LG_Centre_L12_name
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
trim(repctr.LG_Centre_L12_name) as repctr12,
trim(repctr.LG_Centre_L11_name) as repctr11,
trim(repctr.LG_Centre_name),
sum(metric_amt)
from dwpviewa.fq_instr  a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where lg_product_id in ('15146','15147','15148','15145')
and reporting_mth = '201808'
and date between a.from_date and a.to_date
--and metric_code = 'PNL'
group by 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,4,5;




select 
metric_code,
case when lg_account_id = '410010' then 'Customer Interest'
when lg_account_id = '410135' then 'Interest Adj Collective Prov'
when lg_account_id in ('500017','501009') then 'Impairment'
when lg_account_id in ('492089','491089') then 'NCM - Swaps'
when lg_account_id in ('492040','491030') then 'NCM - Break Costs'
when metric_code in ('EOP','MAB') then 'Balance Sheet'
else 'Other' end as Description,
lg_account_id,
lg_product_id,
entry_code,
case when lg_product_id = '15145' then 'Variable'
else 'Fixed' end as ProductGrp,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','840000') then repctr.LG_Centre_L12_name
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
trim(repctr.LG_Centre_L12_name) as repctr12,
trim(repctr.LG_Centre_L11_name) as repctr11,
trim(repctr.LG_Centre_name),
sum(metric_amt)
from 
dwpviewa.FQ_Adjusted_Ledger a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where lg_product_id in ('15146','15147','15148','15145')
and reporting_mth = '201808'
and date between a.from_date and a.to_date
group by 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,4,5;




select 
metric_code,
acctl9,
ifrsgroup,
reportinggroup,
repctr12,
sum(p23)
from finiq.fiq_slicer_prod
where lg_product_id in ('15146','15147','15148','15145')
group by 1,2,3,4,5
order by 1,2,3,4,5


