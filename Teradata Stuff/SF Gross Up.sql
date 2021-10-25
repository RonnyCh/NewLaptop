

-- create hieararchy table based on parents
drop table oldmap;

create volatile table oldMap as (
select 
child_id,
parent2_id as parent_key,
'Parent2' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent3_id as parent_key,
'Parent3' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent4_id as parent_key,
'Parent4' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent5_id as parent_key,
'Parent5' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent6_id as parent_key,
'Parent6' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent7_id as parent_key,
'Parent7' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent8_id as parent_key,
'Parent8' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent9_id as parent_key,
'Parent9' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
union all
select 
child_id,
parent10_id as parent_key,
'Parent10' as id
from dwpviewa.LG_Hier
where ?MonthEnd   between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
) with data
primary index(child_id,parent_key,id)
on commit preserve rows;





-- create temp table

drop table m118954.SFGross;

CREATE SET VOLATILE TABLE M118954.SFGross ,FALLBACK ,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP2,
     LOG
     (
      mykey CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      contra CHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( mykey , contra)
ON COMMIT PRESERVE ROWS;


--- insert the data
insert into m118954.SFGross values ('187128','073377 - WEF Third Party ALM adj ctr');
insert into m118954.SFGross values ('187218','075650 - WEF RM NSW');
insert into m118954.SFGross values ('RB1735','075650 - WEF RM NSW');
insert into m118954.SFGross values ('RB3145','075650 - WEF RM NSW');
insert into m118954.SFGross values ('187224','075660 - WEF RM QLD');
insert into m118954.SFGross values ('RB1831','075660 - WEF RM QLD');
insert into m118954.SFGross values ('RB3164','075660 - WEF RM QLD');
insert into m118954.SFGross values ('187219','075685 - WEF RM VIC');
insert into m118954.SFGross values ('RB1811','075685 - WEF RM VIC');
insert into m118954.SFGross values ('RB3147','075685 - WEF RM VIC');
insert into m118954.SFGross values ('PSOMGR','075688 - WEF RM SANTAS');
insert into m118954.SFGross values ('RB1837','075688 - WEF RM SANTAS');
insert into m118954.SFGross values ('187225','075690 - WEF RM WA');
insert into m118954.SFGross values ('RB1841','075690 - WEF RM WA');
insert into m118954.SFGross values ('RB3175','075690 - WEF RM WA');
insert into m118954.SFGross values ('7014','075693 - WEF RM HO');
insert into m118954.SFGross values ('RB3179','075693 - WEF RM HO');
insert into m118954.SFGross values ('RB1112','075695 - WEF RM ALM Adj ctr');
insert into m118954.SFGross values ('CB2934','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2075','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2636','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2935','090051 - WEF EF 1st Party QLD');
insert into m118954.SFGross values ('CB2927','090051 - WEF EF 1st Party QLD');
insert into m118954.SFGross values ('CB2936','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('RB0815','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('CB2933','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('CB2938','090130 - WEF EF 1st Party SANTAS');
insert into m118954.SFGross values ('CB2865','090130 - WEF EF 1st Party SANTAS');
insert into m118954.SFGross values ('CB2937','090132 - WEF EF 1st Party WA');
insert into m118954.SFGross values ('CB2940','090132 - WEF EF 1st Party WA');
insert into m118954.SFGross values ('RB9060','090145 - WEF EF 1st Party HO');
insert into m118954.SFGross values ('731095','090170 - WEF EF 1st Party ALM adj ctr');
insert into m118954.SFGross values ('RB9040','090170 - WEF EF 1st Party ALM adj ctr');
insert into m118954.SFGross values ('SG1449','092301 - STG EF 1st Party NSW');
insert into m118954.SFGross values ('SG1119','092301 - STG EF 1st Party NSW');
insert into m118954.SFGross values ('CBG001','092301 - STG EF 1st Party NSW');
insert into m118954.SFGross values ('SG1110','092302 - STG EF 1st Party QLD');
insert into m118954.SFGross values ('SG1571','092302 - STG EF 1st Party QLD');
insert into m118954.SFGross values ('CB5013','092302 - STG EF 1st Party QLD');
insert into m118954.SFGross values ('SG1104','092304 - STG EF 1st Party VIC');
insert into m118954.SFGross values ('SG1559','092304 - STG EF 1st Party VIC');
insert into m118954.SFGross values ('HOUTOT','092304 - STG EF 1st Party VIC');
insert into m118954.SFGross values ('SG1097','092345 - STG EF 1st Party SANTAS');
insert into m118954.SFGross values ('SG0871','092345 - STG EF 1st Party SANTAS');
insert into m118954.SFGross values ('GSTGTT','092345 - STG EF 1st Party SANTAS');
insert into m118954.SFGross values ('SG1106','092435 - STG EF 1st Party WA');
insert into m118954.SFGross values ('SG1562','092435 - STG EF 1st Party WA');
insert into m118954.SFGross values ('CB6000','092435 - STG EF 1st Party WA');
insert into m118954.SFGross values ('SG1115','092518 - STG EF 1st Party HO');
insert into m118954.SFGross values ('RB9040','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('731095','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('RB9060','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('187208','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('7014','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('187270','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('RB1112','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('RB3179','090329 - Invoice Finance ALM adj ctr');
insert into m118954.SFGross values ('CB2936','096375 - Invoice Finance (WIF) VIC');
insert into m118954.SFGross values ('RB0815','096375 - Invoice Finance (WIF) VIC');
insert into m118954.SFGross values ('187219','096375 - Invoice Finance (WIF) VIC');
insert into m118954.SFGross values ('CB2933','096375 - Invoice Finance (WIF) VIC');
insert into m118954.SFGross values ('RB3147','096375 - Invoice Finance (WIF) VIC');
insert into m118954.SFGross values ('CB2938','096380 - Invoice Finance (WIF) SA/NT');
insert into m118954.SFGross values ('CB2865','096380 - Invoice Finance (WIF) SA/NT');
insert into m118954.SFGross values ('PSOMGR','096380 - Invoice Finance (WIF) SA/NT');
insert into m118954.SFGross values ('CB2937','096426 - Invoice Finance (WIF) WA');
insert into m118954.SFGross values ('187225','096426 - Invoice Finance (WIF) WA');
insert into m118954.SFGross values ('CB2940','096426 - Invoice Finance (WIF) WA');
insert into m118954.SFGross values ('RB3175','096426 - Invoice Finance (WIF) WA');
insert into m118954.SFGross values ('CB2934','096435 - Invoice Finance (WIF) NSW');
insert into m118954.SFGross values ('CB2075','096435 - Invoice Finance (WIF) NSW');
insert into m118954.SFGross values ('CB2636','096435 - Invoice Finance (WIF) NSW');
insert into m118954.SFGross values ('187218','096435 - Invoice Finance (WIF) NSW');
insert into m118954.SFGross values ('RB3145','096435 - Invoice Finance (WIF) NSW');
insert into m118954.SFGross values ('CB2935','096480 - Invoice Finance (WIF) QLD');
insert into m118954.SFGross values ('CB2927','096480 - Invoice Finance (WIF) QLD');
insert into m118954.SFGross values ('187224','096480 - Invoice Finance (WIF) QLD');
insert into m118954.SFGross values ('RB3164','096480 - Invoice Finance (WIF) QLD');
insert into m118954.SFGross values ('RC3812','840061 - St George Asset Lending - Trade and Cash Flow ALM Adj Centre');
insert into m118954.SFGross values ('187128','073377 - WEF Third Party ALM adj ctr');
insert into m118954.SFGross values ('RB3145','075650 - WEF RM NSW');
insert into m118954.SFGross values ('RB3164','075660 - WEF RM QLD');
insert into m118954.SFGross values ('RB3147','075685 - WEF RM VIC');
insert into m118954.SFGross values ('RB3175','075690 - WEF RM WA');
insert into m118954.SFGross values ('RB3179','075693 - WEF RM HO');
insert into m118954.SFGross values ('CB2934','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2075','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2636','076800 - WEF EF 1st Party NSW');
insert into m118954.SFGross values ('CB2935','090051 - WEF EF 1st Party QLD');
insert into m118954.SFGross values ('CB2927','090051 - WEF EF 1st Party QLD');
insert into m118954.SFGross values ('CB2936','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('RB0815','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('CB2933','090052 - WEF EF 1st Party VIC');
insert into m118954.SFGross values ('CB2938','090130 - WEF EF 1st Party SANTAS');
insert into m118954.SFGross values ('CB2865','090130 - WEF EF 1st Party SANTAS');
insert into m118954.SFGross values ('CB2937','090132 - WEF EF 1st Party WA');
insert into m118954.SFGross values ('CB2940','090132 - WEF EF 1st Party WA');
insert into m118954.SFGross values ('RB9060','090145 - WEF EF 1st Party HO');
insert into m118954.SFGross values ('731095','090170 - WEF EF 1st Party ALM adj ctr');
insert into m118954.SFGross values ('RB9040','090170 - WEF EF 1st Party ALM adj ctr');





-- run report to get the lowest level and use those centres against new hiearchy to figure out the mapping
create volatile table f as (
select 
b.child_id,
a.mykey,
a.contra
from M118954.SFGross a
inner join oldmap b
on b.parent_key = a.mykey
group by 1,2,3) 
with data
primary index(child_id,mykey,contra)
on commit preserve rows;



-- report

select 
a.child_id ,
a.mykey,
a.contra,
c.lg_centre_l13_name,
c.lg_centre_l12_name,
c.lg_centre_l11_name,
c.lg_centre_l10_name,
b.lg_centre_l13_name,
b.lg_centre_l12_name,
b.lg_centre_l11_name,
b.lg_centre_l10_name,
b.lg_centre_l13_key,
b.lg_centre_l12_key,
b.lg_centre_l11_key,
b.lg_centre_l10_key
from f  a
inner join dwpviewa.lg_hier_centre b
on a.child_id = b.lg_centre_id
and date between b.from_date and b.to_date
inner join dwpviewa.lg_hier_centre c
on a.child_id = c.lg_centre_id
and 1191231 between c.from_date and c.to_date
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15