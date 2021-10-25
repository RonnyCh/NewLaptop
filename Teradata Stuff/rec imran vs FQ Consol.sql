select
a.reporting_mth,
a.metric_code,
TRIM(acct.LG_Account_L09_Name) ,
TRIM(acct.LG_Account_L08_Name) ,
case when trim(acct.LG_Account_L08_Name)  = 'Capital Benefit' then 'Capital Benefit'
when trim(acct.LG_Account_L09_Name) = 'Non-interest income' then trim(acct.LG_Account_L08_Name)
when trim(prod.LG_Product_L08_Name) in ('Business Debit Card', 'Personal Credit Cards') and mar.Parent8_Name <> 'Non Customer Margin' then 'Cards'
when trim(prod.LG_Product_L08_Name)  in ('Personal Loans Revolving Credit','Personal Term Loans') and mar.Parent8_Name <> 'Non Customer Margin' then 'Personal Loans'
when  trim(prod.LG_Product_L08_Name)  = 'Auto Finance' and mar.Parent8_Name <> 'Non Customer Margin' then 'Auto Finance'
when trim(prod.LG_Product_L10_Name) in ('Personal Deposits', 'Business Deposits') and mar.Parent8_Name <> 'Non Customer Margin' then trim(prod.LG_Product_L09_Name)
when trim(prod.LG_Product_L10_Name) = 'Business Finance' and mar.Parent8_Name <> 'Non Customer Margin'  then trim(prod.LG_Product_L10_Name)
when mar.Parent8_Name = 'Non Customer Margin' then 'Non Customer Margin'
when trim(prod.LG_Product_L10_Name) in ('Total Product for TPROD Hierarchy') then 'Customer Margin Other'
else trim(prod.LG_Product_L10_Name)  end as ProdGrp,
repctr.LG_Centre_L14_name as Division,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','84000') then trim(repctr.LG_Centre_L12_name)
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
case when a.entry_code in ('INS','ADJ','NON','ADJL') then 'ADJL' else 'MANL' end as revisedEntryCode,
sum(case when a.tblname = 'FIQ_Prod' then a.metric_amt else 0 end) as FIQProd,
sum(case when a.tblname = 'Consol' then a.metric_amt else 0 end) as FQ_Consol,
(FQ_Consol - FIQProd) as Var
from 
(
select
a.reporting_mth
,'FIQ_Prod' as tblName
,metric_code
,a.entry_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.tot_metric_amt as metric_amt
from finiq.FQ_ADJ_LGR_RPT a
where a.reporting_mth in ('201807')
--and a.alloc_description not in ('Plug')
union all
select
a.reporting_mth
,'Consol' as tblName
,metric_code
,a.source_code
,a.lg_account_id
,a.lg_product_id
,a.lg_cost_centre_id
,a.reporting_centre_id
,a.metric_amt as metric_amt
from dwpviewa.FQ_Consol_Ledger a
where a.reporting_mth in ('201807')
and date between from_date and to_date
) a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as ctr
on a.lg_cost_centre_id = ctr.LG_Centre_ID
and date between ctr.from_date and ctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join finiq.FIQ_Ref_MARACT mar
on mar.child_id = a.lg_account_id
left join finiq.FIQ_Ref_IFRS_Account_Map ifrs
on ifrs.lg_account_id = a.lg_account_id
left join finiq.fq_non_map mp
on mp.lg_account_id = a.lg_account_id 
and mp.lg_product_id = a.lg_product_id
where a.lg_cost_centre_id not in ('842009','842010','848702','848383','842186','844024')
and a.reporting_centre_id not in ('842009','842010','848702','848383','842186','844024')
and trim(acct.LG_Account_L09_Key) in ('ALOANS','INETII','NOINTE','LCUSDP') 
and trim(acct.LG_Account_L08_Key) not in ('ALPRO1') 
and reportinggroup not in ('RAMS','St George - Lloyds')
and a.entry_code <> 'AGGR'
group by 1,2,3,4,5,6,7,8
order by 1,2,3,4
