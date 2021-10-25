

-- create temp table
create volatile table tmp as (
SELECT MONTH_KEY (Named MONTH_KEY)
		, trim(Centre_Id)(Named Centre_Id)
		, trim(PRODUCT_CODE)(Named PRODUCT_CODE)
		, trim(ASSET_SUBCLASS)(Named ASSET_SUBCLASS)
		, SUM (ECC) (Named ECC)
	    , SUM (RWA) (Named RWA)
		FROM retsys.CRDBEXTRACT1807 
		WHERE (PRODUCT_CODE <> 'N/A' and PRODUCT_CODE is not null) 
		AND (Centre_Id <> 'N/A' and Centre_Id is not null) 
		GROUP BY 1,2,3,4
		HAVING SUM (ECC) is not null
) with no data
		primary index (month_key,centre_id,product_code,asset_subclass,ecc)
on commit preserve rows;


-- insert into temp table
insert into tmp
SELECT MONTH_KEY (Named MONTH_KEY)
		, trim(Centre_Id)(Named Centre_Id)
		, trim(PRODUCT_CODE)(Named PRODUCT_CODE)
		, trim(ASSET_SUBCLASS)(Named ASSET_SUBCLASS)
		, SUM (ECC) (Named ECC)
		FROM retsys.CRDBEXTRACT1810
		WHERE (PRODUCT_CODE <> 'N/A' and PRODUCT_CODE is not null) 
		AND (Centre_Id <> 'N/A' and Centre_Id is not null) 
		GROUP BY 1,2,3,4
		HAVING SUM (ECC) is not null;



-- summarise
select
a.month_key,
case when a.centre_id in ('842009','842010','848702','848383','842186') then 'SME'
else trim(repctr.LG_Centre_L13_name) end as ReportingGroup,
trim(prod.LG_Product_L10_Name),
sum(ECC)
from tmp a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
group by 1,2,3