﻿select distinct product_item_id,extend_id from SO1.UP_PRODUCT_ITEM where extend_id is not null;
---检查数据量 目标表10330 源表10330
select count(1)
  from SHDW.DWD_ACC_BOSS_PRD_REL_20131231;
select count(1) from
(
select distinct PRODUCT_ITEM_ID, EXTEND_ID
  from SHODS.ODS_CRM_UP_PRODUCT_ITEM_20131231  where item_type = 'SRVC_SINGLE' and extend_id is not null
)G;
---检查主要字段
select CRM_PROD_ID, EXTEND_ID
  from SHDW.DWD_ACC_BOSS_PRD_REL_20131231;
select distinct PRODUCT_ITEM_ID, EXTEND_ID
  from SHODS.ODS_CRM_UP_PRODUCT_ITEM_20131231  where item_type = 'SRVC_SINGLE' and extend_id is not null