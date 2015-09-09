create table client_subcribe_record
(
   id                   bigint(20) not null auto_increment,
   creater              bigint(20) comment '创建人',
   create_time          datetime comment '创建时间',
   modifier             bigint(20) comment '修改人',
   modify_time          datetime comment '修改时间',
   version              bigint(20) comment '版本号',
   follow_id            bigint(20) comment '主流程编号',
   groupbuy_id          bigint(20) comment '下定记录编号',
   groupbuy_line_id     bigint(20) comment '下定记录行编号',
   status               VARCHAR(50) comment '状态',
   broker_id            bigint(20) comment '经纪人编号',
   client_info_id       bigint(20) comment '客户经纪人编号',
   protocol_id          varchar(255) comment '认购协议编号',
   subcribe_amount      decimal(20,3) comment '认购金额',
   subcribe_protocol    bigint(20) comment '认购协议',
   build_no             varchar(20) comment '幢号',
   room_no              varchar(20) comment '楼号',
   project_type_id      bigint(20) comment '产品类型编号',
   idcard_no            VARCHAR(50) comment '身份证号',
   remark               varchar(500),
   primary key (id)
);

alter table client_subcribe_record comment '客户认购记录表';

 * from client_booked_record;
select pose_no,count(1) from client_refund_amount_record GROUP BY  pose_no having count(1)>1;
select pose_no from client_groupbuy_amount_record GROUP BY  pose_no having count(1)>1;
SELECT * from client_groupbuy_amount_record where pose_no=000623140922;
SELECT *from client_follow_up_record where id in (1014272015108,1014272015109);
SELECT * FROM client_groupbuy_record WHERE ID IN (1014272015108,1014272015109);
SELECT COUNT(1) FROM
(
select pose_no from client_groupbuy_amount_record GROUP BY  pose_no having count(1)>1
)G ;
SELECT * FROM  client_groupbuy_amount_record WHERE pose_no IN (
select pose_no from client_groupbuy_amount_record GROUP BY  pose_no having count(1)>1) ORDER BY create_time DESC;

select ifnull(a.invoice_amount,0),ifnull(a.invoice_amount,0)-ifnull(b.amount,0) from client_groupbuy_amount_record a join
(
select  pose_no,sum(amount) as amount from client_refund_amount_record  GROUP BY  pose_no
) b
  on  a.pose_no=b.pose_no;
select* from client_receipt_record;

insert into client_receipt_record select receipt_no,client_info_id,create_time from client_groupbuy_record where receipt_no is not null;


select * from client_receipt_record a join  client_groupbuy_record

drop index index_client_info_id on client_receipt_record;

select receipt_no,client_info_id,create_time from client_groupbuy_record where receipt_no is not null;
SELECT * from client_groupbuy_record where receipt_no is not null;
SELECT * from client_groupbuy_amount_record where receipt_no is not null;

 update client_groupbuy_record a set a.receipt_no = (
     select b.receipt_no from
   (select DISTINCT client_groupbuy_record_id,receipt_no from client_groupbuy_amount_record b limit 0,1) b
 where b.client_groupbuy_record_id=a.id
 );
select * from client_receipt_record;
select DISTINCT client_groupbuy_record_id,receipt_no from client_groupbuy_amount_record b where b.receipt_no is not null

select * from client_groupbuy_amount_record where receipt_no is not null;

update client_groupbuy_amount_record a set a.receipt_no = ifnull((
  select b.receipt_no from
    (select DISTINCT client_groupbuy_record_id,receipt_no from hossv2_new_test.client_groupbuy_amount_record b LIMIT 0,500) b
  where b.client_groupbuy_record_id=a.client_groupbuy_record_id
),a.receipt_no);
SELECT * from client_groupbuy_record where receipt_no=20150603000033;
SELECT * from client_groupbuy_record;
SELECT * from client_follow_up_record where id in(4977280,1002951002951);

