select * from wf_instance where id=1101102118919826;
SELECT * from wf_task where wf_instance_id=1101102118919826;
SELECT *
FROM liq_commission_settlement_standards where wf_instance_id=1101102118919826;
select * from liq_personal_rules where id=1101102168581433;
SELECT * from liq_personal_rules_details where personal_rules_id=1101102168581433;
SELECT flow_no from flow_no_generator group by flow_no having count(1)>1;
SELECT * from liq_personal_rules_details order by create_time desc;
SELECT * from ACT_RE_PROCDEF WHERE iD_='JSBZ:1:132104';
SELECT * from ACT_RU_EXECUTION where PROC_INST_ID_=190754;
select * from ACT_RU_TASK where PROC_INST_ID_=190754;
select * from liq_channel_commission_settlement_person where wf_instance_id=1101102118919826;
SELECT * from liq_channel_commission_settlement where wf_instance_id=1101102118919826;
SELECT * from liq_channel_commission_settlement_details ;
select * from cm_project_repay;
SELECT * from project_type where id=1101100350252904;

SELECT lpr.fixed_amount
FROM liq_personal_rules_details lpr JOIN project_type pt ON lpr.project_type_id = pt.id
WHERE lpr.channel_type = 'pd'
ORDER BY lpr.create_time DESC
LIMIT 0, 1;
SELECT
  cfur.id,
  broker_id,
  client_id
FROM client_follow_up_record cfur INNER JOIN broker b ON cfur.broker_id = b.id
WHERE cfur.project_id = 19624605 AND b.type = '0' AND cfur.parent_id=20038020058;

select basic_status,id,broker_id,client_id from client_follow_up_record where id=20038020058;
SELECT  * from business_node_record where follow_id=20038020058;
SELECT * from client_follow_up_record where parent_id=20038020058;

SELECT b.id AS id,b.name AS NAME,COUNT(cdr.id) AS dealNum
FROM broker b
  left join client_follow_up_record cfur on cfur.broker_id = b.id
  LEFT JOIN client_deal_record cdr ON b.id = cdr.broker_id
  LEFT JOIN partner_store_broker psb ON psb.broker_id = b.id
  LEFT JOIN partner_store ps ON ps.id = psb.obj_id
  left join partner_organization po on po.id = ps.org_id
WHERE ps.disabled = 0 AND psb.type = '2'
GROUP BY b.id
ORDER BY dealNum DESC;
select * from dc_order;
SELECT
  o.city_id AS cityId,
  SUM(refund_amount) AS refundAmount
FROM dc_order o
  JOIN project p
    ON p.id = o.project_id
WHERE o.disabled = 0
      AND o.order_status = 1
      AND p.league_type = 0
      AND o.city_id IN(1,2,3,4,5,6,7,8,370300,9,371100,10,11,12,13,14,15,17,16,330900,19,18,21,341100,20,23,22,25,24,27,26,29,28,30,440500,1000061,1000063,1000062,630100,51,141100,55,54,53,321000,52,59,58,57,511000,56,63,62,61,640100,60,68,69,70,71,64,65,66,77,78,330400,72,73,87,86,620100,81,370900,82,341300,89,320900,90,468000,440800,442000,340300,371400,511300,532900,320582,450600,370700,710100,330600,150200,469005,370600,450300,440400,371300,340200,130300,1000064,450500,320800,350600,440700,421000)
      AND date_format(o.refund_date,'%Y-%m-%d') <= '2015-08-28'
      AND date_format(o.refund_date,'%Y-%m-%d') >= '2015-08-24'
      AND o.refund_date<= '2015-08-28 00:00:00'
      AND o.refund_date >= '2015-08-24 00:00:00'
GROUP BY o.city_id;
SELECT
  o.city_id AS cityId,
  SUM(actual_groupbuy_amount) AS buyAmount
FROM dc_order o
  JOIN project p
    ON p.id = o.project_id
