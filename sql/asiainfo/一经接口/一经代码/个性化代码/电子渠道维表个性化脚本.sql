--电子渠道第一次个性化处理脚本
delete from DIM_BASS1_CHANNEL_OP_INFO_20150414;
insert into DIM_BASS1_CHANNEL_OP_INFO_20150414(ORG_CLASS1,ORG_CLASS2,ORG_CLASS3,BASS1_CHL,BASS1_CHLNAME,OP_ID)
select distinct ORG_CLASS1, ORG_CLASS2, ORG_CLASS3,
   CASE WHEN ORG_CLASS3='自助终端' THEN 'BASS1_ST'
      WHEN ORG_CLASS3='短信营业厅' THEN 'BASS1_SM'
      WHEN ORG_CLASS3='CBOSS' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='后台进程' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='网上商城后台接口' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='客户端' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='热线电话' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='互联网分销' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='10086自助' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='WAP' THEN 'WAP'
      WHEN ORG_CLASS3='统一支付平台' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='网上营业厅' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='微信营业厅' THEN 'BASS1_WB'
      ELSE 'BASS1_UM'
      END AS BASS1_CHL,
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
            END AS BASS1_CHLNAME
      , OP_ID
  from SHFIN.RPT_DIM_CHANNEL_ORG_OP_INFO where ORG_CLASS1='电子渠道' and op_id is not null;

delete from DIM_BASS1_CHANNEL_OP_INFO_20150414 where op_id=722526 and org_class3='网上营业厅';

insert into DIM_BASS1_CHANNEL_OP_INFO_20150414(ORG_CLASS1,ORG_CLASS2,ORG_CLASS3,BASS1_CHL,BASS1_CHLNAME,ORG_ID)
select distinct ORG_CLASS1, ORG_CLASS2, ORG_CLASS3,
  CASE WHEN ORG_CLASS3='自助终端' THEN 'BASS1_ST'
      WHEN ORG_CLASS3='短信营业厅' THEN 'BASS1_SM'
      WHEN ORG_CLASS3='CBOSS' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='后台进程' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='网上商城后台接口' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='客户端' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='热线电话' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='互联网分销' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='10086自助' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='WAP' THEN 'WAP'
      WHEN ORG_CLASS3='统一支付平台' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='网上营业厅' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='微信营业厅' THEN 'BASS1_WB'
      ELSE 'BASS1_UM'
      END AS BASS1_CHL,
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
            END AS BASS1_CHLNAME,
      CRM_ORG_ID
  from SHFIN.RPT_DIM_CHANNEL_ORG_OP_INFO where ORG_CLASS1='电子渠道' and op_id is null and crm_org_id is not null;