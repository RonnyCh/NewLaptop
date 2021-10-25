

-- this is the key sql to check what's in acct fin lg link which will be picked up by FINIQ as balances
select 
a.*, b. mis_org_unit_id, c.lg_cost_centre_id, trim(prod.LG_Product_L08_Name) , trim(prod.LG_Product_Name) , trim(LG_Centre_L13_name), trim(LG_Centre_name) 
from dwpvtbla.Acct_Fin_LG_Link a
inner join dwpviewa.acct_mis b
on b.acct_key = a.acct_key
and date between b.from_date and b.to_date
inner join dwpviewa.LG_Entity_Centre_Map c
on c.lg_entity_id = a.lg_entity_id
and c.gl_org_unit_id = b.mis_org_unit_id
and date between c.from_date and c.to_date
left join dwpviewa.LG_Hier_Centre as ctr
on c.lg_cost_centre_id = ctr.LG_Centre_ID
and date between ctr.from_date and ctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
where a.lg_product_id in ('15146','15147','15148','15145')
and date between a.from_date and a.to_date
--and bal_amt <> 0;


-- finiq picks up data from SX for customer interest
select * from dwpvtbla.SX_Instruments_Fin
where sx_instr_key in (
'SLIS100431400001600',
'SLIS100431400000800',
'SLIS100331300000600',
'SLIS100231200000400',
'SLIS100231200001200')
order by 1,2










******************************

* Below code was just my playing around codes testing how it works for BBBL *

******************************



-- compared sx vs output in fq instrument
Sel 
a.sx_instr_key,
a.bal_amt,
a.NIM,
b.metric_amt as FIQ_NII
from DWT1VTBLA.SX_Instruments_Fin a
inner join DWt1vtbla.fq_instr b
on a.sx_instr_key = b.instr_key
where sx_instr_key IN (
'SLIS100231200027400',
'SLIS100431400002400',
'SLIS100531500015700',
'SLIS100131100013300')
and b.metric_code = 'PNL';

-- select all data in sx instrument
sel * from 
DWT1VTBLA.SX_Instruments_Fin where 
--mis_common_coa_id = 334700
process_date = 1180531;

-- select those acct key found in sx
 select 
instr_key,
case when lg_account_id = '410010' then 'Customer Interest'
else 'WIB Trf - NCM' end as Description,
lg_account_id,
sum(metric_amt)
from DWt1vtbla.fq_instr 
where instr_key IN (
'SLIS100231200027400',
'SLIS100431400002400',
'SLIS100531500015700',
'SLIS100131100013300')
and metric_code = 'PNL'
group by 1,2,3
order by 1,2,3;

-- select all account key not found in sx
select 
instr_key,
metric_code,
case when lg_account_id = '410010' then 'Customer Interest'
when lg_account_id = '410135' then 'Interest Adj Collective Prov'
when lg_account_id in ('500017','501009') then 'Impairment'
when metric_code in ('EOP','MAB') then 'Balance Sheet'
else 'WIB Trf - NCM' end as Description,
'Acct key not found in SX Instrument' as status,
lg_account_id,
sum(metric_amt)
from DWt1vtbla.fq_instr 
where lg_product_id in ('15146','15147','15148','15145')
--and metric_code = 'PNL'
and instr_key not IN (
'SLIS100231200027400',
'SLIS100431400002400',
'SLIS100531500015700',
'SLIS100131100013300')
group by 1,2,3,4,5
order by 1,2,3,4,5

