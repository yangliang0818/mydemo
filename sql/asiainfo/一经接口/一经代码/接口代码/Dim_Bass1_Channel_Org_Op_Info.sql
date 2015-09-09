CREATE TABLE DIM_BASS1_CHANNEL_ORG_OP_INFO_YYYYMMDD
(
  ORG_CLASS1     VARCHAR(12),--一级分类
  ORG_CLASS2     VARCHAR(24),--二级分类
  ORG_CLASS3     VARCHAR(48),--三级分类
  BASS1_CHL   VARCHAR(48),   --一经渠道名称，目前只区分实体渠道，电子渠道的大类
  OP_ID          BIGINT
);
/*INSERT INTO DIM_BASS1_CHANNEL_ORG_OP_INFO_YYYYMMDD
SELECT DISTINCT ORG_CLASS1,ORG_CLASS2,ORG_CLASS3,
 CASE WHEN ORG_CLASS3='自助终端' THEN '自助终端电子渠道'
      WHEN ORG_CLASS3='短信营业厅' THEN '短信'
      WHEN ORG_CLASS3='CBOSS' THEN '其他渠道'
      WHEN ORG_CLASS3='后台进程' THEN '其他渠道'
      WHEN ORG_CLASS3='网上商城后台接口' THEN '网站'
      WHEN ORG_CLASS3='客户端' THEN '网站'
      WHEN ORG_CLASS3='热线电话' THEN '热线'
      WHEN ORG_CLASS3='互联网分销' THEN '网站'
      WHEN ORG_CLASS3='10086自助' THEN '热线'
      WHEN ORG_CLASS3='WAP' THEN 'WAP'
      WHEN ORG_CLASS3='统一支付平台' THEN '网站'
      WHEN ORG_CLASS3='网上营业厅' THEN '网站'
      WHEN ORG_CLASS3='微信营业厅' THEN '网站'
      ELSE '其他渠道'
      END,
      OP_ID
  FROM SHFIN.RPT_DIM_CHANNEL_ORG_OP_INFO  WHERE IS_VALID=1;*/
--电子渠道
insert into Rpt_Dim_Channel_Org_Op_Info
                select distinct '电子渠道' as Kind_Name1,
                                '自营电子渠道' as Kind_Name2,
                                case
                                  when a.op_id = 999990001 or a.org_id = 402852 then
                                   '网上营业厅'
                                  when a.op_id = 999990002 then
                                   'WAP'
                                  when a.op_id in (999990021, 999990101) then
                                   '10086自助'
                                  when a.op_id = 999990024 and a.op_name = '网上商城后台接口' then
                                   '网上商城'
                                  when a.op_id = 999990076 and a.op_name = 'CBOSS' then
                                   'CBOSS'
                                  when a.op_id = 999990077 then
                                   '短信营业厅'
                                  when a.op_id = 999990091 then
                                   '客户端'
                                  when a.op_id = 999990099 and a.op_name = '统一支付平台' then
                                   '统一支付'
                                  when a.busi_chl_type_name = 'CCS' then
                                   '热线电话' -- 10086人工
                                  when a.op_id = 999990121 then
                                   '互联网外链' -- 划入网上营业厅
                                  when a.op_id = 999990122 then
                                   '支付宝' -- 划入网上营业厅
                                  when a.op_id = 999990133 then
                                   '微信营业厅' -- 划入网上营业厅
                                  when a.op_id = 9 and a.op_name = '后台进程' then
                                   null
                                end as Kind_Name3,
                                a.org_id as Crm_Org_Id,
                                a.op_id,
                                c.bass_org_type as Crm_Org_Type,
                                nvl(c.bass_org_type_name, c.boss_org_type_name) as Crm_Org_Type_Name,
                                a.busi_chl_type_name as Crm_Org_Kind,
                                nvl(c.org_name, a.org_name) as Crm_Org_Name,
                                a.op_name as Op_Name,
                                a.login_name as Login_Name,
                                b.node_id,
                                b.node_name,
                                nvl(b.node_kind || '', c.chl_kind) as Node_Kind,
                                nvl(b.node_type || '', c.chl_type) as Node_Type,
                                c.chl_mode,
                                b.node_level,
                                b.node_status,
                                b.operate_type,
                                b.node_entity_type,
                                b.district_id,
                                b.valid_date,
                                b.expire_date,
                                b.create_date as Node_Create_Date,
                                b.done_date as Node_Done_Date,
                                b.check_date,
                                b.channel_entity_serial,
                                b.self_status,
                                b.self_status_name,
                                b.node_addr,
                                b.business_start_date,
                                b.agent_id,
                                b.agent_short_name,
                                b.agent_name,
                                b.belong_org_id,
                                b.belong_org_name,
                                b.test_busi_flag,
                                b.org_id,
                                b.org_name,
                                b.agent_type,
                                b.agent_type_name,
                                b.agent_type_alias,
                                b.agent_level,
                                b.agent_level_name,
                                b.agent_status,
                                b.pay_type,
                                b.pay_type_name,
                                b.agent_valid_date,
                                b.agent_expire_date,
                                b.agent_create_date,
                                b.agent_done_date,
                                1 as Is_Valid,
                                '2015-03' as Create_Date,
                                '2015-03' as Modify_Date
                  from (select org_id,
                               org_name,
                               op_id,
                               op_name,
                               login_name,
                               busi_chl_type_name,
                               row_number() over(partition by op_id order by start_date desc, end_date desc) as Seq_No
                          from shdw.Dim_Prty_Oper_Info
                         where upper(nvl(login_name, '-1')) not like '%GSJK%'
                           and start_date < '2015-03-01') a
                  left join Temp_Node_Agent_Info2 b
                    on a.org_id = b.crm_org_id
                  left join (select org_id,
                                    org_name,
                                    bass_org_type,
                                    bass_org_type_name,
                                    boss_org_type,
                                    boss_org_type_name,
                                    chl_kind,
                                    chl_type,
                                    chl_mode,
                                    row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                               from shdw.Dim_Prty_Org_Info
                              where start_date < '2015-03-01') c
                    on a.org_id = c.org_id
                   and c.seq_no = 1
                 where a.seq_no = 1
                   and (a.op_id in (999990001,
                                    999990002,
                                    999990021,
                                    999990024,
                                    999990076,
                                    999990077,
                                    999990091,
                                    999990099,
                                    999990101,
                                    999990121,
                                    999990122,
                                    999990133) or a.busi_chl_type_name = 'CCS' or
                       a.org_id = 402852 or a.op_id = 9 and a.op_name = '后台进程');


 		
		

