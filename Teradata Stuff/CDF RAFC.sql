-- example 1 where you can link it with TM1 CDV
select 
count(rpm.cust_id)
from ewp1vafca.RAFC_Armt_GL_Compnt_Mth a
left join EWP1VAFCA.RAFC_Party_Armt_Link_Mth b
on b.armt_key = a.armt_key
and 1210331 between b.from_date and b.to_date
left outer join EWP1VAFCA.RAFC_Party_Mth RPM
on b.Party_Key = RPM.Party_Key
and 1210331 between rpm.from_date and rpm.to_date
left join dwpviewa.lg_hier_product prod
on prod.lg_product_id = a.acctg_pdct_id
and date between prod.from_date and prod.to_date
left join dwpviewa.lg_hier_account acct
on acct.lg_account_id = a.acctg_acct_id
and date between acct.from_date and acct.to_date
left join dwpviewa.lg_hier_centre ctr
on ctr.lg_centre_id = a.rpt_centre_id
and 1210331 between ctr.from_date and ctr.to_date
where 1210331 between a.from_date and a.to_Date
and a.acctg_pdct_id = '11201'
and a.acctg_acct_id = '146200'
and a.rpt_centre_id = '219047'
and bal_type_code = 'BAL'
--group by 1,2,3,4





select * from ewp1viewa.ZVPS_Merchant_Statement_BOM
where process_date = 1171130
and merchant_nbr = 3434313



select *
from ewp1viewa.ZVPS_Merchant
where merchant_nbr = 2074888
and date between from_date and to_date



select * from ewp1vafca.RAFC_Armt_Merchnt_Mth
where armt_key = 'CW-018:SGB:MER0000000002074888'


select * from EWP1VAFCA.RAFC_Party_Mth
--where party_key = 'GCM:PY:338BFB25-2ABF-11e6-A996-000C00000000'
where cust_id = 55441112
and 1210331 between from_date and to_date


select * from EWP1VAFCA.RAFC_Party_Armt_Link_Mth
where armt_key = 'CW-018:SGB:MER0000000002074888'
and date