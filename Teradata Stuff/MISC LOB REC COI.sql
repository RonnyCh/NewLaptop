
SELECT
    'Prod' as src,
     MONTH_KEY,
   centre_id,
    trim(repctr.LG_Centre_L13_name) as l13 ,
	trim(repctr.LG_Centre_L12_name) as l12 ,
	trim(repctr.LG_Centre_L11_name) as l11 ,
	--trim(repctr.LG_Centre_L10_name) as l10 ,
	trim(prod.LG_Product_L10_Name) as prod10,
	--ASSET_SUBCLASS,
	product_code,
    sum(ECC) as ecc,
    sum(RWA) as RWA
    FROM finiq.CRDBEXTRACT a
    left join dwpviewa.LG_Hier_Centre as repctr
    on a.Centre_ID = repctr.LG_Centre_ID
    and date between repctr.from_date and repctr.to_date
	left join dwpviewa.LG_Hier_Product as prod
	on a.Product_code = prod.LG_Product_ID
	and '29991231' between prod.from_date and prod.to_date
    WHERE DIVISION IN ('Business','Consumer','Specialist Businesses')
    and month_key in ('202010')
	--and centre_id = '848060'
	and product_code = '11122'
	and l13 = 'St. George Retail'
	--and prod10 = 'Personal Deposits'
	and ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP')
	--and ASSET_SUBCLASS in ('SMECORP')
    group by 1,2,3,4,5,6,7,8
	
	
	SELECT 
MONTH_KEY
, trim(Centre_Id) as Centre_Id
, trim(PRODUCT_CODE)
, trim(ASSET_SUBCLASS)
,trim(repctr.LG_Centre_L13_name) as l13 
,trim(repctr.LG_Centre_L12_name) as l12 
,trim(repctr.LG_Centre_L11_name) as l11 
,trim(repctr.LG_Centre_L10_name) as l10 
,trim(prod.LG_Product_L10_Name) as prod10
,trim(prod.LG_Product_L09_Name) as prod09
,trim(prod.LG_Product_L08_Name) as prod08
, SUM (ECC)
, SUM (case when RWA is null then 0 else RWA end)
FROM finiq.CRDBEXTRACT a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
and LG_Centre_L13_Key not in ('352268','355863','357000','358630','364000','366000','355862','RB3607')
and LG_Centre_L12_Key not in ('352007','RE4220', 'RA0080', 'RB3609')
and LG_Centre_L11_Key not in ('RB3608', 'RB3603','359000')
and LG_Centre_Id <> '148080'
left join dwpviewa.LG_Hier_Product as prod
on a.Product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
/* Remove BT centre  */
WHERE (PRODUCT_CODE <> 'N/A' and PRODUCT_CODE is not null)
AND (Centre_Id <> 'N/A' and Centre_Id is not null)
AND  (ASSET_SUBCLASS <> 'N/A' and ASSET_SUBCLASS is not null)
and month_key in ('202009')
AND trim(PRODUCT_CODE) = '13013'
AND CENTRE_ID = '849243'
--and ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11




SELECT * 
FROM finiq.CRDBEXTRACT
WHERE month_key in ('202009')
AND trim(PRODUCT_CODE) = '400176'
--AND CENTRE_ID = '849243'





SELECT 
MONTH_KEY
, trim(Centre_Id) as Centre_Id
, trim(PRODUCT_CODE)
, trim(ASSET_SUBCLASS)
,trim(repctr.LG_Centre_L13_name) as l13 
,trim(repctr.LG_Centre_L12_name) as l12 
,trim(repctr.LG_Centre_L11_name) as l11 
,trim(repctr.LG_Centre_L10_name) as l10 
,trim(prod.LG_Product_L10_Name) as prod10
,trim(prod.LG_Product_L09_Name) as prod09
,trim(prod.LG_Product_L08_Name) as prod08
, SUM (ECC)
, SUM (case when RWA is null then 0 else RWA end)
FROM finiq.CRDBEXTRACT a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
and LG_Centre_L13_Key not in ('352268','355863','357000','358630','364000','366000','355862','RB3607')
and LG_Centre_L12_Key not in ('352007','RE4220', 'RA0080', 'RB3609')
and LG_Centre_L11_Key not in ('RB3608', 'RB3603','359000')
and LG_Centre_Id <> '148080'
left join dwpviewa.LG_Hier_Product as prod
on a.Product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
/* Remove BT centre  */
WHERE (PRODUCT_CODE <> 'N/A' and PRODUCT_CODE is not null)
AND (Centre_Id <> 'N/A' and Centre_Id is not null)
AND  (ASSET_SUBCLASS <> 'N/A' and ASSET_SUBCLASS is not null)
and month_key in ('202009','202010')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11

