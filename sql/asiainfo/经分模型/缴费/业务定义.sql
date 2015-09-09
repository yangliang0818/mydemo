--检查数据量
select count(1) from  shdw.DIM_BUSI_SPEC_DEF
except
select count(1) from SHODS.ODS_BI_BUSI_SPEC_DEF_20131231;
--检查主要字段差异
select SPEC_ID,BUSI_NAME,BUSI_TYPE from  shdw.DIM_BUSI_SPEC_DEF
except
select BUSI_SPEC_ID,NAME,BUSI_TYPE from SHODS.ODS_BI_BUSI_SPEC_DEF_20131231;
