drop table newmap;

create volatile table newMap as (
select 
child_id,
parent2_id as parent_key,
'Parent2' as id
from dwpviewa.LG_Hier
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
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
where date between from_date and to_date
and segment_type = 'Centre'
and Parent1_Id = 'CNTINT'
and parent3_id in ('RB4152','RB4892')
group by 1,2,3 
) with data
primary index(child_id,parent_key,id)
on commit preserve rows;



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


-- tidy up delete blank parent keys....
delete from oldmap where parent_key = '';
delete from newmap where parent_key = '';


-- create volatile table to insert AB Mapping
CREATE SET VOLATILE TABLE M118954.ABRep ,FALLBACK ,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP2,
     LOG
     (
      Parent_Key CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      AB_Group CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( Parent_Key , AB_Group )
ON COMMIT PRESERVE ROWS;

insert into m118954.ABRep values ('187465','ABGCC-004');
insert into m118954.ABRep values ('187535','ABGCC-004');
insert into m118954.ABRep values ('352450','ABGCC-004');
insert into m118954.ABRep values ('358779','ABGCC-004');
insert into m118954.ABRep values ('SG0112','ABGCC-022');
insert into m118954.ABRep values ('846700','ABGCC-022');
insert into m118954.ABRep values ('RB0834','ABGCC-022');
insert into m118954.ABRep values ('RB0866','ABGCC-022');
insert into m118954.ABRep values ('SG1115','ABGCC-022');
insert into m118954.ABRep values ('SG1451','ABGCC-022');
insert into m118954.ABRep values ('SG0712','ABGCC-011');
insert into m118954.ABRep values ('197410','ABGCC-012');
insert into m118954.ABRep values ('SG0460','ABGCC-011');
insert into m118954.ABRep values ('SG0783','ABGCC-016');
insert into m118954.ABRep values ('SG0774','ABGCC-016');
insert into m118954.ABRep values ('080650','ABGCC-017');
insert into m118954.ABRep values ('RB4597','ABGCC-011');
insert into m118954.ABRep values ('080900','ABGCC-012');
insert into m118954.ABRep values ('187100','ABGCC-002');
insert into m118954.ABRep values ('187405','ABGCC-002');
insert into m118954.ABRep values ('CB2400','ABGCC-002');
insert into m118954.ABRep values ('RB0777','ABGCC-002');
insert into m118954.ABRep values ('RB0782','ABGCC-002');
insert into m118954.ABRep values ('RB1109','ABGCC-002');
insert into m118954.ABRep values ('RC3814','ABGCC-002');
insert into m118954.ABRep values ('SG1447','ABGCC-002');
insert into m118954.ABRep values ('888426','ABGCC-002');
insert into m118954.ABRep values ('C108','ABGCC-002');
insert into m118954.ABRep values ('C114','ABGCC-002');
insert into m118954.ABRep values ('RB3607','ABGCC-002');
insert into m118954.ABRep values ('187200','ABGCC-001');
insert into m118954.ABRep values ('187830','ABGCC-001');
insert into m118954.ABRep values ('187183','ABGCC-001');
insert into m118954.ABRep values ('RB1042','ABGCC-001');
insert into m118954.ABRep values ('RB1897','ABGCC-001');
insert into m118954.ABRep values ('SG1480','ABGCC-001');
insert into m118954.ABRep values ('352268','ABGCC-001');
insert into m118954.ABRep values ('355863','ABGCC-001');
insert into m118954.ABRep values ('357000','ABGCC-001');
insert into m118954.ABRep values ('366000','ABGCC-001');
insert into m118954.ABRep values ('358630','ABGCC-001');
insert into m118954.ABRep values ('364000','ABGCC-001');
insert into m118954.ABRep values ('352450','ABGCC-008');
insert into m118954.ABRep values ('SG0162','ABGCC-008');
insert into m118954.ABRep values ('SG0586','ABGCC-008');
insert into m118954.ABRep values ('197899','ABGCC-009');
insert into m118954.ABRep values ('358400','ABGCC-009');
insert into m118954.ABRep values ('673099','ABGCC-009');
insert into m118954.ABRep values ('SG0262','ABGCC-019');
insert into m118954.ABRep values ('SG0591','ABGCC-019');
insert into m118954.ABRep values ('SG0594','ABGCC-019');
insert into m118954.ABRep values ('SG0704','ABGCC-019');
insert into m118954.ABRep values ('080800','ABGCC-020');
insert into m118954.ABRep values ('352301','ABGCC-020');
insert into m118954.ABRep values ('720590','ABGCC-020');
insert into m118954.ABRep values ('187830','ABGCC-026');
insert into m118954.ABRep values ('187899','ABGCC-026');
insert into m118954.ABRep values ('187200','ABGCC-026');
insert into m118954.ABRep values ('SG0112','ABGCC-021');
insert into m118954.ABRep values ('RC3812','ABGCC-021');
insert into m118954.ABRep values ('SG1480','ABGCC-021');
insert into m118954.ABRep values ('187200','ABGCC-006');
insert into m118954.ABRep values ('SG1480','ABGCC-006');
insert into m118954.ABRep values ('187183','ABGCC-006');
insert into m118954.ABRep values ('187830','ABGCC-006');
insert into m118954.ABRep values ('187899','ABGCC-025');
insert into m118954.ABRep values ('CB2508','ABGCC-025');
insert into m118954.ABRep values ('187465','ABGCC-025');
insert into m118954.ABRep values ('SG0112','ABGCC-024');
insert into m118954.ABRep values ('SG0512','ABGCC-024');
insert into m118954.ABRep values ('187535','ABGCC-024');
insert into m118954.ABRep values ('SG1480','ABGCC-024');
insert into m118954.ABRep values ('400151','ABGCC-029');
insert into m118954.ABRep values ('840000','ABGCC-029');
insert into m118954.ABRep values ('SG1452','ABGCC-029');
insert into m118954.ABRep values ('SG1477','ABGCC-005');
insert into m118954.ABRep values ('SG1476','ABGCC-013');
insert into m118954.ABRep values ('400152','ABGCC-013');
insert into m118954.ABRep values ('234458','ABGCC-013');
insert into m118954.ABRep values ('AMG058','ABGCC-013');
insert into m118954.ABRep values ('AMG062','ABGCC-013');
insert into m118954.ABRep values ('AMG063','ABGCC-013');
insert into m118954.ABRep values ('AMG065','ABGCC-013');
insert into m118954.ABRep values ('SG1479','ABGCC-013');
insert into m118954.ABRep values ('400153','ABGCC-013');
insert into m118954.ABRep values ('400059','ABGCC-014');
insert into m118954.ABRep values ('400155','ABGCC-014');
insert into m118954.ABRep values ('400156','ABGCC-014');
insert into m118954.ABRep values ('400157','ABGCC-014');
insert into m118954.ABRep values ('400WIB','ABGCC-014');
insert into m118954.ABRep values ('AMG059','ABGCC-014');
insert into m118954.ABRep values ('SG0012','ABGCC-014');
insert into m118954.ABRep values ('400154','ABGCC-023');
insert into m118954.ABRep values ('CB2320','ABGCC-023');
insert into m118954.ABRep values ('CB2827','ABGCC-023');
insert into m118954.ABRep values ('SG1478','ABGCC-023');
insert into m118954.ABRep values ('SG1481','ABGCC-023');
insert into m118954.ABRep values ('AMG056','ABGCC-023');
insert into m118954.ABRep values ('AMG067','ABGCC-023');
insert into m118954.ABRep values ('AMG069','ABGCC-023');
insert into m118954.ABRep values ('SG0429 ','ABGCC-028');
insert into m118954.ABRep values ('SG0447 ','ABGCC-028');
insert into m118954.ABRep values ('SG1447 ','ABGCC-028');
insert into m118954.ABRep values ('SG1466','ABGCC-031');
insert into m118954.ABRep values ('SG1112','ABGCC-031');
insert into m118954.ABRep values ('SG0457','ABGCC-030');
insert into m118954.ABRep values ('SG1541','ABGCC-030');
insert into m118954.ABRep values ('SG1457','ABGCC-030');
insert into m118954.ABRep values ('187200 ','ABGCC-032');
insert into m118954.ABRep values ('187830 ','ABGCC-032');
insert into m118954.ABRep values ('081606','ABGCC-032');
insert into m118954.ABRep values ('081607','ABGCC-032');
insert into m118954.ABRep values ('081608','ABGCC-032');
insert into m118954.ABRep values ('RB1042 ','ABGCC-032');
insert into m118954.ABRep values ('188230 ','ABGCC-032');
insert into m118954.ABRep values ('197900 ','ABGCC-032');
insert into m118954.ABRep values ('RB0140 ','ABGCC-032');
insert into m118954.ABRep values ('RB0802 ','ABGCC-032');
insert into m118954.ABRep values ('RE2095 ','ABGCC-032');
insert into m118954.ABRep values ('SG0924 ','ABGCC-032');
insert into m118954.ABRep values ('SG0927 ','ABGCC-032');
insert into m118954.ABRep values ('SG0933 ','ABGCC-032');
insert into m118954.ABRep values ('SG1480 ','ABGCC-032');
insert into m118954.ABRep values ('187899 ','ABGCC-032');
insert into m118954.ABRep values ('237930 ','ABGCC-032');
insert into m118954.ABRep values ('RA0083 ','ABGCC-032');
insert into m118954.ABRep values ('RB6156 ','ABGCC-032');
insert into m118954.ABRep values ('SG0112 ','ABGCC-032');
insert into m118954.ABRep values ('352268 ','ABGCC-033');
insert into m118954.ABRep values ('355863 ','ABGCC-033');
insert into m118954.ABRep values ('357000 ','ABGCC-033');
insert into m118954.ABRep values ('366000 ','ABGCC-033');
insert into m118954.ABRep values ('RE4220 ','ABGCC-033');
insert into m118954.ABRep values ('RB3609 ','ABGCC-033');
insert into m118954.ABRep values ('RA0080 ','ABGCC-033');
insert into m118954.ABRep values ('364000 ','ABGCC-033');
insert into m118954.ABRep values ('358630 ','ABGCC-033');
insert into m118954.ABRep values ('187200','ABGCC-034');
insert into m118954.ABRep values ('187830','ABGCC-034');
insert into m118954.ABRep values ('RB1042','ABGCC-034');
insert into m118954.ABRep values ('188230','ABGCC-034');
insert into m118954.ABRep values ('197900','ABGCC-034');
insert into m118954.ABRep values ('RB0140','ABGCC-034');
insert into m118954.ABRep values ('RB0802','ABGCC-034');
insert into m118954.ABRep values ('RE2095','ABGCC-034');
insert into m118954.ABRep values ('SG0924','ABGCC-034');
insert into m118954.ABRep values ('SG0927','ABGCC-034');
insert into m118954.ABRep values ('SG0933','ABGCC-034');
insert into m118954.ABRep values ('SG1480','ABGCC-034');
insert into m118954.ABRep values ('187899','ABGCC-034');
insert into m118954.ABRep values ('237930','ABGCC-034');
insert into m118954.ABRep values ('RA0083','ABGCC-034');
insert into m118954.ABRep values ('RB6156','ABGCC-034');
insert into m118954.ABRep values ('SG0112','ABGCC-034');
insert into m118954.ABRep values ('188230','ABGCC-035');
insert into m118954.ABRep values ('197900','ABGCC-035');
insert into m118954.ABRep values ('RB0140','ABGCC-035');
insert into m118954.ABRep values ('RB0802','ABGCC-035');
insert into m118954.ABRep values ('RE2095','ABGCC-035');
insert into m118954.ABRep values ('SG0924','ABGCC-035');
insert into m118954.ABRep values ('SG0927','ABGCC-035');
insert into m118954.ABRep values ('SG0933','ABGCC-035');
insert into m118954.ABRep values ('187899','ABGCC-036');
insert into m118954.ABRep values ('237930','ABGCC-036');
insert into m118954.ABRep values ('RA0083','ABGCC-036');
insert into m118954.ABRep values ('RB6156','ABGCC-036');
insert into m118954.ABRep values ('SG0112','ABGCC-036');
insert into m118954.ABRep values ('187100','ABGCC-037');
insert into m118954.ABRep values ('187405','ABGCC-037');
insert into m118954.ABRep values ('888426','ABGCC-037');
insert into m118954.ABRep values ('CB2400','ABGCC-037');
insert into m118954.ABRep values ('CB5000','ABGCC-037');
insert into m118954.ABRep values ('RB0777','ABGCC-037');
insert into m118954.ABRep values ('RB0782','ABGCC-037');
insert into m118954.ABRep values ('RB1109','ABGCC-037');
insert into m118954.ABRep values ('RC3814','ABGCC-037');
insert into m118954.ABRep values ('SG1447','ABGCC-037');
insert into m118954.ABRep values ('187100','ABGCC-038');
insert into m118954.ABRep values ('187405','ABGCC-038');
insert into m118954.ABRep values ('888426','ABGCC-038');
insert into m118954.ABRep values ('CB2400','ABGCC-038');
insert into m118954.ABRep values ('RB0777','ABGCC-038');
insert into m118954.ABRep values ('RB0782','ABGCC-038');
insert into m118954.ABRep values ('RB1109','ABGCC-038');
insert into m118954.ABRep values ('RC3814','ABGCC-038');
insert into m118954.ABRep values ('SG1447','ABGCC-038');
insert into m118954.ABRep values ('187200','ABGCC-039');
insert into m118954.ABRep values ('187830','ABGCC-039');
insert into m118954.ABRep values ('352268','ABGCC-039');
insert into m118954.ABRep values ('187183','ABGCC-039');
insert into m118954.ABRep values ('358630','ABGCC-039');
insert into m118954.ABRep values ('RB0828','ABGCC-039');
insert into m118954.ABRep values ('RB1042','ABGCC-039');
insert into m118954.ABRep values ('188230','ABGCC-039');
insert into m118954.ABRep values ('197900','ABGCC-039');
insert into m118954.ABRep values ('RB0140','ABGCC-039');
insert into m118954.ABRep values ('RB0802','ABGCC-039');
insert into m118954.ABRep values ('RE2095','ABGCC-039');
insert into m118954.ABRep values ('SG0924','ABGCC-039');
insert into m118954.ABRep values ('SG0927','ABGCC-039');
insert into m118954.ABRep values ('SG0933','ABGCC-039');
insert into m118954.ABRep values ('SG1480','ABGCC-039');
insert into m118954.ABRep values ('187200','ABGCC-040');
insert into m118954.ABRep values ('187830','ABGCC-040');
insert into m118954.ABRep values ('352268','ABGCC-040');
insert into m118954.ABRep values ('187183','ABGCC-040');
insert into m118954.ABRep values ('358630','ABGCC-040');
insert into m118954.ABRep values ('RB1042','ABGCC-040');
insert into m118954.ABRep values ('188230','ABGCC-040');
insert into m118954.ABRep values ('197900','ABGCC-040');
insert into m118954.ABRep values ('RB0140','ABGCC-040');
insert into m118954.ABRep values ('RB0802','ABGCC-040');
insert into m118954.ABRep values ('RE2095','ABGCC-040');
insert into m118954.ABRep values ('SG0924','ABGCC-040');
insert into m118954.ABRep values ('SG0927','ABGCC-040');
insert into m118954.ABRep values ('SG0933','ABGCC-040');
insert into m118954.ABRep values ('SG1480','ABGCC-040');
insert into m118954.ABRep values ('355863','ABGCC-041');
insert into m118954.ABRep values ('357000','ABGCC-041');
insert into m118954.ABRep values ('366000','ABGCC-041');
insert into m118954.ABRep values ('364000','ABGCC-041');
insert into m118954.ABRep values ('RB3609','ABGCC-041');
insert into m118954.ABRep values ('187100','ABGCC-042');
insert into m118954.ABRep values ('504106','ABGCC-042');
insert into m118954.ABRep values ('CB2508','ABGCC-042');
insert into m118954.ABRep values ('CB5030','ABGCC-043');
insert into m118954.ABRep values ('SG0512','ABGCC-043');
insert into m118954.ABRep values ('SG0429','ABGCC-043');
insert into m118954.ABRep values ('SG0447','ABGCC-043');
insert into m118954.ABRep values ('SG1447','ABGCC-043');
insert into m118954.ABRep values ('504106','ABGCC-044');
insert into m118954.ABRep values ('CB2508','ABGCC-044');
insert into m118954.ABRep values ('187899','ABGCC-044');
insert into m118954.ABRep values ('RB6156','ABGCC-044');
insert into m118954.ABRep values ('187465','ABGCC-044');
insert into m118954.ABRep values ('353000','ABGCC-044');
insert into m118954.ABRep values ('352403','ABGCC-045');
insert into m118954.ABRep values ('CB5030','ABGCC-045');
insert into m118954.ABRep values ('SG0512','ABGCC-045');
insert into m118954.ABRep values ('SG0429','ABGCC-045');
insert into m118954.ABRep values ('SG0447','ABGCC-045');
insert into m118954.ABRep values ('SG1447','ABGCC-045');
insert into m118954.ABRep values ('RA0083','ABGCC-045');
insert into m118954.ABRep values ('SG0112','ABGCC-045');
insert into m118954.ABRep values ('187535','ABGCC-045');
insert into m118954.ABRep values ('SG1480','ABGCC-045');
insert into m118954.ABRep values ('187113','ABGCC-046');
insert into m118954.ABRep values ('187119','ABGCC-046');
insert into m118954.ABRep values ('211480','ABGCC-046');
insert into m118954.ABRep values ('740400','ABGCC-046');
insert into m118954.ABRep values ('RB3995','ABGCC-046');
insert into m118954.ABRep values ('RB0818','ABGCC-046');
insert into m118954.ABRep values ('RB0819','ABGCC-046');
insert into m118954.ABRep values ('RB3625','ABGCC-046');
insert into m118954.ABRep values ('187360','ABGCC-046');
insert into m118954.ABRep values ('RB4079','ABGCC-046');
insert into m118954.ABRep values ('RB5049','ABGCC-046');
insert into m118954.ABRep values ('187128','ABGCC-047');
insert into m118954.ABRep values ('187214','ABGCC-047');
insert into m118954.ABRep values ('187209','ABGCC-047');
insert into m118954.ABRep values ('187218','ABGCC-047');
insert into m118954.ABRep values ('CB2701','ABGCC-047');
insert into m118954.ABRep values ('710000','ABGCC-047');
insert into m118954.ABRep values ('RB5063','ABGCC-047');
insert into m118954.ABRep values ('710016','ABGCC-047');
insert into m118954.ABRep values ('187880','ABGCC-047');
insert into m118954.ABRep values ('710022','ABGCC-047');
insert into m118954.ABRep values ('187226','ABGCC-047');
insert into m118954.ABRep values ('SG0466','ABGCC-048');
insert into m118954.ABRep values ('SG1100','ABGCC-048');
insert into m118954.ABRep values ('SG1577','ABGCC-048');
insert into m118954.ABRep values ('CBG001','ABGCC-048');
insert into m118954.ABRep values ('SG0299','ABGCC-048');
insert into m118954.ABRep values ('SG1474','ABGCC-048');
insert into m118954.ABRep values ('SG1450','ABGCC-048');
insert into m118954.ABRep values ('SG0011','ABGCC-048');
insert into m118954.ABRep values ('CB2931','ABGCC-049');
insert into m118954.ABRep values ('731160','ABGCC-049');
insert into m118954.ABRep values ('187820','ABGCC-049');
insert into m118954.ABRep values ('CB2800','ABGCC-049');
insert into m118954.ABRep values ('RC3884','ABGCC-049');
insert into m118954.ABRep values ('CB2934','ABGCC-049');
insert into m118954.ABRep values ('RM4380','ABGCC-049');
insert into m118954.ABRep values ('RM4400','ABGCC-049');
insert into m118954.ABRep values ('188170','ABGCC-049');
insert into m118954.ABRep values ('SG0896','ABGCC-050');
insert into m118954.ABRep values ('RB0866','ABGCC-050');
insert into m118954.ABRep values ('SG1110','ABGCC-050');
insert into m118954.ABRep values ('SG1115','ABGCC-050');
insert into m118954.ABRep values ('SG1449','ABGCC-050');
insert into m118954.ABRep values ('SG1104','ABGCC-050');
insert into m118954.ABRep values ('SG1106','ABGCC-050');
insert into m118954.ABRep values ('SG1097','ABGCC-050');
insert into m118954.ABRep values ('RC3955','ABGCC-051');
insert into m118954.ABRep values ('SG1451','ABGCC-051');



-- create volatile table for mapping
CREATE SET VOLATILE TABLE M118954.HierLabel ,FALLBACK ,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP2,
     LOG
     (
      Parent_Key CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      Label CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( Parent_Key )
ON COMMIT PRESERVE ROWS;


insert into hierlabel
select 
lg_centre_l13_key as parent_key,
trim(lg_centre_l13_name) as Label
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2
union all
select 
lg_centre_l12_key as parent_key,
trim(lg_centre_l12_name) as Label
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2
union all
select 
lg_centre_l11_key as parent_key,
trim(lg_centre_l11_name) as Label
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2
union all
select 
lg_centre_l10_key as parent_key,
trim(lg_centre_l10_name) as Label
from dwpviewa.lg_hier_centre
where date between from_date and to_date
and lg_centre_l14_key in ('RB4892','RB4152')
group by 1,2







-- check movements at level 14



select 
a.parent_key as Old_keys,
b.parent_key as New_keys,
c.label as oldLabel,
d.label as newLabel
from 
oldmap a
inner join newmap b
on a.child_id = b.child_id
left join hierlabel c
on c.parent_key = a.parent_key
left join hierlabel d
on d.parent_key = b.parent_key
where  a.id = b.id
--and a.child_id = '842211'
and a.id = 'Parent4'    -- change this parent to see the different levels.............l13 = parent 4
and a.parent_key <> b.parent_key
group by 1,2,3,4





