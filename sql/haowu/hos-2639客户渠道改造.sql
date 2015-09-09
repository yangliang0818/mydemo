--新增渠道来源配置表
drop table if exists hossv2_new_dev.data_dictionary_channel;

/*==============================================================*/
/* Table: data_dictionary_channel                               */
/*==============================================================*/
create table hossv2_new_dev.data_dictionary_channel
(
   id                   bigint(20) not null default 0 comment '编号',
   creater              bigint(20) comment '创建人',
   create_time          datetime not null comment '创建时间',
   modifier             bigint(20) comment '修改人',
   modify_time          datetime comment '修改时间',
   version              bigint(20) not null comment '版本',
   channel_code         national varchar(50) comment '渠道编码',
   channel_name         national varchar(100) comment '渠道名称',
   plat_code            national varchar(50) comment '平台编码',
   plat_name            varchar(100) comment '平台名称',
   plat_source_code     varchar(50) comment '平台来源编码',
   plat_source_name     varchar(100) comment '平台来源名称',
   is_valid             smallint(6) comment '是否有效 1 有效 0 无效',
   primary key (id),
   key uc_data_dictionary_group_code (channel_code)
);

alter table hossv2_new_dev.data_dictionary_channel comment '渠道数据字段配置信息';

INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (1, -1, '2015-07-16 15:42:46', -1, '2015-07-16 15:42:54', 0, 'socialBroker', '社会经纪人', 'robguestapp', '抢钱宝APP', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (2, -1, '2015-07-16 15:45:18', -1, '2015-07-16 15:45:22', 0, 'socialBroker', '社会经纪人', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (3, -1, '2015-07-16 15:47:15', -1, '2015-07-16 15:47:19', 0, 'socialBroker', '社会经纪人', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (4, -1, '2015-07-16 15:48:11', -1, '2015-07-16 15:48:16', 0, 'socialBroker', '社会经纪人', 'official', '官网', 'official_thirdHouseChannel', '第三方房源频道', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (5, -1, '2015-07-16 15:49:18', -1, '2015-07-16 15:49:44', 0, 'oldtonew', '老带新', 'robguestapp', '抢钱宝APP', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (6, -1, '2015-07-16 15:51:13', -1, '2015-07-16 15:51:18', 0, 'oldtonew', '老带新', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (7, -1, '2015-07-16 15:51:56', -1, '2015-07-16 15:52:02', 0, 'oldtonew', '老带新', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (8, -1, '2015-07-16 15:53:15', -1, '2015-07-16 15:53:19', 0, 'oldtonew', '老带新', 'official', '官网', 'official_thirdHouseChannel', '第三方房源频道', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (9, -1, '2015-07-16 15:54:09', -1, '2015-07-16 15:54:16', 0, 'aloneBroker', '直客经纪人', 'conduitapp', '合伙人APP', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (10, -1, '2015-07-16 15:55:20', -1, '2015-07-16 15:55:24', 0, 'aloneBroker', '直客经纪人', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (11, -1, '2015-07-16 15:55:57', -1, '2015-07-16 15:56:01', 0, 'aloneBroker', '直客经纪人', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (12, -1, '2015-07-16 15:57:39', -1, '2015-07-16 15:57:44', 0, 'aloneBroker', '直客经纪人', 'official', '官网', 'official_thirdHouseChannel', '第三方房源频道', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (13, -1, '2015-07-16 15:58:32', -1, '2015-07-16 15:58:36', 0, 'conduit', '合伙人', 'conduitapp', '合伙人APP', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (14, -1, '2015-07-16 15:59:46', -1, '2015-07-16 15:59:51', 0, 'conduit', '合伙人', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (15, -1, '2015-07-16 16:00:33', -1, '2015-07-16 16:00:37', 0, 'conduit', '合伙人', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (16, -1, '2015-07-16 16:04:23', -1, '2015-07-16 16:04:27', 0, 'clientDeal', 'C端购房者', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (17, -1, '2015-07-16 16:05:28', -1, '2015-07-16 16:05:32', 0, 'clientDeal', 'C端购房者', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (18, -1, '2015-07-16 16:05:28', -1, '2015-07-16 16:07:00', 0, 'clientDeal', 'C端购房者', 'official', '官网', 'official_thirdHouseChannel', '第三方房源频道', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (19, -1, '2015-07-16 16:07:32', -1, '2015-07-16 16:07:36', 0, 'other', '其他线下渠道', 'other_outItinerantList', '外包巡展派单', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (20, -1, '2015-07-16 16:09:33', -1, '2015-07-16 16:09:37', 0, 'other', '其他线下渠道', 'other_outCall', '外包Call客', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (21, -1, '2015-07-16 16:10:02', -1, '2015-07-16 16:10:06', 0, 'other', '其他线下渠道', 'other_channel', '其他渠道', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (22, -1, '2015-07-16 16:10:50', -1, '2015-07-16 16:10:55', 0, 'socialShare', '社会分享', null, null, null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (23, -1, '2015-07-16 17:42:05', -1, '2015-07-16 17:42:08', 0, 'nature', '自然来人', 'baidu', '百度', 'ppc', '搜索', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (24, -1, '2015-07-16 17:43:17', -1, '2015-07-16 17:43:21', 0, 'nature', '自然来人', 'baidu', '百度', 'cpm', '网盟', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (25, -1, '2015-07-16 17:44:03', -1, '2015-07-16 17:44:08', 0, 'nature', '自然来人', 'sougou', '搜狗', 'ppc', '搜索', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (26, -1, '2015-07-16 17:45:01', -1, '2015-07-16 17:45:06', 0, 'nature', '自然来人', 'sougou', '搜狗', 'cpm', '网盟', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (27, -1, '2015-07-16 17:45:50', -1, '2015-07-16 17:45:54', 0, 'nature', '自然来人', '360', '360', 'ppc', '搜索', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (28, -1, '2015-07-16 17:46:44', -1, '2015-07-16 17:46:48', 0, 'nature', '自然来人', '360', '360', 'cpm', '网盟', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (29, -1, '2015-07-16 17:47:14', -1, '2015-07-16 17:47:19', 0, 'nature', '自然来人', 'google', '谷歌', 'ppc', '搜索', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (30, -1, '2015-07-16 17:48:06', -1, '2015-07-16 17:48:10', 0, 'nature', '自然来人', 'google', '谷歌', 'cpm', '网盟', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (31, -1, '2015-07-16 17:48:45', -1, '2015-07-16 17:48:49', 0, 'nature', '自然来人', 'juxiao', '聚效', 'dsp', 'dsp', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (32, -1, '2015-07-16 17:49:37', -1, '2015-07-16 17:49:41', 0, 'nature', '自然来人', 'tengxun', '腾讯', 'guangdiantong', '广点通', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (33, -1, '2015-07-16 17:50:28', -1, '2015-07-16 17:50:32', 0, 'nature', '自然来人', 'xinlang', '新浪', 'fengsitong', '粉丝通', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (34, -1, '2015-07-16 17:51:22', -1, '2015-07-16 17:51:26', 0, 'nature', '自然来人', 'ad7', 'ad7', 'dsp', 'dsp', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (35, -1, '2015-07-16 17:52:05', -1, '2015-07-16 17:52:11', 0, 'nature', '自然来人', '400', '400电话', null, null, 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (36, -1, '2015-07-16 17:53:07', -1, '2015-07-16 17:53:13', 0, 'nature', '自然来人', 'official', '官网', 'official_officialApp', '官网APP', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (37, -1, '2015-07-16 17:54:12', -1, '2015-07-16 17:54:15', 0, 'nature', '自然来人', 'official', '官网', 'official_officialWeb', '官网网站', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (38, -1, '2015-07-16 17:54:52', -1, '2015-07-16 17:54:55', 0, 'nature', '自然来人', 'official', '官网', 'official_thirdHouseChannel', '第三方房源频道', 1);
INSERT INTO hossv2_new_dev.data_dictionary_channel (id, creater, create_time, modifier, modify_time, version, channel_code, channel_name, plat_code, plat_name, plat_source_code, plat_source_name, is_valid) VALUES (39, -1, '2015-07-16 17:55:37', -1, '2015-07-16 17:55:43', 0, 'nature', '自然来人', 'other', '其他', null, null, 1);


--增量更新语句
update hossv2_new_dev.data_dictionary_channel set plan_code='other_outItinerantList' where id=19;
update hossv2_new_dev.data_dictionary_channel set plan_code='other_channel' where id=21;
update hossv2_new_dev.data_dictionary_channel set plan_name='其他' where id=39;

--修改主流程表client_follow_up_record中的老带新类型的社会渠道改为老带新渠道
--更新渠道来源
update client_follow_up_record set source_way='oldtonew' where source_way='socialBroker' and client_info_id in (1078186078434,1192298193274,1192358193301,1192639193399,400000741000409);
--回退脚本
update client_follow_up_record set source_way='socialBroker' where source_way='oldtonew' and id in (400066726,400066755,400066760,400066763,400066779);

--client_follwo_up_record表source_way字段目前有这些值 aloneBroker(直客经纪人) conduit(合伙人) socialBroker(社会经纪人) nature(自然来人) socialShare(社会分享)
--client_info表source_way目前有这些值 conduit broker_to_client childClient aloneBroker conduitShare aloneBrokerShare nature robed rental socialBroker social_broker_share socialShare weixin

update data_dictionary_channel set plat_name='全媒体-百度' where id=23;
update data_dictionary_channel set plat_name='全媒体-百度' where id=24;
update data_dictionary_channel set plat_name='全媒体-搜狗' where id=25;
update data_dictionary_channel set plat_name='全媒体-搜狗' where id=26;
update data_dictionary_channel set plat_name='全媒体-360' where id=27;
update data_dictionary_channel set plat_name='全媒体-360' where id=28;
update data_dictionary_channel set plat_name='全媒体-谷歌' where id=29;
update data_dictionary_channel set plat_name='全媒体-谷歌' where id=30;
update data_dictionary_channel set plat_name='全媒体-聚效' where id=31;
update data_dictionary_channel set plat_name='全媒体-腾讯' where id=32;
update data_dictionary_channel set plat_name='全媒体-新浪' where id=33;
update data_dictionary_channel set plat_name='全媒体-ad7' where id=34;
update data_dictionary_channel set plat_name='全媒体-400电话' where id=35;
