---查询费用申请单原始SQL 运行时间 1.25秒
SELECT
  fee.id,
  fee.title,
  fee.flow_no              AS flowNo,
  fee.fee_type_name        AS feeTypeName,
  fee.sub_fee_type_name    AS subFeeTypeName,
  instance.start_user_name AS startUserName,
  instance.start_time      AS startTime
FROM cm_project_fee fee,
  wf_instance instance
WHERE fee.wf_instance_id = instance.id
      AND instance.status IN (2) AND fee.project_id = 1003743741
      AND fee.id IN
          (
            SELECT feeInfo.fee_id
            FROM cm_project_fee_info feeInfo
            WHERE feeInfo.id NOT IN (
              SELECT IFNULL(contractFeeInfo.fee_info_id, 0)
              FROM
                cm_apply_contract contract,
                wf_instance wf,
                cm_project_fee projectFee,
                cm_apply_contract_fee_info contractFeeInfo
              WHERE
                contract.fee_id = projectFee.id
                AND wf.id = contract.wf_instance_id
                AND contractFeeInfo.apply_contract_id = contract.id
                AND wf.STATUS IN (1, 2, 5, 6)
                AND 1 = 1

              UNION

              SELECT IFNULL(repayInfo.fee_info_id, 0)
              FROM
                cm_project_repay repay,
                cm_project_repay_info repayInfo,
                wf_instance wf,
                cm_project_fee projectFee
              WHERE
                repay.id = repayInfo.repay_id
                AND repay.wf_instance_id = wf.id
                AND repay.fee_id = projectFee.id
                AND wf.STATUS IN (1, 2, 5, 6)
                AND 1 = 1
            )
            GROUP BY feeInfo.fee_id
          ) ;
---优化后SQL 运行时间0.1185秒
SELECT
  fee.id,
  fee.title,
  fee.flow_no              AS flowNo,
  fee.fee_type_name        AS feeTypeName,
  fee.sub_fee_type_name    AS subFeeTypeName,
  instance.start_user_name AS startUserName,
  instance.start_time      AS startTime
FROM cm_project_fee fee JOIN wf_instance instance
    ON fee.wf_instance_id = instance.id
WHERE instance.status IN (2) AND fee.project_id = 1003743741 AND exists(SELECT feeInfo.id
                                                                        FROM cm_project_fee_info feeInfo
                                                                        WHERE fee.id = feeInfo.fee_id)
      AND NOT exists(SELECT contractFeeInfo.fee_info_id
                     FROM cm_apply_contract contract,
                       cm_apply_contract_fee_info contractFeeInfo,
                       wf_instance wf
                     WHERE
                       wf.id = contract.wf_instance_id
                       AND contractFeeInfo.apply_contract_id = contract.id
                       AND contract.fee_id = fee.id
                       AND wf.STATUS IN (1, 2, 5, 6)
)
      AND NOT exists(SELECT repayInfo.fee_info_id
                     FROM cm_project_repay repay,
                       cm_project_repay_info repayInfo,
                       wf_instance wf
                     WHERE repay.id = repayInfo.repay_id
                           AND repay.wf_instance_id = wf.id
                           AND repay.fee_id = fee.id
                           AND wf.STATUS IN (1, 2, 5, 6)
);
--参考方案1 运行时间0.95秒
SELECT
  fee.id,
  fee.title,
  fee.flow_no              AS flowNo,
  fee.fee_type_name        AS feeTypeName,
  fee.sub_fee_type_name    AS subFeeTypeName,
  instance.start_user_name AS startUserName,
  instance.start_time      AS startTime
FROM cm_project_fee fee JOIN wf_instance instance
    ON fee.wf_instance_id = instance.id
  join cm_project_fee_info feeInfo on fee.id = feeInfo.fee_id
WHERE instance.status IN (2) AND fee.project_id = 1003743741
      AND NOT exists(SELECT contractFeeInfo.fee_info_id
                     FROM cm_apply_contract contract,
                       cm_apply_contract_fee_info contractFeeInfo,
                       wf_instance wf,
                       cm_project_fee projectFee
                     WHERE contract.fee_id = projectFee.id AND
                           wf.id = contract.wf_instance_id
                           AND contractFeeInfo.apply_contract_id = contract.id
                           and contractFeeInfo.fee_info_id=feeInfo.id
                           AND wf.STATUS IN (1, 2, 5, 6)
)
      AND NOT exists(SELECT repayInfo.fee_info_id
                     FROM cm_project_repay repay,
                       cm_project_repay_info repayInfo,
                       wf_instance wf,
                       cm_project_fee projectFee
                     WHERE repay.id = repayInfo.repay_id
                           AND repay.wf_instance_id = wf.id
                           AND repay.fee_id = projectFee.id
                           and repayInfo.fee_info_id=feeInfo.id
                           AND wf.STATUS IN (1, 2, 5, 6)
) group by fee_id;
---参考方案2 运行时间1.28秒
SELECT
  fee.id,
  fee.title,
  fee.flow_no              AS flowNo,
  fee.fee_type_name        AS feeTypeName,
  fee.sub_fee_type_name    AS subFeeTypeName,
  instance.start_user_name AS startUserName,
  instance.start_time      AS startTime
FROM cm_project_fee fee JOIN wf_instance instance
    ON fee.wf_instance_id = instance.id join
    cm_project_fee_info feeInfo on fee.id = feeInfo.fee_id
WHERE instance.status IN (2) AND fee.project_id = 1003743741
      AND NOT exists(SELECT contractFeeInfo.fee_info_id
                     FROM cm_apply_contract contract,
                       cm_apply_contract_fee_info contractFeeInfo,
                       wf_instance wf
                     WHERE
                       wf.id = contract.wf_instance_id
                       AND contractFeeInfo.apply_contract_id = contract.id
                       AND contract.fee_id = fee.id
                       AND wf.STATUS IN (1, 2, 5, 6)
)
      AND NOT exists(SELECT repayInfo.fee_info_id
                     FROM cm_project_repay repay,
                       cm_project_repay_info repayInfo,
                       wf_instance wf
                     WHERE repay.id = repayInfo.repay_id
                           AND repay.wf_instance_id = wf.id
                           AND repay.fee_id = fee.id
                           AND wf.STATUS IN (1, 2, 5, 6)
);

select * from cm_project_fee fee where  fee.id=1003833831 and fee.project_id=1003743741;
select * from cm_project_fee_info where fee_id=1003833831;#1003834833
select * from wf_instance where id=1003759769 and status=2;
select * from cm_project_fee_info where fee_id=1003833831;
select * from cm_apply_contract_fee_info where fee_info_id=1003834833;
select * from cm_apply_contract_fee_info where fee_id=1003833831;
select * from cm_project_repay_info where fee_info_id=1003834833;
select * from cm_project_repay where id=1003846844;
select * from wf_instance where id=1003759774 and STATUS IN (1, 2, 5, 6);
