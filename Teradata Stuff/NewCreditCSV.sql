
-- renaming the monthly tables to stand names
rename table finiq.sascredit?YYMM as finiq.tmp_credit;
rename table finiq.sasadj?YYMM as finiq.tmp_credit_adj;

/*Step 101: CPOP - amend CPOP source table to add remap columns*/
create volatile table CPOP as (
sel distinct
substring(cast(month_key as varchar(6)),1,4) as Yr_Key
,substring(cast(month_key as varchar(6)),5,2) as Mth_Key
,trim(a.CENTRE_ID) as CENTRE_ID 
,trim(LHC.LG_Centre_Name) as Ctr_Name
,trim(LHC.LG_Centre_L06_Key)||':'||trim(LHC.LG_Centre_L06_Name) as Ctr_06 
,trim(LHC.LG_Centre_L07_Key)||':'||trim(LHC.LG_Centre_L07_Name) as Ctr_07 
,trim(LHC.LG_Centre_L08_Key)||':'||trim(LHC.LG_Centre_L08_Name) as Ctr_08
,trim(LHC.LG_Centre_L09_Key)||':'||trim(LHC.LG_Centre_L09_Name) as Ctr_09
,trim(LHC.LG_Centre_L10_Key)||':'||trim(LHC.LG_Centre_L10_Name) as Ctr_10 
,trim(LHC.LG_Centre_L11_Key)||':'||trim(LHC.LG_Centre_L11_Name) as Ctr_11 
,trim(LHC.LG_Centre_L12_Key)||':'||trim(LHC.LG_Centre_L12_Name) as Ctr_12
,trim(LHC.LG_Centre_L13_Key)||':'||trim(LHC.LG_Centre_L13_Name) as Business_Unit 
,a.Div as DIVISION
,a.LOB_View as LoB         
,case when LHC.LG_Centre_L12_Key = '187405' then 'Y'              /*RAMS*/
    else 'N'
        end RAMS_IND
,a.PRODUCT_CODE
,trim(LHP.LG_Product_L10_Key)||':'||trim(LHP.LG_Product_L10_Name) as Prod10
,case when (a.PRODUCT_CODE is NULL or a.PRODUCT_CODE = 'N/A') then '00000'
    else a.PRODUCT_CODE
        end Map_Prod_Id
,trim(a.ASSET_SUBCLASS) as ASSET_SUBCLASS 
,case when RAMS_IND = 'Y' then 'MRTG'
    when a.ASSET_SUBCLASS = 'OTHER' and LHC.LG_Centre_L13_Key = 'RB7341' then 'MRTG'         /*RB7341 Mortgage Centre*/
        when a.ASSET_SUBCLASS = 'OTHER' and LHP.LG_Product_L10_Key = 'HOUSF' then 'MRTG'
            when a.ASSET_SUBCLASS = 'OTHER' and LHP.LG_Product_L10_Key <> 'HOUSF' then 'SMERETL'
                else trim(a.ASSET_SUBCLASS)
                    end Map_Class
,case when LHC.LG_Centre_L13_Key = 'RB7054' then '187100:Customer Engagement Office'    /*RB7054 Support Consumer*/
    when LHC.LG_Centre_L13_Key = 'RB7071' then 'RB7136:Customer Engagement'     /*RB7071 Support Business*/
/*Suspended RB7065 Support Specialist Businesses remap to align to GL*/
        /*when LHC.LG_Centre_L13_Key = 'RB7065' then '352268:Private Wealth'*/         
            else Business_Unit
                end Map_BU
/*Suspended RB7341 Support Specialist Businesses to align to GL*/                
/*,case when LHC.LG_Centre_L13_Key = 'RB7065' then 'BUSINESS'           
    else a.Div
        end Map_Div*/
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.Map_Div
        end Map_Div
,cast(trim(a.CENTRE_ID) as char(6)) as Map_Ctr 
,cast(a.PRODUCT_CODE as char(5)) as Map_Prod
,case when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7063','RB7065') then  'Auto and Novated Finance'
    when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7053') then 'Strategic Alliance'
        when a.LOB_View in ('Unmapped Business','Unallocated','WIB') and Map_Div in ('BUSINESS') then 'Unallocated BD'
               when a.LOB_View in ('Unmapped Consumer','Unallocated','WIB') and Map_Div in ('CONSUMER') then 'Unallocated CD'
                 else a.LOB_View
                       end Map_LoB
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.LoB_Div
        end LoB_Div
,case when LoB_Div <> 'SPECIALIST BUSINESSES' and Map_Class in ('CORP','SLIPRE','SMECORP','SOV') then 'ECC'
    else 'RWA'
        end Map_Risk_Type
,sum(a.ECC) as ECC_raw
,sum(a.RWA) as RWA_raw
,sum(case when Map_Risk_Type = 'ECC' then a.ECC else 0 end) as ECC
,sum(case when Map_Risk_Type = 'RWA' then a.RWA else 0 end) as RWA
,sum(case when Map_Risk_Type = 'RWA' then cast(a.RWA*8.75/100 as decimal (15,2)) else 0 end) as RWAxFactor
from finiq.tmp_credit_adj a
left outer join finiq.LoB_Div Ld
on Ld.SAS_Source = 'CPOP'
and Ld.LoB_View = a.LoB_View
and Ld.Div_C_RPRT_BUSUNIT = a.Div
inner join dwpviewa.LG_Hier_Product LHP
on a.Product_Code = LHP.LG_Product_Id
inner join dwpviewa.LG_Hier_Centre LHC
on a.CENTRE_ID = LHC.LG_Centre_Id
where 
(select add_months('20'||substring('?YYMM',1,2)||'-'||substring('?YYMM',3,2)||'-'||'01',1)-1) between LHP.From_Date and LHP.To_Date
and (select add_months('20'||substring('?YYMM',1,2)||'-'||substring('?YYMM',3,2)||'-'||'01',1)-1)  between LHC.From_Date and LHC.To_Date

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27

Union


sel distinct
substring(cast(month_key as varchar(6)),1,4) as Yr_Key
,substring(cast(month_key as varchar(6)),5,2) as Mth_Key
,trim(a.CENTRE_ID) as CENTRE_ID 
,'' as Ctr_Name
,'' as Ctr_06 
,'' as Ctr_07
,'' as Ctr_08
,'' as Ctr_09
,'' as Ctr_10
,'' as Ctr_11
,'' as Ctr_12
,'' as Business_Unit 
,a.Div as DIVISION
,a.LOB_View as LoB         
,'N' as RAMS_IND
,a.PRODUCT_CODE
,trim(LHP.LG_Product_L10_Key)||':'||trim(LHP.LG_Product_L10_Name) as Prod10
,case when (a.PRODUCT_CODE is NULL or a.PRODUCT_CODE = 'N/A') then '00000'
    else a.PRODUCT_CODE
        end Map_Prod_Id
,trim(a.ASSET_SUBCLASS) as ASSET_SUBCLASS
,trim(a.ASSET_SUBCLASS) as Map_Class
,case when a.Div = 'CONSUMER' then '187100:Customer Engagement Office'
    when a.Div = 'BUSINESS' then 'RB7136:Customer Engagement'
         when a.Div = 'SPECIALIST BUSINESSES' then Business_Unit
             else 'ERR'
                end Map_BU
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.Map_Div
        end Map_Div
/*Below are fictitious Centre_Id to be updated*/
,case when Map_Div = 'CONSUMER' then cast('999991' as char(6))
    when Map_Div = 'BUSINESS' then cast('999992' as char(6))
        when Map_Div = 'SPECIALIST BUSINESSES' then cast('999993' as char(6))
            else cast('999999' as char(6))
                end Map_Ctr
,cast(a.PRODUCT_CODE as char(5)) as Map_Prod
,case when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7063','RB7065') then  'Auto and Novated Finance'
    when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7053') then 'Strategic Alliance'
        when a.LOB_View in ('Unmapped Business','Unallocated','WIB') and Map_Div in ('BUSINESS') then 'Unallocated BD'
               when a.LOB_View in ('Unmapped Consumer','Unallocated','WIB') and Map_Div in ('CONSUMER') then 'Unallocated CD'
                 else a.LOB_View
                       end Map_LoB
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.LoB_Div
        end LoB_Div
,case when LoB_Div <> 'SPECIALIST BUSINESSES' and Map_Class in ('CORP','SLIPRE','SMECORP','SOV') then 'ECC'
    else 'RWA'
        end Map_Risk_Type
,sum(a.ECC) as ECC_raw
,sum(a.RWA) as RWA_raw
,sum(case when Map_Risk_Type = 'ECC' then a.ECC else 0 end) as ECC
,sum(case when Map_Risk_Type = 'RWA' then a.RWA else 0 end) as RWA
,sum(case when Map_Risk_Type = 'RWA' then cast(a.RWA*8.75/100 as decimal (15,2)) else 0 end) as RWAxFactor
from finiq.tmp_credit_adj a
left outer join finiq.LoB_Div Ld
on Ld.SAS_Source = 'CPOP'
and Ld.LoB_View = a.LoB_View
and Ld.Div_C_RPRT_BUSUNIT = a.Div
inner join dwpviewa.LG_Hier_Product LHP
on a.Product_Code = LHP.LG_Product_Id
where 
(select add_months('20'||substring('?YYMM',1,2)||'-'||substring('?YYMM',3,2)||'-'||'01',1)-1) between LHP.From_Date and LHP.To_Date
and (a.Centre_Id is NULL or a.Centre_Id ='N/A')

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27


Union


sel distinct
substring(cast(month_key as varchar(6)),1,4) as Yr_Key
,substring(cast(month_key as varchar(6)),5,2) as Mth_Key
,trim(a.CENTRE_ID) as CENTRE_ID 
,trim(LHC.LG_Centre_Name) as Ctr_Name
,trim(LHC.LG_Centre_L06_Key)||':'||trim(LHC.LG_Centre_L06_Name) as Ctr_06 
,trim(LHC.LG_Centre_L07_Key)||':'||trim(LHC.LG_Centre_L07_Name) as Ctr_07 
,trim(LHC.LG_Centre_L08_Key)||':'||trim(LHC.LG_Centre_L08_Name) as Ctr_08
,trim(LHC.LG_Centre_L09_Key)||':'||trim(LHC.LG_Centre_L09_Name) as Ctr_09
,trim(LHC.LG_Centre_L10_Key)||':'||trim(LHC.LG_Centre_L10_Name) as Ctr_10 
,trim(LHC.LG_Centre_L11_Key)||':'||trim(LHC.LG_Centre_L11_Name) as Ctr_11 
,trim(LHC.LG_Centre_L12_Key)||':'||trim(LHC.LG_Centre_L12_Name) as Ctr_12
,trim(LHC.LG_Centre_L13_Key)||':'||trim(LHC.LG_Centre_L13_Name) as Business_Unit 
,a.Div as DIVISION 
,a.LOB_View as LoB         
,case when LHC.LG_Centre_L12_Key = '187405' then 'Y'
    else 'N'
        end RAMS_IND
,a.PRODUCT_CODE
,'' as Prod10
,case when (a.PRODUCT_CODE is NULL or a.PRODUCT_CODE = 'N/A') then '00000'
    else a.PRODUCT_CODE
        end Map_Prod_Id
,trim(a.ASSET_SUBCLASS) as ASSET_SUBCLASS
,case when RAMS_IND = 'Y' then 'MRTG'
    when a.ASSET_SUBCLASS = 'OTHER' and LHC.LG_Centre_L13_Key = 'RB7341' then 'MRTG'
        when a.ASSET_SUBCLASS = 'OTHER' and LHC.LG_Centre_L13_Key <> 'RB7341' then 'SMERETL'
                else trim(a.ASSET_SUBCLASS)
                    end Map_Class
,case when LHC.LG_Centre_L13_Key = 'RB7054' then '187100:Customer Engagement Office'
    when LHC.LG_Centre_L13_Key = 'RB7071' then 'RB7136:Customer Engagement'
/*Suspended RB7065 Support Specialist Businesses remap to align to GL*/
 /*       when LHC.LG_Centre_L13_Key = 'RB7065' then '352268:Private Wealth'*/
            else Business_Unit
                end Map_BU
/*Suspended RB7065 Support Specialist Businesses remap to align to GL*/
/*,case when LHC.LG_Centre_L13_Key = 'RB7065' then 'BUSINESS'
    else a.Div
        end Map_Div*/
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.Map_Div
        end Map_Div
,cast(trim(a.CENTRE_ID) as char(6)) as Map_Ctr                     
,cast('00000' as char(5)) as Map_Prod        
,case when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7063','RB7065') then  'Auto and Novated Finance'
    when a.LOB_View is NULL and left(Map_Bu,6) in ('RB7053') then 'Strategic Alliance'
        when a.LOB_View in ('Unmapped Business','Unallocated','WIB') and Map_Div in ('BUSINESS') then 'Unallocated BD'
               when a.LOB_View in ('Unmapped Consumer','Unallocated','WIB') and Map_Div in ('CONSUMER') then 'Unallocated CD'
                 else a.LOB_View
                       end Map_LoB                
,case when Ld.LoB_View is NULL then 'SPECIALIST BUSINESSES'
    else Ld.LoB_Div
        end LoB_Div
,case when LoB_Div <> 'SPECIALIST BUSINESSES' and Map_Class in ('CORP','SLIPRE','SMECORP','SOV') then 'ECC'
    else 'RWA'
        end Map_Risk_Type
,sum(a.ECC) as ECC_raw
,sum(a.RWA) as RWA_raw
,sum(case when Map_Risk_Type = 'ECC' then a.ECC else 0 end) as ECC
,sum(case when Map_Risk_Type = 'RWA' then a.RWA else 0 end) as RWA
,sum(case when Map_Risk_Type = 'RWA' then cast(a.RWA*8.75/100 as decimal (15,2)) else 0 end) as RWAxFactor
from finiq.tmp_credit_adj a
left outer join finiq.LoB_Div Ld
on Ld.SAS_Source = 'CPOP'
and Ld.LoB_View = a.LoB_View
and Ld.Div_C_RPRT_BUSUNIT = a.Div
inner join dwpviewa.LG_Hier_Centre LHC
on a.centre_id = LHC.LG_Centre_Id
where 
(select add_months('20'||substring('?YYMM',1,2)||'-'||substring('?YYMM',3,2)||'-'||'01',1)-1) between LHC.From_Date and LHC.To_Date
and (a.Centre_Id is NULL or a.Centre_Id ='N/A')


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
)
with data
primary index (LoB,DIVISION)
on commit preserve rows
;

