
select a.* ,
trim(relctr.LG_Centre_L13_name),
trim(relctr.LG_Centre_L12_name),
trim(repctr.LG_Centre_L13_name),
trim(repctr.LG_Centre_L12_name),
case when a.lg_relationship_centre_id = a.reporting_centre_id then 'Same' else 'Diff' end as status
from 
finiq.FQ_ADJ_LGR_RPT a
left join dwpviewa.LG_Hier_Centre as relctr
on a.lg_relationship_Centre_ID = relctr.LG_Centre_ID
and date between relctr.from_date and relctr.to_date
left join dwpviewa.LG_Hier_Centre as repctr
on a.reporting_Centre_ID = repctr.LG_Centre_ID
and date between repctr.from_date and repctr.to_date
where reporting_mth = '201902'
and trim(relctr.LG_Centre_L12_key) = 'SG1479'