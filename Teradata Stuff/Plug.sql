

DELETE 
FROM FINIQ.FQ_MANUAL_ALLOC
where manual_alloc_desc in ('Plug','Plug2')
and reporting_mth = '?ECurrentMth_YYYYMM' ;


/*PRODUCTION PLUG */
/* Step 1 - Volatile Table for Adjusted Ledger */

Drop table vt_ADJ;
create volatile table vt_ADJ as
(sel 
lc1.lg_centre_l14_key  
,LG_Account_Id                 
,LG_Product_Id 
,Metric_Code              
,Reporting_Mth                 
,sum(metric_amt) as metric_amt
from dwpviewa.fq_Adjusted_ledger ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.reporting_centre_id = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
where reporting_mth = '?ECurrentMth_YYYYMM'
and ?EFollowingMth_1YYMMDD between ldg.from_date and ldg.to_date
and entry_code not in ('ALC','ALT')
and ldg.reporting_centre_id not in ('842009','842010','848702','848383','842186')

group by 1,2,3,4,5

having sum(metric_amt) <> 0

union all

sel 
lc1.lg_centre_l14_key  
,LG_Account_Id                 
,LG_Product_Id 
,Metric_Code              
,Reporting_Mth               
,sum(metric_amt) as metric_amt
from FINIQ.FQ_MANUAL_ALLOC ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.reporting_centre_id = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
where reporting_mth = '?ECurrentMth_YYYYMM'
and ldg.manual_alloc_desc not in ('Plug2','Plug')
and ldg.reporting_centre_id not in ('842009','842010','848702','848383','842186')

group by 1,2,3,4,5

having sum(metric_amt) <> 0


union all


sel 
lc1.lg_centre_l14_key  
,LG_Account_Id                 
,LG_Product_Id 
,Metric_Code              
,Reporting_Mth               
,sum(ldg.Alloc_Metric_Amt) as metric_amt
from  finiq_dev.FQ_ALLOCATION_TODAY ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.reporting_centre_id = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
group by 1,2,3,4,5


)
with data
Primary index (LG_Account_Id, LG_Product_Id)
ON COMMIT PRESERVE ROWS;

