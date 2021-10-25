

--run this only if you want to bring the original mapping before 10/11/2021'
--delete from finiq.TM1_CtrAgg;
--insert into finiq.TM1_CtrAgg
--select * from finiq.TM1_CtrAggOld;


-- full check table contains everything 
DROP TABLE FULLCHK;

create volatile table fullChk as (
select
tmp.centre_id
,tmp.agg_centre_id
,trim(repctr.LG_Centre_L13_name) as l13
,trim(repctr.LG_Centre_L12_name) as l12
,trim(repctr.LG_Centre_L11_name) as l11
,trim(repctr.LG_Centre_L12_key) as l12Key
,trim(repctr.LG_Centre_L11_key) as l11Key
,trim(aggctr.LG_Centre_L13_name) as l13agg
,trim(aggctr.LG_Centre_L12_name) as l12agg
,trim(aggctr.LG_Centre_L11_name) as l11agg
,case when repctr.LG_Centre_L12_key = 'CB2937' then '140178'
when repctr.LG_Centre_L12_key = 'CB1330' then '534150'
when repctr.LG_Centre_L12_key = 'CB2935' then '142295'
when repctr.LG_Centre_L12_key = 'RB9060' then '849337'
when repctr.LG_Centre_L11_key = 'CB2931' then '535090'
when repctr.LG_Centre_L11_key = 'RC3884' then '140178'
when repctr.LG_Centre_L11_key = 'RM4380' then '140226'
when repctr.LG_Centre_L11_key = 'CB2800' then '533990'
when repctr.LG_Centre_L11_key = '188170' then '740337'
when repctr.LG_Centre_L11_key = 'RM4400' then '140175'
when repctr.LG_Centre_L11_key = '188260' then '731296' 
when repctr.LG_Centre_L11_key = 'RB5063' then '219051' 
when repctr.LG_Centre_L11_key = 'SG0457' then '848362' 
when repctr.LG_Centre_L11_key = '187530' then '162091' 
when repctr.LG_Centre_L11_key = '187219' then '219080' 
when repctr.LG_Centre_L11_key = 'SG0011' then '848508'
when repctr.LG_Centre_L11_key = '187226' then '848508'
when repctr.LG_Centre_L11_key = '187226' then '219043'
when repctr.LG_Centre_L11_key = 'RB0130' then '534617'
when repctr.LG_Centre_L11_key = 'CB2701' then '219065'
when repctr.LG_Centre_L11_key = '710016' then '219042'
when repctr.LG_Centre_L11_key = '187170' then '740337'
when repctr.LG_Centre_L11_key = 'RB7262' then '550730'
when repctr.LG_Centre_L11_key = 'RB7238' then '219092'
when repctr.LG_Centre_L11_key = 'RB0817' then '160682'
when repctr.LG_Centre_L11_key = '187640' then '219091'
when repctr.LG_Centre_L11_key = '187225' then '219096'
end as NewAgg
,case when tmp.agg_centre_id is null then 'Issue'
when l12 <> l12agg then 'Issue' else 'OK' end as flag
,sum(case when ASSET_SUBCLASS in ('SMECORP','SLIPRE','CORP','SOV') and l13agg not in ('Auto and Novated Finance','Strategic Alliance') then ECC else 0 end) as ECC
,sum(case when l13agg in ('Auto and Novated Finance','Strategic Alliance') then RWA * 0.0875
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
--and l13 = 'Commercial Banking'
-- trim(aggctr.LG_Centre_L12_name) <> 'Home Ownership Distribution'
-- and trim(repctr.LG_Centre_L11_name) <> 'STG Cash Flow'
--where tmp.centre_id = '848718'
group by 1,2,3,4,5,6,7,8,9,10,11,12
) with data
on commit preserve rows;


-- update previous status (old) to existing since they have been changed.
update finiq.tm1_ctragg
set status = 'Existing';


-- add the new mapping to existing agg mapping
insert into finiq.tm1_ctragg
select 
'New' as status,
centre_id,
newagg,
newagg,
newagg,
l11key
from fullChk
where flag = 'Issue'
and newagg is not null
group by 1,2,3,4,5,6;


-- show if there are new mapping issue

select * from finiq.tm1_ctragg
where status = 'New'