/*Step 102: Set up RWA Adjustments table*/
create volatile table RWA_Adj as (
sel distinct
a.C_ASSETSUBCLASS as ASSETSUBCLASS
,a.C_ASSETSUBCLASS as Map_Class
,a.LOB_View as LoB
,a.MNGE_BUSN_UNIT as MNGE_BUSN_UNIT
,a.ANCESTOR_CENTRE as ANCESTOR_CENTRE
,a.DESCRIPTION as DESCRIPTION
,a.C_BUSUNIT as C_BUSUNIT 
,a.C_RPRT_BUSUNIT as C_RPRT_BUSUNIT        
,Ld.Map_Div as Map_Div
,case when a.LOB_View in ('Unmapped BD','WIB') and Map_Div in ('BUSINESS') then 'Unallocated BD'
     when a.LOB_View in ('Unmapped CD','WIB') and Map_Div in ('CONSUMER') then 'Unallocated CD'
        when a.LOB_View in ('Business Lending') and a.C_RPRT_BUSUNIT in ('SSB') then 'Auto and Novated Finance'
            else a.LOB_View
                end Map_LoB
,Ld.LoB_Div                
,case when Map_Div <> 'SPECIALIST BUSINESSES' and Map_Class in ('CORP','SLIPRE','SMECORP','SOV') then 'ECC'
    else 'RWA'
        end Map_Risk_Type
,sum(case when Map_Risk_Type = 'ECC' then 0 else a.C_RWA end) as R_ADJ
,sum(case when Map_Risk_Type = 'ECC' then 0 else cast(a.C_RWA*8.75/100 as decimal (15,2)) end) as R_ADJxFactor
from finiq.tmp_credit a
left outer join finiq.LoB_Div Ld
on Ld.SAS_Source = 'RADJ'
and Ld.LoB_View = a.LoB_View
and Ld.Div_C_RPRT_BUSUNIT = a.C_RPRT_BUSUNIT
group by 1,2,3,4,5,6,7,8,9,10,11,12
)
with data
primary index (Map_LoB, Map_Div)
on commit preserve rows 
;