/* Step 2 - Volatile Table for Finiq Ledger */
Drop table vt_LED;
create volatile table vt_LED as
(
-- EOP
sel 
lc1.lg_centre_l14_key                
,Ldg.LG_Account_Id                 
,Ldg.LG_Product_Id
,'EOP' (Named Metric_Code)              
,pdt.process_date (format 'yyyymm') (char(7)) (Named Reporting_Mth)               
,sum(Period_Amt) as metric_amt
from dwpviewa.LG_Ledger ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.LG_COST_CENTRE_ID = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
left join dwpviewa.LG_Hier_Product as prod
on ldg.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = ldg.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join retsys.e18954_LGProcDate pdt
on pdt.sqnum = ldg.Period_Seq_Num
left Join fq_lg_inclusions INCL
on ldg.LG_Cost_Centre_Id = INCL.Child_Id
AND date BETWEEN  INCL.From_Date AND INCL.To_Date
where DATE between ldg.FROM_DATE and ldg.TO_DATE 
and ldg.REC_TYPE_CD = 'P' 
and ldg.VERSION_ID = '00' 
and ldg.CURRENCY_CODE in ('AUD') 
and ldg.LG_ENTITY_ID not in ('800','996') 
and acct.LG_ACCOUNT_L11_KEY in ('SNASST','SSHREQ','SLLIAB') 
and INCL.Segment_Type = 'Centre'
and ldg.lg_cost_centre_id not in ('842009','842010','848702','848383','842186')
and pdt.process_date = ?1yymmdd

group by 1,2,3,4,5

having sum(Period_Amt) <> 0

UNION ALL

-- PNL
sel 
lc1.lg_centre_l14_key                 
,Ldg.LG_Account_Id                 
,Ldg.LG_Product_Id               
,'PNL' (Named Metric_Code)
,pdt.process_date (format 'yyyymm') (char(7)) (Named Reporting_Mth)               
,sum(PERIOD_MOVEMENT_AMT) as metric_amt
from dwpviewa.LG_Ledger ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.LG_COST_CENTRE_ID = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
left join dwpviewa.LG_Hier_Product as prod
on ldg.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = ldg.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join retsys.e18954_LGProcDate pdt
on pdt.sqnum = ldg.Period_Seq_Num
left Join fq_lg_inclusions INCL
on ldg.LG_Cost_Centre_Id = INCL.Child_Id
AND date BETWEEN  INCL.From_Date AND INCL.To_Date
where DATE between ldg.FROM_DATE and ldg.TO_DATE 
and ldg.REC_TYPE_CD = 'P' 
and ldg.VERSION_ID = '00' 
and ldg.CURRENCY_CODE in ('AUD') 
and ldg.LG_ENTITY_ID not in ('800','996') 
and acct.LG_ACCOUNT_L09_KEY in ('inetii','nointe') 
and INCL.Segment_Type = 'Centre'
and ldg.lg_cost_centre_id not in ('842009','842010','848702','848383','842186')
and pdt.process_date = ?1yymmdd

group by 1,2,3,4,5

having sum(Period_Movement_Amt) <>0

UNION ALL

-- MAB
sel 
lc1.lg_centre_l14_key                
,Ldg.LG_Account_Id                 
,Ldg.LG_Product_Id           
,'MAB' (Named Metric_Code)              
,pdt.process_date (format 'yyyymm') (char(7)) (Named Reporting_Mth)               
,sum(Period_Amt) as metric_amt
from dwpviewa.LG_Ledger ldg
left join dwpviewa.LG_Hier_Centre as lc1
on ldg.LG_COST_CENTRE_ID = lc1.LG_Centre_ID
and '29991231' between lc1.from_date and lc1.to_date
left join dwpviewa.LG_Hier_Product as prod
on ldg.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = ldg.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join retsys.e18954_LGProcDate pdt
on pdt.sqnum = ldg.Period_Seq_Num
left Join fq_lg_inclusions INCL
on ldg.LG_Cost_Centre_Id = INCL.Child_Id
AND date BETWEEN  INCL.From_Date AND INCL.To_Date
where DATE between ldg.FROM_DATE and ldg.TO_DATE 
and ldg.REC_TYPE_CD = 'S' 
and ldg.VERSION_ID = 'AM' 
and ldg.CURRENCY_CODE in ('AUD') 
and ldg.LG_ENTITY_ID not in ('800','996') 
and acct.LG_ACCOUNT_L11_KEY in ('SNASST','SSHREQ','SLLIAB') 
and INCL.Segment_Type = 'Centre'
and ldg.lg_cost_centre_id not in ('842009','842010','848702','848383','842186')
and pdt.process_date = ?1yymmdd

group by 1,2,3,4,5

having sum(Period_Amt) <> 0)
with data
Primary index (LG_Account_Id, LG_Product_Id)
ON COMMIT PRESERVE ROWS;

/* Step 3 - Volatile Table for where Code Block are in Ledger but not Adjusted Ledger  */

Drop table vt_Diff;

create volatile table vt_Diff as (
select
metric_code,
TRIM(acct.LG_Account_L09_Name) as LG_Account_L09_Name,
lg_centre_l14_key,
t.lg_account_id, 
t.lg_product_id,
t.reporting_mth,
sum(case when status = 'AdjLedger' then metric_amt else 0 end) as AdjustedLedger,
sum(case when status = 'Ledger' then metric_amt else 0 end) as Ledger,
(Ledger - AdjustedLedger) as var
from
(select
'AdjLedger' as status,
a.*
from vt_adj a
union all
select
'Ledger',
a.*
from vt_led a
) t
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = t.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
where TRIM(acct.LG_Account_L09_Key)  in ('ALOANS','LCUSDP','INETII','NOINTE')
and TRIM(acct.LG_Account_L08_Key) not in ('ALPRO1','I9CAPB','I9CAPC','I9VTFR')
group by 1,2,3,4,5,6
having var <> 0
)
with data
Primary index (LG_Account_Id, LG_Product_Id)
ON COMMIT PRESERVE ROWS;







