--场景1：一个用户订购了来电提醒业务，希望知道是怎么算费的?
--1.查找用户的产品当前有效的产品信息
select b.name, a.*
  from cd.co_prod_41 a
  join pd.pm_product_offering b on a.product_offering_id =
                                   b.product_offering_id
                               and object_id = '1120128152'
                               and a.expire_date > sysdate;
--2.查询产品的定价计划
select * from pd.PM_PRODUCT_PRICING_PLAN where product_offering_id='31000169';
--3.找到来电提醒的定价计划编码为60006308
select * from pd.PM_PRICING_PLAN where pricing_plan_name  like '%来电提醒%' ;
--4.根据定价计划查询用户的定价 比如为70004833
select * from pd.pm_composite_offer_price where pricing_plan_id='45024048';
--5.查询价格信息 定位为固费 PRICE_TYPE 为7  8为账务优惠   0 为基本资费
select * from pd.PM_COMPONENT_PRODOFFER_PRICE where price_id='80006541';
--6.1查询固费信息[固定费用资费包明细]
select * from pd.PM_RECURRING_FEE_DTL where price_id='80006541';
--6.2查询账务优惠费 [PM_BILLING_DISCOUNT_DTL账务优惠表]
select * from pd.PM_BILLING_DISCOUNT_DTL where price_id='80003324';

--7.查询费率找出费率曲线编号为1269300
select * from pd.pm_rates where rate_id='1269300';
--8.费率曲线ID，关联固定费用的费率明细 得出来电提醒基础费是3块，按天收取是每天1毛钱
select * from pd.PM_CURVE_SEGMENTS where curve_id='1269300';







