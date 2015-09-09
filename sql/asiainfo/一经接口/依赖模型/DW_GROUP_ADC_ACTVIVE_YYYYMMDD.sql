--遇到有模型不支撑操作流程
--第一步、拉出程序输入表 dw_GrAdcD.sqC 全部依赖的表都支撑
db2info.dim_product  -->  shdw.dim_acc_item_code
db2info.DW_GROUP_PRODUCT_INST_yyyymmdd  -->shdw.DWD_SVC_GRP_OFF_INS_YYYYMMDD
db2info.dwd_instance_attr_yyyymmdd  -->shdw.DWD_SVC_GRP_SRV_ATTR_YYYYMMDD
db2info.DW_GROUP_PRODUCT_DTL_INST_yyyymmdd --> shdw.DWD_SVC_GRP_MEM_PROD_YYYYMMDD
db2info.ods_adc2boss_amount_yyyymmdd  -->shods.ods_adc2boss_amount_yyyymmdd
db2info.ods_adc2boss_active_yyyymmdd  -->shods.ods_adc2boss_active_yyyymmdd

--第二步、想好老模型表对应的新模型表命名,命名规则参考基础模型各域命名规则 DW_GROUP_ADC_ACTVIVE_yyyymmdd 新模型命名为BASS1_GRP_ADC_ACTVIVE_YYYYMMDD

--第三步、根据模型支撑情况将用支撑的SQL语句编写出来，参考dw_GrAdcD.sqC将逻辑来编写，可视一经的需求适当删减

--第四步、调试好编写的SQL语句，放到一经前置程序开发批次安排开发人员在开发管理平台开发






