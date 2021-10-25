



-- check bill reclass
select 
acctl9,
entry_code,
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where metric_code = 'PNL'
and reportinggroup = 'St. George Group Business Bank'
and acctl9 = 'Net interest income'
and prodgrp = 'Business Finance'
group by 1,2
order by 2;



-- check 41403 (exception)
select 
'Check 41403 Exception',
metric_code,
lg_account_id,
entry_code,
repctr12,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_product_id in ('41403')
and reportinggroup in ('St. George Group Business Bank','Support')
--and entry_code in ('MLA','MLN')
group by 1,2,3,4,5
order by 1,2,3,4,5;




select 
'Check 41403 Exception',
metric_code,
lg_account_id,
reportinggroup,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_product_id in ('41403')
and reportinggroup in ('St. George Group Business Bank','Support')
--and entry_code in ('MLA','MLN')
group by 1,2,3,4
order by 1,2,3,4;


select 
'Check 41403 Exception Support Bal',
metric_code,
lg_account_id,
reportinggroup,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_product_id in ('41403')
and reportinggroup in ('Support')
--and entry_code in ('MLA','MLN')
group by 1,2,3,4
order by 1,2,3,4;

-- check adjustment issue ml  ( this is where the numbers sitting in SGB Bus Banking H/Office)

select 
'Check SGB H/OFF Issue',
metric_code,
entry_code,
repctr12,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_account_id = '202200'
and lg_product_id = '41359'
and reportinggroup = 'St. George Group Business Bank'
and repctr12 = 'SBG Business Banking Head Office'
--and entry_code in ('MLA','MLN')
group by 1,2,3,4
order by 1,2,3,4;


select 
'Check SGB H/OFF Issue',
metric_code,
repctr12,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_account_id = '202200'
and lg_product_id = '41359'
and reportinggroup = 'St. George Group Business Bank'
--and entry_code in ('MLA','MLN')
group by 1,2,3
order by 1,2,3;


-- check BBBL.--- reclass happens in BB H?offoce
select 
'Check BBBL Issue',
metric_code,
entry_code,
repctr12,
sum(p21),
sum(p22),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where lg_product_id in ('15146','15147','15148')
and reportinggroup = 'St. George Group Business Bank'
and metric_code = 'PNL'
--and entry_code in ('MLA','MLN')
group by 1,2,3,4
order by 1,2,3,4;




select 
'Check Sov IFRS Issue',
metric_code, 
prodgrp,
prodl09,
reportinggroup,
sum(p15),
sum(p23),
sum(p24)
from finiq.fiq_slicer_prod
where prodgrp = 'Auto Finance'
or ProdL09 = 'Equipment Finance'
and ifrsgroup <> 'Non IFRS'
--and entry_code = 'NON'
group by 1,2,3,4,5
order by 2,3,4,5


                      








