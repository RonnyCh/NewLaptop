
-- notes
-- 1. find the parent key for exploding (change the parent key as required below
-- 2. specify the parents to match again 1 to see if there are duplicates

select
tmp.parent_key
from
(select 
parent7_id as parent_key
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
and parent6_id = 'ADSAAC'
group by 1
union all
select 
parent8_id
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
and parent6_id = 'ADSAAC'
group by 1
union all
select 
parent9_id
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
and parent6_id = 'ADSAAC'
group by 1
union all
select 
parent9_id
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
and parent6_id = 'ADSAAC'
group by 1
union all
select 
parent10_id
from DWPVTBLA.LG_Hier
where date between from_date and to_date
and segment_type = 'Account'
AND PARENT1_ID IN ('SACCTS','MARACT')
and parent6_id = 'ADSAAC'
group by 1
) tmp
where tmp.parent_key in

 (
'A9FSUB',
'A9INVS',
'AAFSEC',
'AASSOC',
'ACASHB',
'ADEFTX',
'ADERVS',
'AGOOIA',
'ALIFEI',
'AOFAFV',
'AOTHER',
'APPEQU',
'ARECFI',
'AREGDP',
'ATRADS')