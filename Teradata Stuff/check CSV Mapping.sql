select
tmp.centre_id
,tmp.agg_centre_id
,trim(repctr.LG_Centre_L13_name) as l13
,trim(repctr.LG_Centre_L12_name) as l12
,trim(aggctr.LG_Centre_L13_name) as l13agg
,trim(aggctr.LG_Centre_L12_name) as l12agg
,sum(case when ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP','SOV') and l13 not in ('Auto and Novated Finance','Strategic Alliance') then ECC else 0 end) as ECC
,sum(case when l13 in ('Auto and Novated Finance','Strategic Alliance') then RWA * 0.0875
when ASSET_SUBCLASS not in ('SMECORP','SLIPRE','CORP','SOV') then RWA * 0.0875 else 0 end) as RWA
from
(select * from
finiq.CRDBEXTRACT a
left join finiq.TM1_CtrAgg agg
on agg.lg_centre_id = a.centre_id
where month_key in ('202103')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as aggctr
on tmp.agg_centre_id = aggctr.LG_Centre_ID
and date between aggctr.from_date and aggctr.to_date
where tmp.Product_code is not null
and l13agg is null
and centre_id <> 'N/A'
and centre_id is not null
group by 1,2,3,4,5,6
