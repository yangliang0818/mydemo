/*临时表：bass1_wzh_D_channel_%s  渠道 和 运营公司的对应关系表*/
sprintf(sqlStr,create table bass1_wzh_D_channel_%s
 (node_id bigint,
 channel_entity_name varchar(128),
 org_id bigint,
 agent_id bigint,
 agent_full_name varchar(128)
 )
  DATA CAPTURE NONE
 IN %s
 INDEX IN %s
 PARTITIONING KEY
   (node_id
 ) USING HASHING,YYYYMMDD.c_str(),g_tbsname.c_str(),g_tbsindex.c_str());
insert into bass1_wzh_D_channel_%s
   select
        int(a.channel_entity_id),
        b.channel_entity_name,
        int(a.org_id),
        int(a.agent_id),
        c.channel_entity_name
   from
       dim_bass1_channel_org_agent_%s a
   left join
       (select * from DB2INFO.ods_channel_entity_basic_info_%s
       where rec_status=1
       and channel_entity_type=2
       ) b on int(a.channel_entity_id)=b.channel_entity_id
   left join
   (select * from ods_channel_entity_basic_info_%s
       where rec_status=1
       and channel_entity_type=1
    ) c on int(a.agent_id)=c.channel_entity_id,YYYYMMDD.c_str(),YYYYMMDD.c_str(),YYYYMMDD.c_str(),YYYYMMDD.c_str());