SELECT crr.receipt_no as receiptNo,
  crr.rec_time as recTime,
  ci.clinet_name as clientName,
  ci.client_phone as clientPhone,
  sum(ifnull(cgr.receivable_amount, 0)) as couponAmount,
  sum(ifnull(cf.coupon_amount, 0)) as couponAmount,
  sum(ifnull(cgfr.reduce_amount, 0)) as reduceAmount,
  sum(ifnull((select SUM(invoice_amount)
          from client_groupbuy_amount_record cgar
          where cgar.client_groupbuy_record_id = cgr.id
          GROUP BY cgar.client_groupbuy_record_id),
         0)) as receivedAmount,
  ifnull(cgr.receivable_amount, 0) - ifnull(cf.coupon_amount, 0) -
  ifnull(cgfr.reduce_amount, 0) - ifnull((select SUM(invoice_amount)
                                       from client_groupbuy_amount_record cgar
                                       where cgar.client_groupbuy_record_id = cgr.id
                                       GROUP BY cgar.client_groupbuy_record_id),
                                      0) as arrearsAmount
from client_receipt_record crr
  join client_groupbuy_record cgr
    on crr.receipt_no = cgr.receipt_no
  join client_follow_up_record cfr
    on cgr.follow_id = cfr.id
       and cfr.basic_status = 'buy'
  join client_info ci
    on crr.client_info_id = ci.id
  left join (select groupbuy_id, sum(price) as coupon_amount
             from coupon_follow
             group by groupbuy_id) cf
    on cf.groupbuy_id = cgr.id
  left join (select a.client_groupbuy_id,
               sum(reduce_amount) as reduce_amount
             from cm_group_fee_reduce_apply a
               join wf_instance b
                 on a.wf_instance_id = b.id
                    and b.status = 2
             GROUP BY a.client_groupbuy_id) cgfr
    on cgfr.client_groupbuy_id = cgr.id
GROUP BY crr.receipt_no,
crr.rec_time,
ci.clinet_name,
ci.client_phone
order by crr.rec_time desc;

select cgr.follow_id as followId,cgr.id as groupBuyId,ci.client_id as client_id,ci.clinet_name as clientName,ci.client_phone as clientPhone, cgr.project_type_id as projectTypeId ,
       CONCAT(FORMAT( ifnull(pt.group_amount, 0)/ 10000, 2 ),'万享', pt.discount_info) AS projectTypeInfo,
       pt.name as name,pt.group_amount as groupAmount, pt.discount_info as discountInfo
from client_groupbuy_record cgr
  left join project_type pt
    on cgr.project_type_id = pt.id
  left join client_info ci on cgr.client_info_id=ci.id where cgr.receipt_no = 20150603000033;
select * from client_receipt_record;
SELECT *
FROM client_linkman where client_info_id=1002949002949;


select cgr.follow_id as followId,cgr.id as groupBuyId,ci.client_id as clientId,ci.clinet_name as clientName,ci.client_phone as clientPhone, cgr.project_type_id as projectTypeId ,
       CONCAT(FORMAT( ifnull(pt.group_amount, 0)/ 10000, 2 ),'万享', ifnull(pt.discount_info,'')) AS projectTypeInfo,
       pt.name as name,pt.group_amount as groupAmount, ifnull(pt.discount_info,'') as discountInfo,
       link.status as linkStatusfrom from client_groupbuy_record cgr
