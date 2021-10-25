

create volatile table tmp as (
select
tmp.acct_key,
tmp.sys_code,
--tmp.acct_id,
--tmp.prod_id,
--tmp.sys_code
sum(case when tmp.source = 'FINIQ-INSTR' then tmp.amt else 0 end) as FIQ,
sum(case when tmp.source <> 'FINIQ-INSTR' then tmp.amt else 0 end) as NONFIQ,
(FIQ - NONFIQ) as var
from
(sel distinct
'FINIQ-INSTR' as Source
,FQ.Instr_Key as Acct_key
,AGL.Armt_Key
,FQ.LG_Account_Id as Acct_Id
,FQ.LG_Product_Id as Prod_Id
,FQ.LG_Cost_Centre_Id as Cst_Ctr_Id
,FQ.LG_Relationship_Centre_Id as Rel_Ctr_Id
,FQ.Reporting_Centre_Id as Rpt_Ctr_Id
,'Bal' as Bal_Type_Code
,FQ.Reporting_Centre_Basis_Code as Rpt_Cd
,Acc.Status_Code
,substring(FQ.Instr_key,2,3) as Sys_Code
,trim(LHA.LG_Account_L11_Key)||':'||trim(LHA.LG_Account_L11_Name) as Acct_11
,trim(LHA.LG_Account_L08_Key)||':'||trim(LHA.LG_Account_L08_Name) as Acct_08
,trim(LHP.LG_Product_L10_Key)||':'||trim(LHP.LG_Product_L10_Name) as Prod_10
,trim(LHP.LG_Product_L09_Key)||':'||trim(LHP.LG_Product_L09_Name) as Prod_09
,trim(LHC.LG_Centre_L14_Key)||':'||trim(LHC.LG_Centre_L14_Name) as Cst_Ctr_14
,trim(LHC.LG_Centre_L13_Key)||':'||trim(LHC.LG_Centre_L13_Name) as Cst_Ctr_13
,trim(LHC.LG_Centre_L12_Key)||':'||trim(LHC.LG_Centre_L12_Name) as Cst_Ctr_12
,trim(LHC.LG_Centre_L11_Key)||':'||trim(LHC.LG_Centre_L11_Name) as Cst_Ctr_11
,trim(LRR.LG_Centre_L14_Key)||':'||trim(LRR.LG_Centre_L14_Name) as Rpt_Ctr_14
,trim(LRR.LG_Centre_L13_Key)||':'||trim(LRR.LG_Centre_L13_Name) as Rpt_Ctr_13
,trim(LRR.LG_Centre_L12_Key)||':'||trim(LRR.LG_Centre_L12_Name) as Rpt_Ctr_12
,trim(LRR.LG_Centre_L11_Key)||':'||trim(LRR.LG_Centre_L11_Name) as Rpt_Ctr_11
,'20200131' as PDt
,sum(-FQ.Metric_Amt) as amt
from dwpviewa.FQ_Instr FQ
inner join ewp1viewa.Armt_GDW_Link AGL
on FQ.Instr_Key = AGL.GDW_Key
inner join dwpviewa.Acct Acc
on FQ.Instr_Key = Acc.Acct_Key
inner join dwpviewa.LG_Hier_Account LHA
on FQ.LG_Account_Id = LHA.LG_Account_Id
inner join dwpviewa.LG_Hier_Product LHP
on FQ.LG_Product_Id = LHP.LG_Product_Id
inner join dwpviewa.LG_Hier_Centre LHC
on FQ.LG_Cost_Centre_Id = LHC.LG_Centre_Id
inner join dwpviewa.LG_Hier_Centre LRR
on FQ.Reporting_Centre_Id = LRR.LG_Centre_Id
where '20200210' between FQ.From_Date and FQ.To_Date
and PDt between Acc.From_Date and Acc.To_Date
and PDt between AGL.From_Date and AGL.To_Date
and PDt between LHA.From_Date and LHA.To_Date
and PDt between LHP.From_Date and LHP.To_Date
and PDt between LHC.From_Date and LHC.To_Date
and PDt between LRR.From_Date and LRR.To_Date
and FQ.Reporting_Mth = '202001'
and FQ.Metric_Code = 'MAB'
and FQ.Reporting_Segment_Basis_Code = 'T_6'
and FQ.Variance_Eligibility_Ind = 'Y'
and LHC.LG_Centre_L14_Key = 'RB4892'
and LHC.LG_Centre_L12_Key <> 'CB2508'
and LRR.LG_Centre_L14_Key = 'RB4892'
and Sys_Code in ('LIS')
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
union all
sel distinct
'FQ-RA' as Source
,AC.Acct_Key as Acct_Key
,AGL.Armt_Key
,Ragl.Acctg_Acct_Id as Acct_Id
,Ragl.Acctg_Pdct_Id as Prod_Id
,Ragl.Acctg_Cntr_Id as Cst_Ctr_Id
,Ragl.Acctg_Rltnp_Id as Rel_Ctr_Id
,Ragl.Rpt_Centre_Id as Rpt_Ctr_Id
,Ragl.Bal_Type_Code as Bal_Type_Code
,'FWD' as Rpt_Cd
,Acc.Status_Code
,substring(AC.Acct_key,2,3) as Sys_Code
,trim(LHA.LG_Account_L11_Key)||':'||trim(LHA.LG_Account_L11_Name) as Acct_11
,trim(LHA.LG_Account_L08_Key)||':'||trim(LHA.LG_Account_L08_Name) as Acct_08
,trim(LHP.LG_Product_L10_Key)||':'||trim(LHP.LG_Product_L10_Name) as Prod_10
,trim(LHP.LG_Product_L09_Key)||':'||trim(LHP.LG_Product_L09_Name) as Prod_09
,trim(LHC.LG_Centre_L14_Key)||':'||trim(LHC.LG_Centre_L14_Name) as Cst_Ctr_14
,trim(LHC.LG_Centre_L13_Key)||':'||trim(LHC.LG_Centre_L13_Name) as Cst_Ctr_13
,trim(LHC.LG_Centre_L12_Key)||':'||trim(LHC.LG_Centre_L12_Name) as Cst_Ctr_12
,trim(LHC.LG_Centre_L11_Key)||':'||trim(LHC.LG_Centre_L11_Name) as Cst_Ctr_11
,trim(LRR.LG_Centre_L14_Key)||':'||trim(LRR.LG_Centre_L14_Name) as Rpt_Ctr_14
,trim(LRR.LG_Centre_L13_Key)||':'||trim(LRR.LG_Centre_L13_Name) as Rpt_Ctr_13
,trim(LRR.LG_Centre_L12_Key)||':'||trim(LRR.LG_Centre_L12_Name) as Rpt_Ctr_12
,trim(LRR.LG_Centre_L11_Key)||':'||trim(LRR.LG_Centre_L11_Name) as Rpt_Ctr_11
,'20200131' as PDt
,sum(Ragl.Bal_Amt) as Bal_Amt
from dwpviewa.Acct_Cis_Cust_Link AC
inner join dwpviewa.Acct Acc
on AC.Acct_Key = Acc.Acct_Key
inner join dwpviewa.Cis_Cust_Outline_Sme Csme
on AC.Cis_Key = Csme.Cis_Key
inner join ewp1viewa.Armt_GDW_Link AGL
on AC.Acct_Key = AGL.GDW_Key
inner join ewp1vafca.RAFC_Armt_GL_Compnt_Mth Ragl
on AGL.Armt_Key = Ragl.Armt_Key
inner join dwpviewa.LG_Hier_Account LHA
on Ragl.Acctg_Acct_Id = LHA.LG_Account_Id
inner join dwpviewa.LG_Hier_Product LHP
on Ragl.Acctg_Pdct_Id = LHP.LG_Product_Id
inner join dwpviewa.LG_Hier_Centre LHC
on Ragl.Acctg_Cntr_Id = LHC.LG_Centre_Id
inner join dwpviewa.LG_Hier_Centre LRC
on Ragl.Acctg_Rltnp_Id = LRC.LG_Centre_Id
inner join dwpviewa.LG_Hier_Centre LRR
on Ragl.Rpt_Centre_Id = LRR.LG_Centre_Id
where PDt between AC.From_Date and AC.To_Date
and PDt between Acc.From_Date and Acc.To_Date
and PDt between AGL.From_Date and AGL.To_Date
and PDt between Ragl.From_Date and Ragl.To_Date
and PDt between Csme.From_Date and Csme.To_Date
and PDt between LHA.From_Date and LHA.To_Date
and PDt between LHP.From_Date and LHP.To_Date
and PDt between LHC.From_Date and LHC.To_Date
and PDt between LRC.From_Date and LRC.To_Date
and PDt between LRR.From_Date and LRR.To_Date
and AC.Cust_Role_Code = 'PRN'
and Ragl.Bal_Type_Code in ('MAB','MAC','MAD')
and LHC.LG_Centre_L14_Key = 'RB4892'
and LHC.LG_Centre_L12_Key <> 'CB2508'
and LRR.LG_Centre_L14_Key = 'RB4892'
and Sys_Code in ('LIS')
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25) tmp
--where acct_key = 'SLIS100411074584600'
group by 1,2
having abs(var) > 1) with data 
primary index (acct_key, sys_code)
on commit preserve rows


-- check finiq where centres double due to changes but rafc just one
select * 
from dwpviewa.FQ_Instr FQ
where instr_key in (select  acct_key from tmp group by 1)
and reporting_mth = '202001'
and metric_code = 'MAB'





-- check in RAFC


select * from ewp1vafca.RAFC_Armt_GL_Compnt_Mth a
left join ewp1viewa.Armt_GDW_Link  b
on a.armt_key = b.armt_key
and date between b.from_date and b.to_date
where a.to_date = 1200131
and b.gdw_key in (select  acct_key from tmp group by 1)