/*Step 103.1 Group RWA_Adjustment by LoB_Div and Map_LoB*/
Create volatile table R_Adj_Sum as (
sel distinct
Ra.LoB_Div as LoB_Div
,Ra.Map_LoB as Map_LoB
,cast (sum(Ra.R_AdjxFactor) as decimal (30,8)) as R_AdjxFactor
from RWA_Adj Ra
where Ra.LOB_DIV in ('BUSINESS','CONSUMER','SPECIALIST BUSINESSES')                      
group by 1,2
)
with data
primary index (LoB_Div, Map_LoB)
on commit preserve rows
;

/*Step 103.2 Group RWAxFactor by LoB_Div and Map_LoB*/
Create volatile table RWA_Sum as (
sel distinct
Cp.LoB_Div as LoB_Div
,Cp.Map_LoB as Map_LoB
,cast (sum(Cp.RWAxFactor) as decimal (30,8)) as RWAxFactor
from CPOP Cp
where Cp.LOB_DIV in ('BUSINESS','CONSUMER','SPECIALIST BUSINESSES')                      
and Cp.Map_Risk_Type = 'RWA'
group by 1,2
)
with data
primary index (LoB_Div, Map_LoB)
on commit preserve rows
;

/*Step 103.3 Calc RWA Adj Ratio by LoB_Div and Map_LoB*/
Create volatile table R_Adj_Ratio as (
sel distinct
Ra.LoB_Div
,Ra.Map_LoB
,cast(Ra.R_AdjxFactor/RW.RWAxFactor as decimal (30,8)) as R_Adj_Ratio
from R_Adj_Sum Ra, RWA_Sum RW
where Ra.LoB_Div = RW.LoB_Div
and Ra.Map_LoB = RW.Map_LoB
)
with data
primary index (LoB_Div, Map_LoB)
on commit preserve rows
;

