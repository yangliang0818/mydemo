insert into DIM_BASS1_CHANNEL_ORG_AGENT_YYYYMMDD_TEST
    	select
		       distinct char(a.NODE_ID) channel_entity_id,
		       char(c.org_id) org_id,
		       char(E.agent_id) agent_id
	from
	(
		select
			NODE_ID                          ---原为channel_entity_id
		from
			SHDW.DWD_PRTY_NODE_INFO_DS                            ---@1、新基础模型替换 ODS_CHANNEL_ENTITY_BASIC_INFO_%1$s 无需限制有效记录的网点，
			                                                      ---    并且新模型网点信息表包含网点类型信息 无需再关联ods网点表取网点类型
		where
			              ----rec_status=1
			              ----and channel_entity_type=2 and
			 NODE_STATE in (3,11)        --准入和营业的网点
			 and   node_type in (10,11,12,13,17,27,14,16)           ---@2、两个逻辑合并 (10,11,12,13,17,27)  +(14,16)
	) a
	                 ----join
	                 ----(
	                 ----	select
	                 ----		    node_id,
	                 ----		    node_type
	                 ----	from
	                 ----		   ODS_CHANNEL_NODE_%1$s
	                 ----	where
	                 ----		rec_status=1
	                 ----		and node_type in (10,11,12,13,17,27,14,16)
	                 ----    on a.channel_entity_id=b.node_id
	 left join
		    SHDW.DIM_PRTY_ORG_NODE_REL    c                  ---@3、  新基础模型替换ODS_CHANNEL_ORG_AGENT_YYYYMMDD c
	  on  a.node_id = c.node_id
	      and c.START_DATE <='YYYY-MM-DD'  AND c.END_DATE >  'YYYY-MM-DD'    --限制拉链维表的当前有效信息
	 ----and b.NODE_TYPE = c.type                           --@4、冗余条件 删除
	join
	(
		select
			channel_entity_id,
			parent_entity
		from
			ODS_CHANNEL_ENTITY_REL_INFO_%1$s
		where
			rec_status=1
			and channel_entity_type=2         --网点的血缘关系
	) d
	on a.node_id=d.channel_entity_id
	join
	(
		select
			AGENT_ID
		from
			SHDW.DWD_PRTY_AGENT_INFO_DS                    ---@5、  新基础模型替换ODS_CHANNEL_ENTITY_BASIC_INFO_%1$s
		where
			  --rec_status=1
			  --and channel_entity_type=1 and
			 AGENT_STATE=3                              --营业代理商状态
			 and       agent_type in (1,2,3,4,6)
	) e
	on d.parent_entity=e.AGENT_ID
	                      -------join
	                      -------(
	                      -------	select
	                      -------		AGENT_ID
	                      -------	from
	                      -------		ODS_CHANNEL_AGENT_INFO_%1$s
	                      -------	where
	                      -------		rec_status=1
	                      -------		and agent_type in (1,2,3,4,6)                        --此逻辑合并到上段逻辑
	                      -------) f
	                      -------on e.channel_entity_id=f.agent_id
	join
  	(
  		select  node_id
  		from ods_channel_node_extinfo_self_%1$s
  		where
  			rec_status=1
  	) g
  	on
  		a.node_id=g.node_id
  	join
  	(
  		select   node_id
  		from ods_channel_node_extinfo_%1$s
  		where
  			rec_status=1
  	) h
  	on
  		a.node_id=h.node_id     ;