WHERE o.disabled = 0
      AND p.league_type = 0
      AND o.order_status = 1
      AND o.city_id IN(1,2,3,4,5,6,7,8,370300,9,371100,10,11,12,13,14,15,17,16,330900,19,18,21,341100,20,23,22,25,24,27,26,29,28,30,440500,1000061,1000063,1000062,630100,51,141100,55,54,53,321000,52,59,58,57,511000,56,63,62,61,640100,60,68,69,70,71,64,65,66,77,78,330400,72,73,87,86,620100,81,370900,82,341300,89,320900,90,468000,440800,442000,340300,371400,511300,532900,320582,450600,370700,710100,330600,150200,469005,370600,450300,440400,371300,340200,130300,1000064,450500,320800,350600,440700,421000)
      -- AND DATE_FORMAT(o.groupbuy_date,'%Y-%m-%d') <= '2015-08-28'
      -- AND DATE_FORMAT(o.groupbuy_date,'%Y-%m-%d') >= '2015-08-24'
      AND o.refund_date<= '2015-08-28 00:00:00'
      AND o.refund_date >= '2015-08-24 00:00:00'
GROUP BY o.city_id;


SELECT a.*
FROM
  (
    SELECT
      temp1.strDate,
      temp1.cityName,
      temp1.projectName,
      IFNULL(temp2.countNum, 0)               AS countNum,
      IFNULL(temp3.toraiseAmount, 0) / 10000  AS toraiseAmount,
      IFNULL(
          temp4.identificationChipsAmount,
          0
      ) / 10000                               AS identificationChipsAmount,
      IFNULL(temp5.refundAmount, 0) / 10000   AS refundAmount,
      IFNULL(temp6.invoicedAmount, 0) / 10000 AS invoicedAmount,
      (
        IFNULL(temp3.toraiseAmount, 0) - IFNULL(temp6.invoicedAmount, 0)
      ) / 10000                               AS uninvoiceAmount
    FROM
      (
        SELECT
          cgr.modify_time AS strDate,
          CONCAT(
              p.title,

              IF(
                  p.league_type = 0,
                  'ï¼ˆç›´è¥ï¼‰',
                  'ï¼ˆåŠ ç›Ÿï¼‰'
              )
          )               AS projectName,
          sc.city_name    AS cityName,
          p.id            AS pid
        FROM
          client_groupbuy_record cgr
          LEFT JOIN client_follow_up_record cfur ON cgr.follow_id = cfur.id
          LEFT JOIN project p ON cfur.project_id = p.id
          LEFT JOIN sys_city sc ON p.city_id = sc.id
        WHERE
-- DATE_FORMAT(cgr.modify_time, '%Y-%m-%d') = '2015-08-28'
          cgr.modify_time >= '2015-08-28 00:00:00'
          AND cgr.modify_time < '2015-08-29 00:00:00'
          AND 1 = 1
          AND (
            p.city_id IN (
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              370300,
              9,
              371100,
              10,
              11,
              12,
              13,
              14,
              15,
              17,
              16,
              330900,
              19,
              18,
              21,
              341100,
              20,
              23,
              22,
              25,
              24,
              27,
              26,
              29,
              28,
              30,
              440500,
              1000061,
              1000063,
              1000062,
              630100,
              51,
              141100,
              55,
              54,
              53,
              321000,
              52,
              59,
              58,
              57,
              511000,
              56,
              63,
              62,
              61,
              640100,
              60,
              68,
              69,
              70,
              71,
              64,
              65,
              66,
              77,
              78,
              330400,
              72,
              73,
              87,
              86,
              620100,
              81,
              370900,
              82,
              341300,
              89,
              320900,
              90,
              468000,
              440800,
              442000,
              340300,
              371400,
              511300,
              532900,
              320582,
              450600,
              370700,
              710100,
              330600,
              150200,
              469005,
              370600,
              450300,
              440400,
              371300,
              340200,
              130300,
              1000064,
              450500,
              320800,
              350600,
              440700,
              421000
            )
            AND p.league_type = 0
          )
        GROUP BY
          p.id
      ) AS temp1
      LEFT JOIN (
                  SELECT
                    COUNT(cdr.id) AS countNum,
                    p.id          AS pid
                  FROM
                    client_deal_record cdr
                    LEFT JOIN client_follow_up_record cfur ON cdr.follow_id = cfur.id
                    LEFT JOIN project p ON cfur.project_id = p.id
                  WHERE
                    cdr.STATUS = 'sale_approved'
                    -- AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') = '2015-08-28'
                    AND cdr.modify_time >= '2015-08-28 00:00:00'
                    AND cdr.modify_time < '2015-08-29 00:00:00'
                    AND 1 = 1
                    AND (
                      p.city_id IN (
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        370300,
                        9,
                        371100,
                        10,
                        11,
                        12,
                        13,
                        14,
                        15,
                        17,
                        16,
                        330900,
                        19,
                        18,
                        21,
                        341100,
                        20,
                        23,
                        22,
                        25,
                        24,
                        27,
                        26,
                        29,
                        28,
                        30,
                        440500,
                        1000061,
                        1000063,
                        1000062,
                        630100,
                        51,
                        141100,
                        55,
                        54,
                        53,
                        321000,
                        52,
                        59,
                        58,
                        57,
                        511000,
                        56,
                        63,
                        62,
                        61,
                        640100,
                        60,
                        68,
                        69,
                        70,
                        71,
                        64,
                        65,
                        66,
                        77,
                        78,
                        330400,
                        72,
                        73,
                        87,
                        86,
                        620100,
                        81,
                        370900,
                        82,
                        341300,
                        89,
                        320900,
                        90,
                        468000,
                        440800,
                        442000,
                        340300,
                        371400,
                        511300,
                        532900,
                        320582,
                        450600,
                        370700,
                        710100,
                        330600,
                        150200,
                        469005,
                        370600,
                        450300,
                        440400,
                        371300,
                        340200,
                        130300,
                        1000064,
                        450500,
                        320800,
                        350600,
                        440700,
                        421000
                      )
                      AND p.league_type = 0
                    )
                  GROUP BY
                    p.id
                ) AS temp2 ON temp1.pid = temp2.pid
      LEFT JOIN (
                  SELECT
                    IFNULL(
                        (
                          SELECT SUM(invoice_amount)
                          FROM
                            client_groupbuy_amount_record
                          WHERE
                            STATUS = 'buy_make'
                            AND client_groupbuy_record_id = cgr.id
                        ),
                        0
                    )    AS toraiseAmount,
                    p.id AS pid
                  FROM
                    client_groupbuy_record cgr
                    LEFT JOIN client_follow_up_record cfur ON cgr.follow_id = cfur.id
                    LEFT JOIN client_deal_record cdr ON cdr.follow_id = cfur.id
                    LEFT JOIN project p ON cfur.project_id = p.id
                  WHERE
                    cdr.STATUS = 'sale_approved'
                    -- AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') = '2015-08-28'
                    AND cdr.modify_time >= '2015-08-28 00:00:00'
                    AND cdr.modify_time < '2015-08-29 00:00:00'
                    AND 1 = 1
                    AND (
                      p.city_id IN (
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        370300,
                        9,
                        371100,
                        10,
                        11,
                        12,
                        13,
                        14,
                        15,
                        17,
                        16,
                        330900,
                        19,
                        18,
                        21,
                        341100,
                        20,
                        23,
                        22,
                        25,
                        24,
                        27,
                        26,
                        29,
                        28,
                        30,
                        440500,
                        1000061,
                        1000063,
                        1000062,
                        630100,
                        51,
                        141100,
                        55,
                        54,
                        53,
                        321000,
                        52,
                        59,
                        58,
                        57,
                        511000,
                        56,
                        63,
                        62,
                        61,
                        640100,
                        60,
                        68,
                        69,
                        70,
                        71,
                        64,
                        65,
                        66,
                        77,
                        78,
                        330400,
                        72,
                        73,
                        87,
                        86,
                        620100,
                        81,
                        370900,
                        82,
                        341300,
                        89,
                        320900,
                        90,
                        468000,
                        440800,
                        442000,
                        340300,
                        371400,
                        511300,
                        532900,
                        320582,
                        450600,
                        370700,
                        710100,
                        330600,
                        150200,
                        469005,
                        370600,
                        450300,
                        440400,
                        371300,
                        340200,
                        130300,
                        1000064,
                        450500,
                        320800,
                        350600,
                        440700,
                        421000
                      )
                      AND p.league_type = 0
                    )
                  GROUP BY
                    p.id
                ) AS temp3 ON temp1.pid = temp3.pid
      LEFT JOIN (
                  SELECT
                    sum(
                        (
                          SELECT IFNULL(SUM(invoice_amount), 0) AS amount
                          FROM
                            client_groupbuy_amount_record
                          WHERE
                            `status` = 'buy_make'
                            AND client_groupbuy_record_id = cgr.id
                        )
                    )    AS identificationChipsAmount,
                    p.id AS pid
                  FROM
                    client_groupbuy_record cgr
                    LEFT JOIN client_follow_up_record cfur ON cgr.follow_id = cfur.id
                    LEFT JOIN project p ON cfur.project_id = p.id
                  WHERE
                    cgr.STATUS = 'buy_make'
                    -- DATE_FORMAT(cgr.modify_time, '%Y-%m-%d') = '2015-08-28'
                    AND cgr.modify_time >= '2015-08-28 00:00:00'
                    AND cgr.modify_time < '2015-08-29 00:00:00'
                    AND 1 = 1
                    AND (
                      p.city_id IN (
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        370300,
                        9,
                        371100,
                        10,
                        11,
                        12,
                        13,
                        14,
                        15,
                        17,
                        16,
                        330900,
                        19,
                        18,
                        21,
                        341100,
                        20,
                        23,
                        22,
                        25,
                        24,
                        27,
                        26,
                        29,
                        28,
                        30,
                        440500,
                        1000061,
                        1000063,
                        1000062,
                        630100,
                        51,
                        141100,
                        55,
                        54,
                        53,
                        321000,
                        52,
                        59,
                        58,
                        57,
                        511000,
                        56,
                        63,
                        62,
                        61,
                        640100,
                        60,
                        68,
                        69,
                        70,
                        71,
                        64,
                        65,
                        66,
                        77,
                        78,
                        330400,
                        72,
                        73,
                        87,
                        86,
                        620100,
                        81,
                        370900,
                        82,
                        341300,
                        89,
                        320900,
                        90,
                        468000,
                        440800,
                        442000,
                        340300,
                        371400,
                        511300,
                        532900,
                        320582,
                        450600,
                        370700,
                        710100,
                        330600,
                        150200,
                        469005,
                        370600,
                        450300,
                        440400,
                        371300,
                        340200,
                        130300,
                        1000064,
                        450500,
                        320800,
                        350600,
                        440700,
                        421000
                      )
                      AND p.league_type = 0
                    )
                  GROUP BY
                    p.id
                ) AS temp4 ON temp1.pid = temp4.pid
      LEFT JOIN (
                  SELECT
                    SUM(crr.amount) AS refundAmount,
                    p.id            AS pid
                  FROM
                    client_refund_record crr
                    LEFT JOIN client_follow_up_record cfur ON crr.follow_id = cfur.id
                    LEFT JOIN project p ON cfur.project_id = p.id
                  WHERE
                    crr.STATUS = 'refund_paying'
                    -- AND DATE_FORMAT(crr.modify_time, '%Y-%m-%d') = '2015-08-28'
                    AND crr.modify_time >= '2015-08-28 00:00:00'
                    AND crr.modify_time < '2015-08-29 00:00:00'
                    AND 1 = 1
                    AND (
                      p.city_id IN (
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        370300,
                        9,
                        371100,
                        10,
                        11,
                        12,
                        13,
                        14,
                        15,
                        17,
                        16,
                        330900,
                        19,
                        18,
                        21,
                        341100,
                        20,
                        23,
                        22,
                        25,
                        24,
                        27,
                        26,
                        29,
                        28,
                        30,
                        440500,
                        1000061,
                        1000063,
                        1000062,
                        630100,
                        51,
                        141100,
                        55,
                        54,
                        53,
                        321000,
                        52,
                        59,
                        58,
                        57,
                        511000,
                        56,
                        63,
                        62,
                        61,
                        640100,
                        60,
                        68,
                        69,
                        70,
                        71,
                        64,
                        65,
                        66,
                        77,
                        78,
                        330400,
                        72,
                        73,
                        87,
                        86,
                        620100,
                        81,
                        370900,
                        82,
                        341300,
                        89,
                        320900,
                        90,
                        468000,
                        440800,
                        442000,
                        340300,
                        371400,
                        511300,
                        532900,
                        320582,
                        450600,
                        370700,
                        710100,
                        330600,
                        150200,
                        469005,
                        370600,
                        450300,
                        440400,
                        371300,
                        340200,
                        130300,
                        1000064,
                        450500,
                        320800,
                        350600,
                        440700,
                        421000
                      )
                      AND p.league_type = 0
                    )
                  GROUP BY
                    p.id
                ) AS temp5 ON temp1.pid = temp5.pid
      LEFT JOIN (
                  SELECT
                    SUM(cgr.received_amount) AS invoicedAmount,
                    p.id                     AS pid
                  FROM
                    client_groupbuy_record cgr
                    LEFT JOIN client_follow_up_record cfur ON cgr.follow_id = cfur.id
                    LEFT JOIN client_deal_record cdr ON cdr.follow_id = cfur.id
                    LEFT JOIN project p ON cfur.project_id = p.id
                  WHERE
                    cdr.invoice_status = 'invoiced'
                    -- AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') = '2015-08-28'
                    AND cdr.modify_time >= '2015-08-28 00:00:00'
                    AND cdr.modify_time < '2015-08-29 00:00:00'
                    AND 1 = 1
                    AND (
                      p.city_id IN (
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        370300,
                        9,
                        371100,
                        10,
                        11,
                        12,
                        13,
                        14,
                        15,
                        17,
                        16,
                        330900,
                        19,
                        18,
                        21,
                        341100,
                        20,
                        23,
                        22,
                        25,
                        24,
                        27,
                        26,
                        29,
                        28,
                        30,
                        440500,
                        1000061,
                        1000063,
                        1000062,
                        630100,
                        51,
                        141100,
                        55,
                        54,
                        53,
                        321000,
                        52,
                        59,
                        58,
                        57,
                        511000,
                        56,
                        63,
                        62,
                        61,
                        640100,
                        60,
                        68,
                        69,
                        70,
                        71,
                        64,
                        65,
                        66,
                        77,
                        78,
                        330400,
                        72,
                        73,
                        87,
                        86,
                        620100,
                        81,
                        370900,
                        82,
                        341300,
                        89,
                        320900,
                        90,
                        468000,
                        440800,
                        442000,
                        340300,
                        371400,
                        511300,
                        532900,
                        320582,
                        450600,
                        370700,
                        710100,
                        330600,
                        150200,
                        469005,
                        370600,
                        450300,
                        440400,
                        371300,
                        340200,
                        130300,
                        1000064,
                        450500,
                        320800,
                        350600,
                        440700,
                        421000
                      )
                      AND p.league_type = 0
                    )
                  GROUP BY
                    p.id
                ) AS temp6 ON temp1.pid = temp6.pid
  ) AS a
