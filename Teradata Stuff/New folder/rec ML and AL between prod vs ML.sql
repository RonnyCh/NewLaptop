

-- create temp table for mapping out the allocation rule
drop table ma;
create volatile table MA as
(
SELECT
CASE WHEN ALLOC_DESCRIPTION = 'BSA TD' THEN 103
WHEN ALLOC_DESCRIPTION = 'Bill Reclass Issue' THEN 104
ELSE CAST(ALLOC_RULE_ID AS INT) END AS ALLOC_RULE_ID,
ALLOC_DESCRIPTION
FROM finiq.FQ_ADJ_LGR_RPT
WHERE ENTRY_CODE IN ('ALC','ALT')
AND REPORTING_MTH = '201804'
GROUP BY 1,2)
with data
Primary index (ALLOC_RULE_ID, ALLOC_DESCRIPTION)
ON COMMIT PRESERVE ROWS;

-- run the query to see the diff between prod ML and AL/ML in Imran table
SELECT
A.METRIC_CODE,
trim(acct.LG_Account_L09_Name),
trim(prod.LG_Product_L10_Name),
case when a.alloc_description = 'allocation' then 'AL' else 'ML' end as entry_code,
case when a.alloc_description = 'allocation' then B.ALLOC_DESCRIPTION else a.alloc_description end as alloc_description,
A.ALLOC_RULE_ID,
A.LG_ACCOUNT_ID, 
A.LG_PRODUCT_ID,
A.REPORTING_CENTRE_ID,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','84000') then trim(repctr.LG_Centre_L12_name)
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
SUM(CASE WHEN SRC = 'IMRAN ' THEN METRIC_AMT ELSE 0 END) AS FIQ,
SUM(CASE WHEN SRC = 'MLPROD1' THEN METRIC_AMT ELSE 0 END) AS ZFQ,
(FIQ - ZFQ) as Var
FROM
(SELECT 
metric_Code,
'IMRAN  ' AS SRC,
CAST(ALLOC_RULE_ID AS INT) AS ALLOC_RULE_ID,
case when entry_code in ('ALC','ALT') then 'Allocation' else ALLOC_DESCRIPTION end as alloc_description,
LG_COST_CENTRE_ID,
LG_ACCOUNT_ID, 
LG_PRODUCT_ID,
REPORTING_CENTRE_ID,
SUM(TOT_METRIC_AMT) AS METRIC_AMT
FROM finiq.FQ_ADJ_LGR_RPT
WHERE ENTRY_CODE NOT IN ('INS','ADJ','NON')
AND REPORTING_MTH = '201804'
GROUP BY 1,2,3,4,5,6,7,8
UNION ALL
SELECT 
metric_Code,
'MLPROD1' AS SRC,
CAST(MANUAL_ALLOC_GROUP_NO AS INT),
case when manual_alloc_Desc like '%alloc process date%' then 'Allocation' else manual_alloc_Desc end as manual_alloc_Desc,
LG_COST_CENTRE_ID,
LG_ACCOUNT_ID, 
LG_PRODUCT_ID,
REPORTING_CENTRE_ID,
SUM(METRIC_AMT)
FROM dwpviewa.ZFQ_Manual_Alloc
WHERE REPORTING_MTH = '201804'
GROUP BY 1,2,3,4,5,6,7,8
) A
LEFT JOIN MA B
ON B.ALLOC_RULE_ID = A.ALLOC_RULE_ID
left join dwpviewa.LG_Hier_Centre as repctr
on a.Reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Account_EOP as acct
on acct.LG_Account_ID = a.LG_Account_ID
and '29991231' between acct.from_date and acct.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
GROUP BY 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,4
having abs(var) > 3




