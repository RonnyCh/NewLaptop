select
'ECC' as typ,
trim(repctr.LG_Centre_L13_name) 
,trim(prod.LG_Product_L10_Name)
,sum(a.ecc) as LM
,sum(b.ecc) as TM
,(LM - TM) as var
from Retsys.CRDBEXTRACT2004 a
inner join Retsys.CRDBEXTRACT2005 b
on a.account_id = b.account_id
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.Product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
where trim(repctr.LG_Centre_L14_name) in ('Business','Consumer')
group by 1,2,3
order by 1,2;





select
'RWA' as typ
,trim(repctr.LG_Centre_L13_name) 
,trim(prod.LG_Product_L10_Name)
,sum(case when a.RWA is null then 0 else a.RWA end) as LM
,sum(case when b.RWA is null then 0 else b.RWA end) as TM
,(LM - TM) as var
from Retsys.CRDBEXTRACT2004 a
inner join Retsys.CRDBEXTRACT2005 b
on a.account_id = b.account_id
left join dwpviewa.LG_Hier_Centre as repctr
on a.Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
left join dwpviewa.LG_Hier_Product as prod
on a.Product_code = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
where trim(repctr.LG_Centre_L14_name) in ('Business','Consumer')
group by 1,2,3
order by 1,2;