left join project_type pt
on cgr.project_type_id = pt.id
left join client_info ci on cgr.client_info_id=ci.id left join client_linkman link on link.client_info_id = cgr.client_info_id where cgr.receipt_no = 20150603000033;


 SELECT *
 FROM  client_groupbuy_record where receipt_no=20150603000033;
 SELECT * from client_receipt_record where receipt_no=20150603000033;
 select * from client_follow_up_record where id in (4977280,1002951002951);
 SELECT * from project_type;
 select
   cfr.id as followId,
   cgr.id as groupBuyId,
   pt.id as projectTypeId,
   CONCAT(pt.name,
          '(',
          FORMAT(ifnull(pt.group_amount, 0) / 10000, 2),
          '万享',
          ifnull(pt.discount_info, ''),
          ')') AS projectTypeInfo
 from client_follow_up_record cfr
   join client_groupbuy_record cgr
     on cfr.id = cgr.follow_id
        and cfr.basic_status = 'buy'
   join project_type pt
     on cgr.project_type_id = pt.id;
 SELECT *
 FROM client_booked_record;
 SELECT * from client_follow_up_record ;
 select * from client_linkman where client_info_id='1002949002949';
 SELECT * from document WHERE object_id in (12094952,12099194) order by modify_time desc;
 SELECT object_id from document GROUP BY object_id having count(1)>1;
 SELECT * from client_follow_up_record where id=1002951002951;
 SELECT * from client_linkman where client_info_id=1002949002949;
 #新增下定客户
 SELECT sum(newGroupBuyCounts) as newGroupBuyCounts,
        sum(newBookedCounts) as newBookedCounts,
        sum(overBookedCounts) as overBookedCounts
 from (SELECT count(cgr.id) as newGroupBuyCounts,
              0 as newBookedCounts,
              0 as overBookedCounts
       FROM client_groupbuy_record cgr
         JOIN client_follow_up_record cfr
           ON cgr.follow_id = cfr.id
              AND cgr.create_time >= '2015-08-17:00:00:00'
              AND cgr.create_time <= '2015-08-23:23:59:59'
              AND cfr.basic_status IN ('buy', 'booked', 'deal', 'brokerage')
         join project_type pt
           on cgr.project_type_id = pt.id
              and pt.project_id = 4626623
       union all
       select 0 as newGroupBuyCounts,
              count(cbr.id) as newBookedCounts,
              0 as overBookedCounts
       from client_booked_record cbr
         JOIN client_follow_up_record cfr
           on cbr.follow_id = cfr.id
              and cbr.create_time >= '2015-08-17'
              and cbr.create_time <= '2015-08-23'
              and cfr.basic_status IN ('buy', 'booked', 'deal', 'brokerage')
         join project_type pt
           on cbr.project_type_id = pt.id
              and pt.project_id = 4626623
       UNION ALL
       SELECT 0 as newGroupBuyCounts,
              0 as newBookedCounts,
              count(cgr.id) as overBookedCounts
       FROM client_groupbuy_record cgr
         JOIN client_follow_up_record cfr
           ON cgr.follow_id = cfr.id
              AND cgr.create_time >= '2015-08-17'
              AND cgr.create_time <= '2015-08-23'
              AND cfr.basic_status IN ('buy')
         join project_type pt
           on cgr.project_type_id = pt.id
              and pt.project_id = 4626623
         left join project_setting ps
           on pt.project_id=ps.project_id
       where  date_add(cgr.create_time, INTERVAL ifnull(ps.book_remind_days,30) day) <now()
      )g;



 SELECT cgr.*
 FROM client_groupbuy_record cgr
   JOIN client_follow_up_record cfr
     ON cgr.follow_id = cfr.id
        AND cgr.create_time >= '2015-08-17'
        AND cgr.create_time <= '2015-08-23'
        AND cfr.basic_status IN ('buy', 'booked', 'deal', 'brokerage')
   join project_type pt
     on cgr.project_type_id = pt.id
        and pt.project_id = 4626623
   left join project_setting ps
     on pt.project_id=ps.project_id;
 SELECT * from project_setting where id=2;
 update project_setting set project_id=4626623 where id=2;
 SELECT * from client_groupbuy_record a where a.create_time>='2015-08-17' and a.create_time<='2015-08-23';
 SELECT * from client_follow_up_record where id=4977280;
 SELECT DISTINCT basic_status from client_follow_up_record;
 SELECT * from client_groupbuy_record where follow_id in (4977280,1002951002951);
 SELECT * from project_type where project_id=4626623;
 SELECT * from project where title like '%大龙%';

 SELECT * from client_booked_record ;


  SELECT * FROM client_follow_up_record WHERE id = 1006150006151;
  select * from client_groupbuy_record where invoice_no
  select * from client_receipt_record ;
  insert into client_receipt_record(receipt_no, client_info_id, rec_time,project_id)
  select distinct cgr.invoice_no,'1111','2014-07-22 15:09:28','2222'
                                    from client_groupbuy_record cgr join project_type pt on cgr.project_type_id=pt.id
                                      left join client_receipt_record crr on cgr.invoice_no=crr.receipt_no
   where  crr.receipt_no is null;



