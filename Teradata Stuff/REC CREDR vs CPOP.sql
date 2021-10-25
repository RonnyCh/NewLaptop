
drop table tmp;
drop table tmpMissing;
drop table tblFinal;
drop table tmpCred;



-- create a temp table where instrument keys found in both tables
create volatile table tmp as (
select
'Found  ' as Status,
cpop.month_key,
credr.acct_key as Instr_CREDR,
cpop.account_id as Instr_CPOP,
credr.cr_risk_asset_subclass_code,
cpop.asset_subclass,
cpop.centre_id,
cpop.gdw_src_sys_code,
cpop.src_sys_code,
cpop.division,
cpop.cpop_prod_code,
credr.credr_prod_code,
sum(coalesce(credr.ECON_CAPL_AMT,0)) as CREDR_ECC,
sum(coalesce(cpop.ecc,0)) as CPOP_ECC,
(CREDR_ECC - CPOP_ECC) as Var_ECC,
sum(coalesce(credr.BASEL_RWA_AMT,0)) as CREDR_RWA,
sum(coalesce(cpop.rwa,0)) as CPOP_RWA,
(CREDR_RWA - CPOP_RWA) as Var_RWA
from
(
-- derived table CPOP
select 
a.month_key,
a.account_id,
a.asset_subclass,
a.CENTRE_ID,
b.gdw_src_sys_code,
b.src_sys_code,
a.product_code as cpop_prod_code,
trim(ctr.lg_centre_l14_name) as division,
a.ecc,
a.rwa
from
finiq.CRDBEXTRACT a
left join 
(select 
gdw_src_sys_code,
src_sys_code,
gdw_key 
from ewp1vafca.rafc_armt_acct_mth 
where 1210228 between from_date and to_date) b
on b.gdw_key = a.account_id
left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = a.CENTRE_ID
and 1210228 between from_date and to_date
where a.month_key = '202102'
and (ECC <> 0 and RWA <> 0)
) cpop   
left join 
(
-- derived table CREDR
sel
a.MONTH_KEY
,case when AR_SOURCE_SYSTEM_CODE in ('SDDA','SLIS','SSOV','SCFL','SCHS','SCRA','EIL','AIC','FIF','SCHA','SLNS','CCF','RAM') then AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY
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
--and AR_SOURCE_SYSTEM_CODE = 'SLIS'
--and AR_SOURCE_SYSTEM_KEY = '100212211561100'
) credr
on cpop.account_id = credr.Acct_Key
where instr_credr is not null
--and cpop.asset_subclass = credr.cr_risk_asset_subclass_code
group by 1,2,3,4,5,6,7,8,9,10,11,12) with data
primary index(INSTR_CPOP)
on commit preserve rows;


-- create a temp table where instrument keys missing in CREDR table
create volatile table tmpMissing as (
select
'Missing' as Status,
cpop.month_key,
credr.acct_key as Instr_CREDR,
cpop.account_id as Instr_CPOP,
cpop.asset_subclass,
cpop.asset_subclass as cr_risk_asset_subclass_code,
cpop.centre_id,
cpop.gdw_src_sys_code,
cpop.src_sys_code,
cpop.division,
cpop.cpop_prod_code,
cpop.cpop_prod_code as credr_prod_code,
sum(coalesce(credr.ECON_CAPL_AMT,0)) as CREDR_ECC,
sum(coalesce(cpop.ecc,0)) as CPOP_ECC,
(CREDR_ECC - CPOP_ECC) as Var_ECC,
sum(coalesce(credr.BASEL_RWA_AMT,0)) as CREDR_RWA,
sum(coalesce(cpop.rwa,0)) as CPOP_RWA,
(CREDR_RWA - CPOP_RWA) as Var_RWA
from
(
select 
a.month_key,
a.account_id,
a.asset_subclass,
a.CENTRE_ID,
b.gdw_src_sys_code,
b.src_sys_code,
a.product_code as cpop_prod_code,
trim(ctr.lg_centre_l14_name) as division,
a.ecc,
a.rwa
from
finiq.CRDBEXTRACT a
left join 
(select 
gdw_src_sys_code,
src_sys_code,
gdw_key 
from ewp1vafca.rafc_armt_acct_mth 
where 1210228 between from_date and to_date) b
on b.gdw_key = a.account_id
left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = a.CENTRE_ID
and 1210228 between from_date and to_date
where a.month_key = '202102'
and (ECC <> 0 and RWA <> 0)
--and account_id = 'SLIS100212211561100'
) cpop
left join 
(sel
a.MONTH_KEY
,case when AR_SOURCE_SYSTEM_CODE in ('SDDA','SLIS','SSOV','SCFL','SCHS','SCRA','EIL','AIC','FIF','SCHA','SLNS','CCF','RAM') then AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY
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
--and AR_SOURCE_SYSTEM_CODE = 'SLIS'
--and AR_SOURCE_SYSTEM_KEY = '100212211561100'
) credr
on cpop.account_id = credr.Acct_Key
where instr_credr is null
--and cpop.asset_subclass = credr.cr_risk_asset_subclass_code
group by 1,2,3,4,5,6,7,8,9,10,11,12) with data
primary index(INSTR_CPOP)
on commit preserve rows;