-- insert to manual load
insert into  FINIQ.FQ_MANUAL_ALLOC
Sel
Metric_Code
,'001' (Named LG_Entity_Id)
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named LG_Cost_Centre_Id)
, LG_Account_Id  
, LG_Product_Id    
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named LG_Relationship_Centre_Id) 
, '00' (Named LG_Location_Id)   
, '000000' (Named LG_IntraGroup_Centre_Id) 
, '00' (Named LG_Movement_Id)
, 'AUD' (Named LG_Currency_Id)
,case when lg_centre_l14_key = 'RB4892' then '073380' when lg_centre_l14_key = 'RB4152' then '849466' else '000000' end (Named Reporting_Centre_Id)
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLN' (NAMED Entry_Code)                    
,'1' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(var) (NAMED Metric_Amt)              
,'101'  (NAMED Manual_Alloc_Group_No)
,'Plug' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from vt_DIFF A
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26;




--select * from pg
--select * from tblzero

-- the following codes will fix up issues with plug not netting off to zero


-- drop temp tables
drop table pg;
drop table tblzero;

-- create product grouping 
create volatile table PG as (
select 
metric_code,
lg_account_id, 
lg_product_id,
prod_group_id
from dwpviewa.FQ_Variance
where reporting_mth = '?ECurrentMth_YYYYMM'
and date between from_date and to_date
and variance_type_code = 'PG'
group by 1,2,3,4
) WITH DATA
primary index (lg_account_id, lg_product_id,prod_group_id)
on commit preserve rows;

-- create template to force it to zero
create volatile table tblZero as (
select  
reporting_mth,
t.metric_code,
TRIM(acct.LG_Account_L09_Key) as acctl9,
case when pg.prod_group_id in (1,2,3,4,74) then '410010'
when pg.prod_group_id = 51 then '146200'
when pg.prod_group_id in (52,53,72,73) then '201206'
when pg.prod_group_id = 75 then '493101'
when t.lg_account_id = '491040' then '410010' 
else t.lg_account_ID end as lg_account_id,
case when pg.prod_group_id = 1 then '11708'
when pg.prod_group_id = 1 then '11708'
when pg.prod_group_id = 2 then '11246'
when pg.prod_group_id = 3 then '11257'
when pg.prod_group_id = 4 then '13431'
when pg.prod_group_id in (51,71,74,75) then '11111'
when pg.prod_group_id = 52 then '11236'
when pg.prod_group_id = 53 then '11265'
when pg.prod_group_id = 72 then '11247'
when pg.prod_group_id = 73 then '11266'
else t.lg_product_id end as lg_product_id,
pg.prod_group_id,
case when trim(prod.LG_Product_L10_Name) in ('Business Finance','Business Deposits') then '849466'
else '073380' end as reporting_centre_id,
sum(metric_amt * -1) as amount
from FINIQ.FQ_MANUAL_ALLOC t
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = t.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Product as prod
on t.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join m118954.pg as pg
on pg.lg_account_id = t.lg_account_id
and pg.lg_product_id = t.lg_product_id 
and pg.metric_code = t.metric_code
where reporting_mth = '?ECurrentMth_YYYYMM'
and manual_alloc_desc = 'Plug'
group by 1,2,3,4,5,6,7
having amount <> 0) with data
primary index (lg_account_id, lg_product_id,reporting_centre_id)
on commit preserve rows;





insert into  FINIQ.FQ_MANUAL_ALLOC
Sel
Metric_Code
,'001' (Named LG_Entity_Id)
,reporting_centre_id as LG_Cost_Centre_Id
, LG_Account_Id  
, LG_Product_Id    
,reporting_centre_id as LG_Relationship_Centre_Id 
, '00' (Named LG_Location_Id)   
, '000000' (Named LG_IntraGroup_Centre_Id) 
, '00' (Named LG_Movement_Id)
, 'AUD' (Named LG_Currency_Id)
,Reporting_Centre_Id
,0 (Named Reporting_Channel_Id)
,'1000000' (NAMED RO_ID)  
,'20' (NAMED Reporting_Segment_Id)  
,'MLA' (NAMED Entry_Code)                    
,'2' (NAMED Seq_No)  
,Reporting_Mth 
,'SGB' (NAMED Bank_Group_Code)            
,'I' (NAMED Reporting_Status_Code)  
,0.00 (NAMED Statistical_Cnt)           
,sum(amount) (NAMED Metric_Amt)              
,'102'  (NAMED Manual_Alloc_Group_No)
,'Plug2' (NAMED Manual_Alloc_Desc)
,'M118954' (NAMED Authorising_Employee_id)        
, CURRENT_TIMESTAMP(0) (NAMED Authorising_Timestamp)      
,'N' (NAMED Authorising_Ind)   
from tblzero A
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26




