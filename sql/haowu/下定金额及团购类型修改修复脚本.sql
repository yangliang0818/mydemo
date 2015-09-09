#将客户王超 18662243066 下定金额和实收金额15000改为10500 client_info_id 40527584535 follow_id 40527584636
#更新语句
update client_groupbuy_record set receivable_amount=10500,received_amount=10500,pose_type=2 where id=40527509623 and receivable_amount=15000 and received_amount=15000 and pose_type=1;
#回滚语句
update client_groupbuy_record set receivable_amount=15000,received_amount=15000,pose_type=1 where id=40527509623 and receivable_amount=10500 and received_amount=10500 and pose_type=2;
#更新语句
update client_groupbuy_amount_record set invoice_amount=10500 where id=40528097091 and invoice_amount=15000;
#回滚语句
update client_groupbuy_amount_record set invoice_amount=15000 where id=40528097091 and invoice_amount=10500;

#将客户徐瑞强 13915410919 下定金额和实收金额15000改为7500 client_info_id 1012637013658 follow_id 1012638013664
#更新语句
update client_groupbuy_record set receivable_amount=7500,received_amount=7500,pose_type=2 where id=1012644013913 and receivable_amount=15000 and received_amount=15000 and pose_type=0;
#回滚语句
update client_groupbuy_record set receivable_amount=15000,received_amount=15000,pose_type=0 where id=1012644013913 and receivable_amount=7500 and received_amount=7500 and pose_type=2;
#更新语句
update client_groupbuy_amount_record set invoice_amount=7500 where id=1012645013955 and invoice_amount=15000;
#回滚语句
update client_groupbuy_amount_record set invoice_amount=15000 where id=1012645013955 and invoice_amount=7500;

#将客户蔡佳 13962511606 下定金额和实收金额15000改为0元 client_info_id 40419415555 follow_id 40419141954
update client_groupbuy_record set receivable_amount=0,received_amount=0,pose_type=2 where id=40419747237 and receivable_amount=15000 and received_amount=15000 and pose_type=1;
#回滚语句
update client_groupbuy_record set receivable_amount=15000,received_amount=15000,pose_type=1 where id=40419747237 and receivable_amount=0 and received_amount=0 and pose_type=2;
#更新语句
update client_groupbuy_amount_record set invoice_amount=0 where id=40420408777 and invoice_amount=15000;
#回滚语句
update client_groupbuy_amount_record set invoice_amount=15000 where id=40420408777 and invoice_amount=0;

#将客户李青花 13799293665 下定金额由3000改为20000元 购房类型由0.3万享团购优惠改为2万享团购优惠 client_info_id 400000740000729 follow_id 400000741000826
#更新语句
update client_groupbuy_record set receivable_amount=20000,received_amount=20000,pose_type=2 and project_type_id=1230902703 where id=40421452969 and receivable_amount=3000 and received_amount=3000 and pose_type=1 and project_type_id=1101100021538517;
#回滚语句
update client_groupbuy_record set receivable_amount=3000,received_amount=3000,pose_type=1 and project_type_id=1101100021538517 where id=40421452969 and receivable_amount=20000 and received_amount=20000 and pose_type=2 and project_type_id=1230902703;

#将客户陈丽凰 13950013014 下定金额由3000改为20000元 购房类型由0.3万享团购优惠改为2万享团购优惠 client_info_id 1192357192972 follow_id 1192358193144
#更新语句
update client_groupbuy_record set receivable_amount=20000,received_amount=20000,pose_type=2 and project_type_id=1230902703 where id=111100002105617 and receivable_amount=10000 and received_amount=3000 and pose_type=1 and project_type_id=1230902704;
#回滚语句
update client_groupbuy_record set receivable_amount=10000,received_amount=3000,pose_type=1 and project_type_id=1230902704 where id=111100002105617 and receivable_amount=20000 and received_amount=20000 and pose_type=2 and project_type_id=1230902703;

#将客户方初泗 13859906575 下定金额由10000改为20000元 购房类型由1万享团购优惠改为2万享团购优惠 client_info_id 400000740000946 follow_id 400000741001093
#更新语句
update client_groupbuy_record set receivable_amount=20000,received_amount=20000,pose_type=2 and project_type_id=1230902703 where id=40439633491 and receivable_amount=10000 and received_amount=10000 and pose_type=1 and project_type_id=1230902704;
#回滚语句
update client_groupbuy_record set receivable_amount=10000,received_amount=3000,pose_type=1 and project_type_id=1230902704 where id=40439633491 and receivable_amount=20000 and received_amount=20000 and pose_type=2 and project_type_id=1230902703;

#将客户庄秀梅 15860712325 下定金额由10000改为20000元 购房类型由1万享团购优惠改为2万享团购优惠 client_info_id 400000981001329 follow_id 400000982001444
#更新语句
update client_groupbuy_record set receivable_amount=20000,received_amount=20000,pose_type=2 and project_type_id=1230902703 where id=40461971954 and receivable_amount=10000 and received_amount=10000 and pose_type=1 and project_type_id=1230902704;
#回滚语句
update client_groupbuy_record set receivable_amount=10000,received_amount=3000,pose_type=1 and project_type_id=1230902704 where id=40461971954 and receivable_amount=20000 and received_amount=20000 and pose_type=2 and project_type_id=1230902703;

#将客户高晓玲 18683571688 下定金额由30000改为20000元 购房类型由3万享10万改为2万享8万 client_info_id 40446016444 follow_id 400000982001444
#更新语句
update client_groupbuy_record set receivable_amount=20000,received_amount=20000,pose_type=2 and project_type_id=400587142997 where id=40446519927 and receivable_amount=30000 and received_amount=30000 and pose_type=1 and project_type_id=400587142998;
#回滚语句
update client_groupbuy_record set receivable_amount=30000,received_amount=30000,pose_type=1 and project_type_id=400587142998 where id=40446519927 and receivable_amount=20000 and received_amount=20000 and pose_type=2 and project_type_id=400587142997;