WHERE
  (
    a.toraiseAmount > 0
    OR a.identificationChipsAmount > 0
    OR a.refundAmount > 0
    OR a.invoicedAmount > 0
  )
LIMIT 0,
  10;



SELECT a.*
FROM (SELECT temp1.strDate,
        temp1.cityName,
        temp1.projectName,
        IFNULL(temp2.countNum, 0) AS countNum,
        IFNULL(temp3.toraiseAmount, 0) / 10000 AS toraiseAmount,
        IFNULL(temp1.receivedAmount, 0) / 10000 as receivedAmount,
        IFNULL(temp4.identificationChipsAmount, 0) / 10000 AS identificationChipsAmount,
        IFNULL(temp5.refundAmount, 0) / 10000 AS refundAmount,
        IFNULL(temp6.invoicedAmount, 0) / 10000 AS invoicedAmount,
        (IFNULL(temp3.toraiseAmount, 0) -
         IFNULL(temp6.invoicedAmount, 0)) / 10000 AS uninvoiceAmount
      FROM (SELECT cgr.modify_time AS strDate,
                   CONCAT(p.title,
                          IF(p.league_type = 0, '（直营）', '（加盟）')) AS projectName,
                   sc.city_name AS cityName,
                   sum(cgr.received_amount) as receivedAmount,
                   p.id AS pid
            FROM client_groupbuy_record cgr
              LEFT JOIN client_follow_up_record cfur
                ON cgr.follow_id = cfur.id
              LEFT JOIN project p
                ON cfur.project_id = p.id
              LEFT JOIN sys_city sc
                ON p.city_id = sc.id
            WHERE DATE_FORMAT(cgr.modify_time, '%Y-%m-%d') =
                  '2015-09-01'
                  AND 1 = 1
                  and ((p.city_id in (1,
                                      2,
                                      370700,
                                      3,
                                      710100,
                                      4,
                                      5,
                                      6,
                                      7,
                                      8,
                                      9,
                                      10,
                                      11,
                                      12,
                                      13,
                                      14,
                                      15,
                                      17,
                                      330900,
                                      16,
                                      19,
                                      18,
                                      21,
                                      20,
                                      23,
                                      22,
                                      25,
                                      24,
                                      27,
                                      26,
                                      29,
                                      28,
                                      150200,
                                      440500,
                                      469005,
                                      51,
                                      55,
                                      54,
                                      53,
                                      52,
                                      321000,
                                      59,
                                      58,
                                      511000,
                                      57,
                                      56,
                                      63,
                                      62,
                                      640100,
                                      61,
                                      60,
                                      68,
                                      69,
                                      370600,
                                      70,
                                      71,
                                      64,
                                      65,
                                      66,
                                      440400,
                                      77,
                                      78,
                                      72,
                                      73,
                                      87,
                                      620100,
                                      86,
                                      81,
                                      82,
                                      341300,
                                      442000,
                                      511300) and p.league_type = 0) or
                       (p.league_company in
                        (52283231, 53941888, 2358, 452240) and
                        p.league_type = 1))
            GROUP BY p.id) AS temp1
        LEFT JOIN (SELECT COUNT(cdr.id) AS countNum, p.id AS pid
                   FROM client_deal_record cdr
                     LEFT JOIN client_follow_up_record cfur
                       ON cdr.follow_id = cfur.id
                     LEFT JOIN project p
                       ON cfur.project_id = p.id
                   WHERE cdr.status = 'sale_approved'
                         AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') =
                             '2015-09-01'
                         AND 1 = 1
                         and ((p.city_id in (1,
                                             2,
                                             370700,
                                             3,
                                             710100,
                                             4,
                                             5,
                                             6,
                                             7,
                                             8,
                                             9,
                                             10,
                                             11,
                                             12,
                                             13,
                                             14,
                                             15,
                                             17,
                                             330900,
                                             16,
                                             19,
                                             18,
                                             21,
                                             20,
                                             23,
                                             22,
                                             25,
                                             24,
                                             27,
                                             26,
                                             29,
                                             28,
                                             150200,
                                             440500,
                                             469005,
                                             51,
                                             55,
                                             54,
                                             53,
                                             52,
                                             321000,
                                             59,
                                             58,
                                             511000,
                                             57,
                                             56,
                                             63,
                                             62,
                                             640100,
                                             61,
                                             60,
                                             68,
                                             69,
                                             370600,
                                             70,
                                             71,
                                             64,
                                             65,
                                             66,
                                             440400,
                                             77,
                                             78,
                                             72,
                                             73,
                                             87,
                                             620100,
                                             86,
                                             81,
                                             82,
                                             341300,
                                             442000,
                                             511300) and p.league_type = 0) or
                              (p.league_company in
                               (52283231, 53941888, 2358, 452240) and
                               p.league_type = 1))
                   GROUP BY p.id) AS temp2
          ON temp1.pid = temp2.pid
        LEFT JOIN (SELECT IFNULL((SELECT SUM(invoice_amount)
                                  FROM client_groupbuy_amount_record
                                  WHERE STATUS = 'buy_make'
                                        AND client_groupbuy_record_id = cgr.id),
                                 0) AS toraiseAmount,
                          sum(cgr.received_amount) as receivedAmount,
                          p.id AS pid
                   FROM client_groupbuy_record cgr
                     LEFT JOIN client_follow_up_record cfur
                       ON cgr.follow_id = cfur.id
                     LEFT JOIN client_deal_record cdr
                       ON cdr.follow_id = cfur.id
                     LEFT JOIN project p
                       ON cfur.project_id = p.id
                   WHERE cdr.status = 'sale_approved'
                         AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') =
                             '2015-09-01'
                         AND 1 = 1
                         and ((p.city_id in (1,
                                             2,
                                             370700,
                                             3,
                                             710100,
                                             4,
                                             5,
                                             6,
                                             7,
                                             8,
                                             9,
                                             10,
                                             11,
                                             12,
                                             13,
                                             14,
                                             15,
                                             17,
                                             330900,
                                             16,
                                             19,
                                             18,
                                             21,
                                             20,
                                             23,
                                             22,
                                             25,
                                             24,
                                             27,
                                             26,
                                             29,
                                             28,
                                             150200,
                                             440500,
                                             469005,
                                             51,
                                             55,
                                             54,
                                             53,
                                             52,
                                             321000,
                                             59,
                                             58,
                                             511000,
                                             57,
                                             56,
                                             63,
                                             62,
                                             640100,
                                             61,
                                             60,
                                             68,
                                             69,
                                             370600,
                                             70,
                                             71,
                                             64,
                                             65,
                                             66,
                                             440400,
                                             77,
                                             78,
                                             72,
                                             73,
                                             87,
                                             620100,
                                             86,
                                             81,
                                             82,
                                             341300,
                                             442000,
                                             511300) and p.league_type = 0) or
                              (p.league_company in
                               (52283231, 53941888, 2358, 452240) and
                               p.league_type = 1))
                   GROUP BY p.id) AS temp3
          ON temp1.pid = temp3.pid
        LEFT JOIN (SELECT sum((SELECT IFNULL(SUM(invoice_amount), 0) AS amount
                               FROM client_groupbuy_amount_record
                               WHERE status = 'buy_make'
                                     AND client_groupbuy_record_id = cgr.id)) AS identificationChipsAmount,
                          p.id AS pid
                   FROM client_groupbuy_record cgr
                     LEFT JOIN client_follow_up_record cfur
                       ON cgr.follow_id = cfur.id
                     LEFT JOIN project p
                       ON cfur.project_id = p.id
                   WHERE cgr.status = 'buy_make'
                         AND DATE_FORMAT(cgr.modify_time, '%Y-%m-%d') =
                             '2015-09-01'
                         AND 1 = 1
                         and ((p.city_id in (1,
                                             2,
                                             370700,
                                             3,
                                             710100,
                                             4,
                                             5,
                                             6,
                                             7,
                                             8,
                                             9,
                                             10,
                                             11,
                                             12,
                                             13,
                                             14,
                                             15,
                                             17,
                                             330900,
                                             16,
                                             19,
                                             18,
                                             21,
                                             20,
                                             23,
                                             22,
                                             25,
                                             24,
                                             27,
                                             26,
                                             29,
                                             28,
                                             150200,
                                             440500,
                                             469005,
                                             51,
                                             55,
                                             54,
                                             53,
                                             52,
                                             321000,
                                             59,
                                             58,
                                             511000,
                                             57,
                                             56,
                                             63,
                                             62,
                                             640100,
                                             61,
                                             60,
                                             68,
                                             69,
                                             370600,
                                             70,
                                             71,
                                             64,
                                             65,
                                             66,
                                             440400,
                                             77,
                                             78,
                                             72,
                                             73,
                                             87,
                                             620100,
                                             86,
                                             81,
                                             82,
                                             341300,
                                             442000,
                                             511300) and p.league_type = 0) or
                              (p.league_company in
                               (52283231, 53941888, 2358, 452240) and
                               p.league_type = 1))
                   GROUP BY p.id) AS temp4
          ON temp1.pid = temp4.pid
        LEFT JOIN (SELECT SUM(crr.amount) AS refundAmount, p.id AS pid
                   FROM client_refund_record crr
                     LEFT JOIN client_follow_up_record cfur
                       ON crr.follow_id = cfur.id
                     LEFT JOIN project p
                       ON cfur.project_id = p.id
                   WHERE crr.status = 'refund_paying'
                         AND DATE_FORMAT(crr.modify_time, '%Y-%m-%d') =
                             '2015-09-01'
                         AND 1 = 1
                         and ((p.city_id in (1,
                                             2,
                                             370700,
                                             3,
                                             710100,
                                             4,
                                             5,
                                             6,
                                             7,
                                             8,
                                             9,
                                             10,
                                             11,
                                             12,
                                             13,
                                             14,
                                             15,
                                             17,
                                             330900,
                                             16,
                                             19,
                                             18,
                                             21,
                                             20,
                                             23,
                                             22,
                                             25,
                                             24,
                                             27,
                                             26,
                                             29,
                                             28,
                                             150200,
                                             440500,
                                             469005,
                                             51,
                                             55,
                                             54,
                                             53,
                                             52,
                                             321000,
                                             59,
                                             58,
                                             511000,
                                             57,
                                             56,
                                             63,
                                             62,
                                             640100,
                                             61,
                                             60,
                                             68,
                                             69,
                                             370600,
                                             70,
                                             71,
                                             64,
                                             65,
                                             66,
                                             440400,
                                             77,
                                             78,
                                             72,
                                             73,
                                             87,
                                             620100,
                                             86,
                                             81,
                                             82,
                                             341300,
                                             442000,
                                             511300) and p.league_type = 0) or
                              (p.league_company in
                               (52283231, 53941888, 2358, 452240) and
                               p.league_type = 1))
                   GROUP BY p.id) AS temp5
          ON temp1.pid = temp5.pid
        LEFT JOIN (SELECT SUM(cgr.received_amount) AS invoicedAmount,
                          p.id AS pid
                   FROM client_groupbuy_record cgr
                     LEFT JOIN client_follow_up_record cfur
                       ON cgr.follow_id = cfur.id
                     LEFT JOIN client_deal_record cdr
                       ON cdr.follow_id = cfur.id
                     LEFT JOIN project p
                       ON cfur.project_id = p.id
                   WHERE cdr.invoice_status = 'invoiced'
                         AND DATE_FORMAT(cdr.modify_time, '%Y-%m-%d') =
                             '2015-09-01'
                         AND 1 = 1
                         and ((p.city_id in (1,
                                             2,
                                             370700,
                                             3,
                                             710100,
                                             4,
                                             5,
                                             6,
                                             7,
                                             8,
                                             9,
                                             10,
                                             11,
                                             12,
                                             13,
                                             14,
                                             15,
                                             17,
                                             330900,
                                             16,
                                             19,
                                             18,
                                             21,
                                             20,
                                             23,
                                             22,
                                             25,
                                             24,
                                             27,
                                             26,
                                             29,
                                             28,
                                             150200,
                                             440500,
                                             469005,
                                             51,
                                             55,
                                             54,
                                             53,
                                             52,
                                             321000,
                                             59,
                                             58,
                                             511000,
                                             57,
                                             56,
                                             63,
                                             62,
                                             640100,
                                             61,
                                             60,
                                             68,
                                             69,
                                             370600,
                                             70,
                                             71,
                                             64,
                                             65,
                                             66,
                                             440400,
                                             77,
                                             78,
                                             72,
                                             73,
                                             87,
                                             620100,
                                             86,
                                             81,
                                             82,
                                             341300,
                                             442000,
                                             511300) and p.league_type = 0) or
                              (p.league_company in
                               (52283231, 53941888, 2358, 452240) and
                               p.league_type = 1))
                   GROUP BY p.id) AS temp6
          ON temp1.pid = temp6.pid) as a
