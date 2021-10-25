
select
--credr.acct_key as Instr_CREDR,
--cpop.account_id as Instr_CPOP,
credr.cr_risk_asset_subclass_code,
sum(credr.ECON_CAPL_AMT) as CREDR_ECC,
sum(cpop.ecc) as CPOP_ECC,
(CREDR_ECC - CPOP_ECC) as Var_ECC,
sum(credr.BASEL_RWA_AMT) as CREDR_RWA,
sum(cpop.rwa) as CPOP_RWA,
(CREDR_RWA - CPOP_RWA) as Var_RWA
from
(sel
a.MONTH_KEY
,AFL.Acct_Key
,b.cr_risk_asset_subclass_code
,a.ECON_CAPL_AMT
,a.BASEL_RWA_AMT
from NW.DW_GRP_CR_RPRT_FACT a
left join NW.DW_CR_RISK_ASSET_SUBCLASS_DIM b
on b.CR_RISK_ASSET_SUBCLASS_key = a.CR_RISK_ASSET_SUBCLASS_key
and date '2021-02-28' between b.EFFV_FROM and b.EFFV_TO
inner join dwpviewa.Acct_Fin_LG_Link AFL
on AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY = AFL.Acct_Key
where Month_Key = '202102'
and '20210228' between AFL.From_Date and AFL.To_Date
--and AR_SOURCE_SYSTEM_CODE = 'SLIS'
--and AR_SOURCE_SYSTEM_KEY = '100212211561100'
) credr,
(select 
month_key,
account_id,
asset_subclass,
ecc,
rwa
from
finiq.CRDBEXTRACT
where month_key = '202102'
--and account_id = 'SLIS100212211561100'
) cpop
where cpop.account_id = credr.Acct_Key
and cpop.asset_subclass = credr.cr_risk_asset_subclass_code
group by 1