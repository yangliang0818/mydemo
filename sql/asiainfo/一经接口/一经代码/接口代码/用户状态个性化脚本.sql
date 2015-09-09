insert into bass1_map values('BASS_STD1_0052','用户状态','100','1010');
insert into bass1_map values('BASS_STD1_0052','用户状态','110','1039');
insert into bass1_map values('BASS_STD1_0052','用户状态','101','1022');
insert into bass1_map values('BASS_STD1_0052','用户状态','104','1021');
insert into bass1_map values('BASS_STD1_0052','用户状态','109','2020');
insert into bass1_map values('BASS_STD1_0052','用户状态','111','1040');
insert into bass1_map values('BASS_STD1_0052','用户状态','112','2030');
insert into bass1_map values('BASS_STD1_0052','用户状态','114','1033');

--一经的用户状态只能是1变化为1或2，2可以再变回1，但是2与2之前不能进行变化
--BASS_STD1_0075编码转换
insert into bass1_map_2
with t1 (old_id,new_id) as (select old_id,new_id from shdw.DIM_NEW_OLD_RELATE_MAP where item_type ='SRVC_SINGLE'),
t2(map_id,map_name,BOSS_VALUE_LEVEL1,BOSS_VALUE_LEVEL2,BASS1_VALUE_LEVEL1,BASS1_VALUE_LEVER2) as
(select map_id,map_name,BOSS_VALUE_LEVEL1,BOSS_VALUE_LEVEL2,BASS1_VALUE_LEVEL1,BASS1_VALUE_LEVER2 from shbass.BASS1_MAP_2 where map_id ='BASS_STD1_0075'),
t3(map_id,map_name,BOSS_VALUE_LEVEL1,BOSS_VALUE_LEVEL2,BASS1_VALUE_LEVEL1,BASS1_VALUE_LEVER2) as
(select map_id,map_name,t1.new_id,BOSS_VALUE_LEVEL2,BASS1_VALUE_LEVEL1,BASS1_VALUE_LEVER2 from t2 left join t1 on t2.BOSS_VALUE_LEVEL1=t1.old_id)
select t3.map_id,t3.map_name,t3.BOSS_VALUE_LEVEL1,t3.BOSS_VALUE_LEVEL2,t3.BASS1_VALUE_LEVEL1,t3.BASS1_VALUE_LEVER2 from t3 left join bass1_map_2 a
on t3.map_id = a.map_id and t3.BOSS_VALUE_LEVEL1 = a.BOSS_VALUE_LEVEL1 and t3.BOSS_VALUE_LEVEL2=a.BOSS_VALUE_LEVEL2 and t3.BASS1_VALUE_LEVEL1=a.BASS1_VALUE_LEVEL1
and t3.BASS1_VALUE_LEVER2=a.BASS1_VALUE_LEVER2
where a.BOSS_VALUE_LEVEL1 is null;

insert into SHBASS.BASS1_02008_USER_STATUS_LOCAL_20150430
 select A.user_id,B.BASS1_VALUE from shdw.dwd_svc_usr_all_info_20150430 a join shbass.bass1_map b
on a.offer_id in (380000184301,380000184302) and a.BASS_USER_STATE_ID=b.BOSS_VALUE AND B.MAP_ID='BASS_STD1_0052';