


create volatile table MA as
(
SELECT
CAST(ALLOC_RULE_ID AS INT) AS ALLOC_RULE_ID,
ALLOC_DESCRIPTION
FROM finiq.FQ_ADJ_LGR_RPT
WHERE ENTRY_CODE NOT IN ('INS','ADJ','NON')
AND REPORTING_MTH = '201804'
GROUP BY 1,2)
with data
Primary index (ALLOC_RULE_ID, ALLOC_DESCRIPTION)
ON COMMIT PRESERVE ROWS;

SELECT
A.ALLOC_RULE_ID,
B.ALLOC_DESCRIPTION,
trim(acct.LG_Account_L09_Name),
trim(prod.LG_Product_L10_Name),
A.LG_ACCOUNT_ID, 
A.LG_PRODUCT_ID,
A.REPORTING_CENTRE_ID,
case when a.reporting_centre_id in ('842009','842010','848702','848383','842186') then 'SME'
when repctr.LG_Centre_L12_Key in ('400150','84000') then trim(repctr.LG_Centre_L12_name)
when repctr.LG_Centre_L13_Key in ('SG1447','187405','SG0447','SG0429','RC3812','SG1480') then trim(repctr.LG_Centre_L13_name)
else 'Support' end as ReportingGroup,
SUM(CASE WHEN SRC = 'IMRAN ' THEN METRIC_AMT ELSE 0 END) AS FIQ,
SUM(CASE WHEN SRC = 'MLPROD' THEN METRIC_AMT ELSE 0 END) AS PROD,
(FIQ - PROD) AS VAR
FROM
(SELECT 
'IMRAN ' AS SRC,
CAST(ALLOC_RULE_ID AS INT) AS ALLOC_RULE_ID,
LG_COST_CENTRE_ID,
LG_ACCOUNT_ID, 
LG_PRODUCT_ID,
REPORTING_CENTRE_ID,
SUM(TOT_METRIC_AMT) AS METRIC_AMT
FROM finiq.FQ_ADJ_LGR_RPT
WHERE ENTRY_CODE NOT IN ('INS','ADJ','NON')
AND REPORTING_MTH = '201804'
GROUP BY 1,2,3,4,5,6
UNION ALL
SELECT 
'MLPROD' AS SRC,
CAST(MANUAL_ALLOC_GROUP_NO AS INT),
LG_COST_CENTRE_ID,
LG_ACCOUNT_ID, 
LG_PRODUCT_ID,
REPORTING_CENTRE_ID,
SUM(METRIC_AMT)
FROM dwpviewa.ZFQ_Manual_Alloc
WHERE REPORTING_MTH = '201804'
GROUP BY 1,2,3,4,5,6) A
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
--WHERE A.LG_ACCOUNT_ID = '413100'
--AND A.LG_PRODUCT_ID = '11108'
GROUP BY 1,2,3,4,5,6,7,8
having abs(var) > 3