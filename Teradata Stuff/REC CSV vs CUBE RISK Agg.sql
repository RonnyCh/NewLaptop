--select * from  finiq.TM1_CtrAgg


-- REC
select
tmp.centre_id
,tmp.agg_centre_id
,trim(repctr.LG_Centre_L13_name) as l13
--,trim(repctr.LG_Centre_L12_name) as l12
--,trim(repctr.LG_Centre_L11_name) as l11
--,trim(repctr.LG_Centre_L10_name) as l10
,trim(aggctr.LG_Centre_L13_name) as l13gg
--,trim(aggctr.LG_Centre_L12_name) as l12gg
--,trim(aggctr.LG_Centre_L11_name) as l11gg
--,trim(aggctr.LG_Centre_L10_name) as l10gg
,sum(ECC)
,sum(RWA)
from
(select * from
finiq.CRDBEXTRACT a
left join finiq.TM1_CtrAgg agg
on agg.lg_centre_id = a.centre_id
where month_key in ('202011')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as aggctr
on tmp.agg_centre_id = aggctr.LG_Centre_ID
and date between aggctr.from_date and aggctr.to_date
where l13gg <> l13
group by 1,2,3,4

-- REC  missing mapping
select
tmp.centre_id
,tmp.agg_centre_id
,trim(repctr.LG_Centre_L13_name) as l13
--,trim(repctr.LG_Centre_L12_name) as l12
--,trim(repctr.LG_Centre_L11_name) as l11
--,trim(repctr.LG_Centre_L10_name) as l10
,trim(aggctr.LG_Centre_L13_name) as l13gg
--,trim(aggctr.LG_Centre_L12_name) as l12gg
--,trim(aggctr.LG_Centre_L11_name) as l11gg
--,trim(aggctr.LG_Centre_L10_name) as l10gg
,sum(ECC)
,sum(RWA)
from
(select * from
finiq.CRDBEXTRACT a
left join finiq.TM1_CtrAgg agg
on agg.lg_centre_id = a.centre_id
where month_key in ('202011')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as aggctr
on tmp.agg_centre_id = aggctr.LG_Centre_ID
and date between aggctr.from_date and aggctr.to_date
where tmp.agg_centre_id is null
group by 1,2,3,4







select
--tmp.centre_id
--,tmp.agg_centre_id
trim(repctr.LG_Centre_L13_name) as l13
,trim(repctr.LG_Centre_L12_name) as l12
--,trim(repctr.LG_Centre_L11_name) as l11
--,trim(repctr.LG_Centre_L10_name) as l10
,trim(aggctr.LG_Centre_L13_name) as l13gg
,trim(aggctr.LG_Centre_L12_name) as l12gg
,ASSET_SUBCLASS
--,trim(aggctr.LG_Centre_L11_name) as l11gg
--,trim(aggctr.LG_Centre_L10_name) as l10gg
,sum(case when ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP') then ECC else 0 end) as ECC
,sum(case when ASSET_SUBCLASS not in ('SMECORP','SLIPRE','CORP') then RWA * 0.0875 else 0 end) as RWA
from
(select * from
finiq.CRDBEXTRACT a
left join finiq.TM1_CtrAgg agg
on agg.lg_centre_id = a.centre_id
where month_key in ('202011')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as aggctr
on tmp.agg_centre_id = aggctr.LG_Centre_ID
and date between aggctr.from_date and aggctr.to_date
--where l13gg <> l13
--where tmp.centre_id = '848718'
group by 1,2,3,4,5

















select
--tmp.centre_id
--,tmp.agg_centre_id
trim(repctr.LG_Centre_L13_name) as l13
,trim(repctr.LG_Centre_L12_name) as l12
--,trim(repctr.LG_Centre_L11_name) as l11
--,trim(repctr.LG_Centre_L10_name) as l10
,trim(aggctr.LG_Centre_L13_name) as l13gg
,trim(aggctr.LG_Centre_L12_name) as l12gg
,ASSET_SUBCLASS
--,trim(aggctr.LG_Centre_L11_name) as l11gg
--,trim(aggctr.LG_Centre_L10_name) as l10gg
,sum(case when ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP') then ECC else 0 end) as ECC
,sum(case when ASSET_SUBCLASS not in ('SMECORP','SLIPRE','CORP') then RWA * 0.0875 else 0 end) as RWA
from
(select * from
finiq.CRDBEXTRACT a
left join finiq.TM1_CtrAgg agg
on agg.lg_centre_id = a.centre_id
where month_key in ('202011')) tmp
left join dwpviewa.LG_Hier_Centre as repctr
on tmp.centre_id = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Centre as aggctr
on tmp.agg_centre_id = aggctr.LG_Centre_ID
and date between aggctr.from_date and aggctr.to_date
--where l13gg <> l13
--where tmp.centre_id = '848718'
group by 1,2,3,4,5