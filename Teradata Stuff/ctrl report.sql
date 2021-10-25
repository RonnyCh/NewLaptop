


--drop table tmp;

create volatile table tmp as (
select 

a.reporting_mth,
case when a.bal_type_code = 'BAL' then 'EOP'
when a.bal_type_code = 'MAB' then 'MAB'
when a.bal_type_code in ('CCF','DCF','FEE','IEX','IIN') then 'PNL'
else 'Other' end as Metric_Code,
'INS' as Entry_Code,
TRIM(acct.LG_Account_L09_Name) as acctl9 ,
TRIM(acct.LG_Account_L08_Name) as acctl8,
trim(prod.LG_Product_L10_Name) as ProdL10,
trim(repctr.LG_Centre_L14_name) as Division,
trim(repctr.LG_Centre_L13_name) as L13,
flag,
a.lg_account_id,
a.lg_product_id,
sum(metric_amt) as amount
from
(select
trim(mar.parent8_name) as MAR
,a.to_date as reporting_mth 
,a.acctg_acct_id as lg_account_id
,a.acctg_pdct_id as lg_product_id
,a.acctg_cntr_id as lg_cost_centre_id
,a.rpt_centre_id as reporting_centre_id
,case when a.bus_seg_code = '' then 'Non_Micro_SME' else 'Micro_SME' end as flag
,a.bal_type_code
,sum(a.bal_amt) AS metric_amt
from
EWP1VAFCA.RAFC_Armt_GL_Compnt_Mth a
left join dwpviewa.LG_Hier_Centre as repctr
on a.rpt_centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.acctg_acct_id
where a.to_date in (1200131)
--and a.entry_code not in ('ALC','ALT')
and trim(repctr.LG_Centre_L14_name) = 'Consumer'
and MAR <> 'Non Customer Margin'
and a.Armt_Key in
(sel distinct aal.armt_key
from dwpviewa.CIS_Cust_Outline_SME CCOS
join dwpviewa.Acct_CIS_Cust_Link accl
    on accl.cis_key = ccos.cis_key
    and 1200131 between accl.from_date and accl.to_date
    and accl.cust_role_code = 'PRN'
join dwpviewa.Acct_Armt_Link aal
    on accl.acct_key = aal.acct_key
    and 1200131 between aal.from_date and aal.to_date
where 1200131 between ccos.from_date and ccos.to_date) 
group by 1,2,3,4,5,6,7,8) a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
--where a.lg_account_id = '410010'
--where division =  'Consumer Bank'
group by 1,2,3,4,5,6,7,8,9,10,11) with data
primary index (lg_account_id, lg_product_id)
on commit preserve rows




