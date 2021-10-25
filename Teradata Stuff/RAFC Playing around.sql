


-- rafc link between armt key and gdw key
select * from ewp1viewa.Armt_GDW_Link

-- example 1 where you can link it with TM1 CDV
select 
a.*,
b.party_key,
b.party_role_code,
rpm.*
from ewp1vafca.RAFC_Armt_GL_Compnt_Mth a
left join EWP1VAFCA.RAFC_Party_Armt_Link_Mth b
on b.armt_key = a.armt_key
and date between b.from_date and b.to_date
left outer join EWP1VAFCA.RAFC_Party_Mth RPM
on b.Party_Key = RPM.Party_Key
and date between rpm.from_date and rpm.to_date
where 1210331 between a.from_date and a.to_Date
and a.acctg_pdct_id = '11201'
and a.acctg_acct_id = '146200'
and a.rpt_centre_id = '219047'



select 
party_role_code
from EWP1VAFCA.RAFC_Party_Armt_Link_Mth
group by 1


select * from EWP1VAFCA.RAFC_Tran_Type_GL_Map


select * from EWP1VAFCA.RAFC_Party_Mth
where post_code = '2000'


select 
rafc_status_code
from EWP1VAFCA.RAFC_Party_Mth
where post_code = '2000'
group by 1



select 
party_type_code
from EWP1VAFCA.RAFC_Party_Mth
group by 1



select * from EWP1ViewA.Party_Psn
where abn_num <> 0