/*Step 104 Add RWA Adj to CPOP to obtain Credit Risk*/
Create volatile table Credit_Risk as (
sel distinct
Cp.Mth_Key as Mth_Key
,Cp.CENTRE_ID as Ctr_Id 
,Cp.Ctr_Name as Ctr_Name
,Cp.Ctr_06 as Ctr_06 
,Cp.Ctr_07 as Ctr_07 
,Cp.Ctr_08 as Ctr_08
,Cp.Ctr_09 as Ctr_09
,Cp.Ctr_10 as Ctr_10 
,Cp.Ctr_11 as Ctr_11 
,Cp.Ctr_12 as Ctr_12
,Cp.Business_Unit as BU 
,Cp.Division as Div
,Cp.LoB as LoB         
,Cp.RAMS_IND as RAMS_IND
,Cp.PRODUCT_CODE as Prod_Id
,Cp.Prod10 as Prod_10
,Cp.Map_Prod_Id as Map_Prod_Id
,Cp.ASSET_SUBCLASS as ASSET_SUBCLASS 
,Cp.Map_Class as Map_Class
,Cp.Map_BU as Map_BU
,Cp.Map_Div as Map_Div
,Cp.Map_Ctr as Map_Ctr 
,Cp.Map_LoB as Map_LoB
,Cp.LoB_Div as LoB_Div
,Cp.Map_Risk_Type as Map_Risk_Type
,Cp.ECC as ECC
,Cp.RWA as RWA
,Cp.RWAxFactor as RWAxFactor
,case when Cp.RWAxFactor*Ra.R_Adj_Ratio is NULL then 0
    else Cp.RWAxFactor*Ra.R_Adj_Ratio
        end R_Adj_Allc
,case when Cp.RWAxFactor+R_Adj_Allc is NULL then 0
    else Cp.RWAxFactor+R_Adj_Allc
        end Total_RWAxF
,cast(Cp.ECC+Total_RWAxF as decimal (30,2)) as Credit_Risk
from CPOP Cp
left outer join R_Adj_Ratio Ra
on Ra.LoB_Div = Cp.LoB_Div
and Ra.Map_LoB = Cp.Map_LoB
)
with data
primary index (LoB_Div, Map_LoB)
on commit preserve rows
;


-- rename the tables back to original names
rename table finiq.tmp_credit as finiq.sascredit?YYMM;
rename table finiq.tmp_credit_adj as finiq.sasadj?YYMM;

-- create csv table
delete from finiq.csv_capital;
insert into finiq.csv_capital
select
trim(year(date '?YrMthDt'))||substring('?YrMthDt',6,2) as month_key,
ctr_id,
prod_id,
asset_subclass,
ecc,
rwa
from credit_risk