-- create a table to link the instrument keys to RAFC to find the reporting centres (once CPOP is no longer required)
create volatile table tblFinal as (
select 
tmp.month_key,
tmp.status,
tmp.gdw_src_sys_code,
tmp.src_sys_code,
tmp.instr_cpop,
tmp.instr_credr,
tmp.cr_risk_asset_subclass_code as asset_subclass_credr,
tmp.ASSET_SUBCLASS as asset_subclass_cpop,
tmp.CENTRE_ID as centre_cpop,
mapctr.rpt_centre_id as centre_rafc,
tmp.cpop_prod_code,
tmp.credr_prod_code,
tmp.division as division_CPOP,
trim(ctr.lg_centre_l14_name) as division_RAFC,
tmp.CREDR_ECC,
tmp.CPOP_ECC,
tmp.Var_ECC,
tmp.CREDR_RWA,
tmp.CPOP_RWA,
tmp.Var_RWA
from tmp
inner join
(sel  
    a.gdw_key
    ,b.rpt_centre_id
from ewp1vafca.rafc_armt_acct_mth a
            left join ewp1vafca.rafc_armt_gl_compnt_mth b
                on a.armt_key = b.armt_key
where date '2021-02-28' between a.from_date and a.to_date
and date '2021-02-28' between b.from_date and b.to_date
and b.bal_type_code = 'BAL'
and a.gdw_key in (select instr_cpop from tmp group by 1)
group by 1,2) mapCtr
on mapctr.gdw_key = tmp.instr_cpop
left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = mapCtr.rpt_centre_id
and 1210228 between from_date and to_date
) with data
primary index(instr_cpop, asset_subclass_cpop)
on commit preserve rows;


-- add the missing instrument keys to the above table
insert into tblFinal
select
tmp.month_key,
tmp.status,
tmp.gdw_src_sys_code,
tmp.src_sys_code,
tmp.instr_cpop,
tmp.instr_credr,
tmp.cr_risk_asset_subclass_code as asset_subclass_credr,
tmp.ASSET_SUBCLASS as asset_subclass_cpop,
tmp.CENTRE_ID as centre_cpop,
'' as centre_rafc,
tmp.cpop_prod_code,
tmp.credr_prod_code,
tmp.division as division_CPOP,
'' as division_RAFC,
tmp.CREDR_ECC,
tmp.CPOP_ECC,
tmp.Var_ECC,
tmp.CREDR_RWA,
tmp.CPOP_RWA,
tmp.Var_RWA
from tmpMissing as tmp
inner join
(
sel  
    a.gdw_key
    ,b.rpt_centre_id
from ewp1vafca.rafc_armt_acct_mth a
            left join ewp1vafca.rafc_armt_gl_compnt_mth b
                on a.armt_key = b.armt_key
where date '2021-02-28' between a.from_date and a.to_date
and date '2021-02-28' between b.from_date and b.to_date
and b.bal_type_code = 'BAL'
and a.gdw_key in (select instr_cpop from tmpMissing group by 1)
group by 1,2
) mapCtr
on mapctr.gdw_key = tmp.instr_cpop
left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = mapCtr.rpt_centre_id
and 1210228 between from_date and to_date;



-- create a temp table for those instruments where flag <> ARFACT (possibly CREDR adjustments)
create volatile table tmpCred as (
sel
a.MONTH_KEY
,case when AR_SOURCE_SYSTEM_CODE in ('SDDA','SLIS','SSOV','SCFL','SCHS','SCRA','EIL','AIC','FIF','SCHA','SLNS','CCF','RAM') then AR_SOURCE_SYSTEM_CODE||AR_SOURCE_SYSTEM_KEY
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
and sourced_from <> 'ARFACT') with data
primary index (acct_key)
on commit preserve rows;


-- insert the results above to the final table
insert into tblFinal
select
a.month_key,
'CREDR' as status,
b.gdw_src_sys_code,
b.src_sys_code,
'' as instr_cpop,
a.acct_key as instr_credr,
a.cr_risk_asset_subclass_code as asset_subclass_credr ,
a.cr_risk_asset_subclass_code as asset_subclass_cpop,
mapctr.rpt_centre_id as centre_cpop,
mapctr.rpt_centre_id as centre_rafc,
a.credr_prod_code as cpop_prod_code,
a.credr_prod_code as credr_prod_code,
trim(ctr.lg_centre_l14_name) as div_cpop,
trim(ctr.lg_centre_l14_name) as div_rafc,
coalesce(a.ECON_CAPL_AMT,0) as credr_ecc,
0 as cpop_ecc,
a.ECON_CAPL_AMT as var_ecc,
coalesce(a.BASEL_RWA_AMT,0) as credr_RWA,
0 as cpop_rwa,
coalesce(a.BASEL_RWA_AMT,0) as var_rwa
from tmpCred a
inner join
(
sel  
    a.gdw_key
    ,b.rpt_centre_id
from ewp1vafca.rafc_armt_acct_mth a
            left join ewp1vafca.rafc_armt_gl_compnt_mth b
                on a.armt_key = b.armt_key
where date '2021-02-28' between a.from_date and a.to_date
and date '2021-02-28' between b.from_date and b.to_date
and b.bal_type_code = 'BAL'
and a.gdw_key in (select acct_key from tmpCred group by 1)
group by 1,2
) mapCtr
on mapctr.gdw_key = a.acct_key

left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = mapCtr.rpt_centre_id
and 1210228 between ctr.from_date and ctr.to_date

left join 
(select 
gdw_src_sys_code,
src_sys_code,
gdw_key 
from ewp1vafca.rafc_armt_acct_mth 
where 1210228 between from_date and to_date) b
on b.gdw_key = a.acct_key;



-- insert to the final table above from volatile table to permanent table in FINIQ

delete from finiq.COI_CREDR;

insert into finiq.COI_CREDR
select * from tblFinal;



-- summary of the data using COI_CREDR table to show final impacts
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




-- this is final table (permanent) in FINIQ
 select 
 --src_sys_code,
 status,
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
 --and status <> 'Found'
 group by 1,2,3
order by 1,2,3;
