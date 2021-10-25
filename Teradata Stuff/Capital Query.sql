


select 
sum(case when month_key = '202102' then ECC else 0 end) as Feb_ECC,
sum(case when month_key = '202103' then ECC else 0 end) as Mar_ECC,
sum(case when month_key = '202102' then RWA else 0 end) as Feb_RWA,
sum(case when month_key = '202103' then RWA else 0 end) as Mar_RWA
from finiq.CRDBextract
where month_key in ('202103','202102')
and asset_subclass = 'MRTG'
and centre_id is not null
and centre_id <> 'N/A';




select 
sum(case when month_key = '202102' then ECC else 0 end) as Feb_ECC,
sum(case when month_key = '202103' then ECC else 0 end) as Mar_ECC,
sum(case when month_key = '202102' then RWA else 0 end) as Feb_RWA,
sum(case when month_key = '202103' then RWA else 0 end) as Mar_RWA
from finiq.CRDBextract
where month_key in ('202103','202102')
and asset_subclass = 'MRTG';
and (centre_id is null or centre_id <> 'N/A')





sel 
a.asset_subclass
,case when centre_id is null then 'Unknown' else trim(b.LG_Centre_L14_Name) end asCtr14
,case when centre_id is null then 'Unknown' else trim(b.LG_Centre_L13_Name) end asCtr13
,sum(a.RWA) 
from finiq.CRDBextract a
left join dwpviewa.LG_Hier_Centre b
on a.centre_id = b.LG_centre_id
where a.month_key = '202103'
and Date between b.From_Date and b.To_Date
and a.asset_subclass = 'MRTG'
and a.centre_id is null
group by 1,2,3
order by 2
;

