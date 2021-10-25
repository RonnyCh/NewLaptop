select
'ECC' as typ
,trim(repctr.LG_Centre_L13_name) as l13agg
,trim(prod.LG_Product_L10_Name) 

,sum(case when month_key = '202102' and ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP','SOV') and l13agg not in ('Auto and Novated Finance','Strategic Alliance') then ECC else 0 end) as ECC_LM
,sum(case when month_key = '202102' and l13agg in ('Auto and Novated Finance','Strategic Alliance') then RWA * 0.0875
when ASSET_SUBCLASS not in ('SMECORP','SLIPRE','CORP','SOV') then RWA * 0.0875 else 0 end) as RWA_LM


,sum(case when month_key = '202103' and ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP','SOV') and l13agg not in ('Auto and Novated Finance','Strategic Alliance') then ECC else 0 end) as ECC_TM
,sum(case when month_key = '202103' and l13agg in ('Auto and Novated Finance','Strategic Alliance') then RWA * 0.0875
when ASSET_SUBCLASS not in ('SMECORP','SLIPRE','CORP','SOV') then RWA * 0.0875 else 0 end) as RWA_TM


from finiq.CRDBEXTRACT a
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.Product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
where trim(repctr.LG_Centre_L14_name) in ('Business','Consumer')
and month_key in ('202103','202102') 
group by 1,2,3
order by 1,2;




--select * from finiq.CRDBEXTRACT
--where month_key = '202103'