where (a.toraiseAmount > 0 OR a.identificationChipsAmount > 0 OR
       a.refundAmount > 0 OR a.invoicedAmount > 0) limit 0, 10

select * from project_type;

select * from client_deal_record where oldToNew=1 and old_customer_no='42512451646848458456';
SELECT * from document where object_id=111100024292325;


SELECT *
FROM cm_group_fee_reduce_apply
  where client_groupbuy_id is not null
GROUP BY client_groupbuy_id
HAVING count(1) > 1;
select * from cm_group_fee_reduce_apply where wf_instance_id=25090076;
select * from client_groupbuy_record where id=19691019700;

SELECT * from dual;
select * from cm_full_cycle_project_budget;

select lprd.fixed_amount,wi.id,pt.project_id
from liq_personal_rules_details lprd join liq_personal_rules lpr on lprd.personal_rules_id = lpr.id
  join liq_commission_settlement_standards lcss on lpr.standards_id = lcss.id
  join wf_instance wi on lcss.wf_instance_id = wi.id
  join project_type pt on lprd.project_type_id = pt.id
where wi.status = 2 and lprd.channel_type = 'pd' and pt.project_id =1101101997284289
order by lprd.create_time desc
limit 1;
select * from wf_instance where id=1101102668516851;
select * from wf_instance where id=1101102462468018;
select * from project_type where project_id=1101102140078944;
select * from liq_personal_rules_details where channel_type = 'pd' and project_type_id in (1101102200830633
,1101102200830632
,1101102131446323
,1101102325281962);
select * from wf_instance order by create_time desc;
select * from wf_instance where id=1101102694781089;
select * from liq_commission_settlement_standards where wf_instance_id=1101102694781089;
select * from liq_personal_rules where standards_id=1101102694776084;
SELECT * from liq_personal_rules_details where personal_rules_id=1101102694777085;