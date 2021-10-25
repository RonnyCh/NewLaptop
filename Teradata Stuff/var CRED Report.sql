
 select 
 --src_sys_code,
 --status,
 division_cpop,
 lg_product_l10_name,
--  lg_product_l08_name,
sum(credr_ecc) as ECC_CREDR,
sum(cpop_ecc) as ECC_CPOP,
(ECC_CPOP - ECC_CREDR) as Var_ECC,
 sum(credr_rwa) as RWA_CREDR,
 sum(cpop_rwa) as RWA_CPOP,
 (RWA_CPOP - RWA_CREDR) as var_RWA
 from finiq.COI_CREDR a
 left join dwpviewa.lg_hier_product prod
 on prod.lg_product_id = a.cpop_prod_code
 and date between prod.from_date and prod.to_date
 where division_cpop is not null
 and status = 'Found'
 group by 1,2
order by 1,2;





 select 
 --src_sys_code,
 --status,
 division_cpop,
 lg_product_l10_name,
--  lg_product_l08_name,
sum(credr_ecc) as ECC_CREDR,
sum(cpop_ecc) as ECC_CPOP,
(ECC_CPOP - ECC_CREDR) as Var_ECC,
 sum(credr_rwa) as RWA_CREDR,
 sum(cpop_rwa) as RWA_CPOP,
 (RWA_CPOP - RWA_CREDR) as var_RWA
 from finiq.COI_CREDR a
 left join dwpviewa.lg_hier_product prod
 on prod.lg_product_id = a.cpop_prod_code
 and date between prod.from_date and prod.to_date
 where division_cpop is not null
 and status <> 'Found'
 group by 1,2
order by 1,2;
 
 
 
 
 
 select * from tmp
 
 
 
 select * from finiq.COI_CREDR
 where instr_cpop = 'EIL00220120267299001'
 
 
 
 select * from 
 tmpMissing
 where gdw_src_sys_code ='SGD'
 
 
 
 
select 
AR_SOURCE_SYSTEM_KEY
,AR_SOURCE_SYSTEM_CODE
,b.cr_risk_asset_subclass_code
,a.PDCT_SOURCE_SYSTEM_KEY as credr_prod_code
,a.ECON_CAPL_AMT
,a.BASEL_RWA_AMT
from NW.DW_GRP_CR_RPRT_FACT a
left join NW.DW_CR_RISK_ASSET_SUBCLASS_DIM b
on b.CR_RISK_ASSET_SUBCLASS_key = a.CR_RISK_ASSET_SUBCLASS_key
and date '2021-02-28' between b.EFFV_FROM and b.EFFV_TO
where Month_Key = '202102'
--and sourced_from = 'RP-003'
and AR_SOURCE_SYSTEM_KEY = '5594775600001'
SCMSOEX5594775600001                     




sel
a.MONTH_KEY
,case when AR_SOURCE_SYSTEM_CODE in ('SDDA','SLIS','SSOV','SCFL','SCHS','SCRA') then AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY
else AR_SOURCE_SYSTEM_CODE||' '||AR_SOURCE_SYSTEM_KEY end as Acct_Key
,b.cr_risk_asset_subclass_code
,a.PDCT_SOURCE_SYSTEM_KEY as credr_prod_code
,a.ECON_CAPL_AMT
,a.BASEL_RWA_AMT
from NW.DW_GRP_CR_RPRT_FACT a
left join NW.DW_CR_RISK_ASSET_SUBCLASS_DIM b
on b.CR_RISK_ASSET_SUBCLASS_key = a.CR_RISK_ASSET_SUBCLASS_key
and date '2021-02-28' between b.EFFV_FROM and b.EFFV_TO
where Month_Key = '202102'
and sourced_from = 'ARFACT'
and AR_SOURCE_SYSTEM_CODE = 'EIL'
and AR_SOURCE_SYSTEM_KEY = '00220120267299001'

 