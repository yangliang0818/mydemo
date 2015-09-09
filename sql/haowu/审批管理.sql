SELECT * from data_dictionary_channel;
select * from client_info;
select * from client_follow_up_record where source_way='otherOffChannel';
SELECT * from document;
SELECT  * from client_refund_record;
SELECT * from client_groupbuy_amount_record where receipt_no is not null;
select * from client_groupbuy_amount_record_change_log where follow_id=1190001254;

select * from project_type where project_id = 1101102140078943;
select * from client_groupbuy_record where follow_id = 111100202542507;
select * from client_groupbuy_amount_record where follow_id = 111100202542507;
SELECT DISTINCT brokerage_type from project_type ;


select * from business_node_record where follow_id=111100202542507 order by create_time desc ;

SELECT DISTINCT  status  from project_type ;

select * from act_re_procdef;
SELECT * from wf_task