SELECT * from project_type where id  in (40518478
,40518478
,40518478
,40518479
,19628609
,2833832
,38266229);
 SELECT * from client_groupbuy_record where invoice_no in (20150401000001,20150401000002,20150401000003,20150401000004,20150407000001,20150407000002
   ,20150408000001) ;
 SELECT * from client_receipt_record where receipt_no in (20150401000001,20150401000002,20150401000003,20150401000004,20150407000001,20150407000002
 ,20150408000001) ;

 SELECT client_info_id from client_groupbuy_record where invoice_no=20150401000004;
 SELECT * from client_receipt_record where receipt_no=20150401000004;
 SELECT *
 FROM client_follow_up_record
 WHERE id IN (5003237
 ,5007479
 ,5007480
 ,5007481);

 SELECT crr.receipt_no as receiptNo,
   crr.rec_time as recTime,
   ci.clinet_name as clientName,
   ci.client_phone as clientPhone,
   sum(ifnull(cgr.receivable_amount, 0)) as receivableAmount,
   sum(ifnull(cf.coupon_amount, 0)) as couponAmount,
   sum(ifnull(cgfr.reduce_amount, 0)) as reduceAmount,
   sum(ifnull((select SUM(invoice_amount)
               from client_groupbuy_amount_record cgar
               where cgar.client_groupbuy_record_id = cgr.id
               GROUP BY cgar.client_groupbuy_record_id),
              0)) as receivedAmount,
   ifnull(cgr.receivable_amount, 0) - ifnull(cf.coupon_amount, 0) -
   ifnull(cgfr.reduce_amount, 0) - ifnull((select SUM(invoice_amount)
                                           from client_groupbuy_amount_record cgar
                                           where cgar.client_groupbuy_record_id = cgr.id
                                           GROUP BY cgar.client_groupbuy_record_id),
                                          0) as arrearsAmount
 from client_receipt_record crr
   join client_groupbuy_record cgr
     on crr.receipt_no = cgr.invoice_no
   join client_follow_up_record cfr
     on cgr.follow_id = cfr.id
   join client_info ci
     on crr.client_info_id = ci.id
   join project_type pt on cgr.project_type_id=pt.id  left join (select groupbuy_id, sum(price) as coupon_amount
                                                                 from coupon_follow
                                                                 group by groupbuy_id) cf
     on cf.groupbuy_id = cgr.id
   left join (select a.client_groupbuy_id,
                sum(reduce_amount) as reduce_amount
              from cm_group_fee_reduce_apply a
                join wf_instance b
                  on a.wf_instance_id = b.id
                     and b.status = 2
              GROUP BY a.client_groupbuy_id) cgfr
     on cgfr.client_groupbuy_id = cgr.id
 where cfr.basic_status='buy' and pt.project_id = 4626623 and  1=1  and  1=1  GROUP BY crr.receipt_no,
   crr.rec_time,
   ci.clinet_name,
   ci.client_phone
 order by crr.rec_time desc limit 0,10;

 SELECT * from client_receipt_record crr
   join client_groupbuy_record cgr
     on crr.receipt_no = cgr.invoice_no
   join client_follow_up_record cfr
     on cgr.follow_id = cfr.id
   join client_info ci
     on crr.client_info_id = ci.id
   join project_type pt on cgr.project_type_id=pt.id ;

 SELECT * from project_type where project_id=4626623;
 select * from client_groupbuy_record where follow_id in (5003237
 ,5007479
 ,5007480
 ,5007481);



 select cgr.follow_id as followId,cgr.id as groupBuyId,ci.client_id as clientId, ci.clinet_name as clientName,ci.client_phone as clientPhone,cgr.broker_id as brokerId,cgr.client_info_id as clientInfoId, cgr.project_type_id as projectTypeId , CONCAT(pt.name,FORMAT( ifnull(pt.group_amount, 0)/ 10000, 2 ),'万享', ifnull(pt.discount_info,'')) AS projectTypeInfo, pt.name as name,pt.group_amount as groupAmount, ifnull(pt.discount_info,'') as discountInfo,  link.status as linkStatus from client_groupbuy_record cgr join client_follow_up_record cfr on cgr.follow_id=cfr.id   left join project_type pt     on cgr.project_type_id = pt.id  left join client_info ci on cgr.client_info_id=ci.id left join client_linkman link on link.client_info_id = cgr.client_info_id where cgr.receipt_no = 20150401000001 and cfr.basic_status='buy'
