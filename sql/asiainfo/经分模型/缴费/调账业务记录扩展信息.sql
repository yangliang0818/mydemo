﻿--检查数据量
select count(1)
  from SHDW.DWD_ACC_ADJUST_EXT_201311
except
select count(1)
  from SHODS.ODS_CA_ADJUST_EXT_201311
--检查关键字段
select SO_NBR,BILL_NO,ITEM_CODE,BILL_FEE,UNPAY_FEE,ADJUST_FEE from shdw.DWD_ACC_ADJUST_EXT_201311
except
select "SO_NBR", "BILL_NO", "ITEM_CODE", "TOTAL_FEE", "UNPAY_FEE", "ADJUST_FEE" from "SHODS"."ODS_CA_ADJUST_EXT_201311";

