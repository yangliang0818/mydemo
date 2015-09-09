CREATE TABLE DIM_BASS1_CHANNEL_OP_INFO_20150415
(
  ORG_CLASS1     VARCHAR(12),--一级分类
  ORG_CLASS2     VARCHAR(24),--二级分类
  ORG_CLASS3     VARCHAR(48),--三级分类
  BASS1_CHL      VARCHAR(48),   --一经渠道名称，目前只区分实体渠道，电子渠道的大类
  BASS1_CHLNAME  VARCHAR(48),
  OP_ID          BIGINT,
  ORG_ID         BIGINT
)DATA CAPTURE NONE
 IN TBSN_APP
  PARTITIONING KEY
   (OP_ID
   ) USING HASHING;
CREATE TABLE TMP_DIM_BASS1_CHANNEL_OP_INFO_20150415
(
  ORG_CLASS1     VARCHAR(12),--一级分类
  ORG_CLASS2     VARCHAR(24),--二级分类
  ORG_CLASS3     VARCHAR(48),--三级分类
  OP_ID          BIGINT
)DATA CAPTURE NONE
 IN TBSN_APP
  PARTITIONING KEY
   (OP_ID
   ) USING HASHING;
--先插入自助终端的归类
INSERT INTO TMP_DIM_BASS1_CHANNEL_OP_INFO_20150415
            SELECT DISTINCT '电子渠道' AS KIND_NAME1,
                            '自营电子渠道' AS KIND_NAME2,
                            '自助终端' AS KIND_NAME3,
                            A.OP_ID
              FROM (SELECT INT(TERMINALOPID) AS OP_ID
                      FROM SHODS.ODS_DB_AP_ATM_PCSETTINGEXT_20150415
                     WHERE TERMINALCODE <> '123456789012345' -- 老自助终端
                       AND TERMINALOPID IS NOT NULL
                    UNION
                    SELECT INT(TERMDESP) AS OP_ID
                      FROM SHODS.ODS_TERM_20150415 -- 新的凯信达机器
                     WHERE SUBSTR(TERMDESP, 1, 1) BETWEEN '0' AND '9') A -- 等同于 TERMDESP IS NOT NULL AND UPPER(TERMDESP) NOT LIKE '%TEST%' AND TERMDESP <> '周浦营业厅'
              LEFT JOIN (SELECT ORG_ID,
                                ORG_NAME,
                                OP_ID,
                                OP_NAME,
                                LOGIN_NAME,
                                BUSI_CHL_TYPE_NAME,
                                ROW_NUMBER() OVER(PARTITION BY OP_ID ORDER BY START_DATE DESC, END_DATE DESC) AS SEQ_NO
                           FROM SHDW.DIM_PRTY_OPER_INFO
                          WHERE BUSI_CHL_TYPE_NAME = 'BOSS'
                            AND START_DATE <='2015-04-14') B
                ON A.OP_ID = B.OP_ID
               AND B.SEQ_NO = 1
             WHERE B.ORG_ID IS NOT NULL;
INSERT INTO TMP_DIM_BASS1_CHANNEL_OP_INFO_20150415 (ORG_CLASS1,ORG_CLASS2,ORG_CLASS3,OP_ID)
                SELECT G.ORG_CLASS1,G.ORG_CLASS2,G.ORG_CLASS3,G.OP_ID FROM
                (
                SELECT DISTINCT '电子渠道' AS ORG_CLASS1,
                                '自营电子渠道' AS ORG_CLASS2,
                                CASE
                                  WHEN A.OP_ID = 999990001 OR A.ORG_ID = 402852 THEN
                                   '网上营业厅'
                                  WHEN A.OP_ID = 999990002 THEN
                                   'WAP'
                                  WHEN A.OP_ID IN (999990021, 999990101) THEN
                                   '10086自助'
                                  WHEN A.OP_ID = 999990024 AND A.OP_NAME = '网上商城后台接口' THEN
                                   '网上商城'
                                  WHEN A.OP_ID = 999990076 AND A.OP_NAME = 'CBOSS' THEN
                                   'CBOSS'
                                  WHEN A.OP_ID = 999990077 THEN
                                   '短信营业厅'
                                  WHEN A.OP_ID = 999990091 THEN
                                   '客户端'
                                  WHEN A.OP_ID = 999990099 AND A.OP_NAME = '统一支付平台' THEN
                                   '统一支付'
                                  WHEN A.BUSI_CHL_TYPE_NAME = 'CCS' THEN
                                   '热线电话' -- 10086人工
                                  WHEN A.OP_ID = 999990121 THEN
                                   '互联网外链' -- 划入网上营业厅
                                  WHEN A.OP_ID = 999990122 THEN
                                   '支付宝' -- 划入网上营业厅
                                  WHEN A.OP_ID = 999990133 THEN
                                   '微信营业厅' -- 划入网上营业厅
                                  WHEN A.OP_ID = 9 AND A.OP_NAME = '后台进程' THEN
                                   NULL
                                END AS ORG_CLASS3,
                                A.OP_ID
                  FROM (SELECT ORG_ID,
                               ORG_NAME,
                               OP_ID,
                               OP_NAME,
                               LOGIN_NAME,
                               BUSI_CHL_TYPE_NAME,
                               ROW_NUMBER() OVER(PARTITION BY OP_ID ORDER BY START_DATE DESC, END_DATE DESC) AS SEQ_NO
                          FROM SHDW.DIM_PRTY_OPER_INFO
                         WHERE UPPER(NVL(LOGIN_NAME, '-1')) NOT LIKE '%GSJK%'
                           AND START_DATE <='2015-04-13') A
                 WHERE A.SEQ_NO = 1
                   AND (A.OP_ID IN (999990001,
                                    999990002,
                                    999990021,
                                    999990024,
                                    999990076,
                                    999990077,
                                    999990091,
                                    999990099,
                                    999990101,
                                    999990121,
                                    999990122,
                                    999990133) OR A.BUSI_CHL_TYPE_NAME = 'CCS' OR
                       A.ORG_ID = 402852 OR A.OP_ID = 9 AND A.OP_NAME = '后台进程')
                )G
                LEFT JOIN TMP_DIM_BASS1_CHANNEL_OP_INFO_20150415 B ON G.OP_ID=B.OP_ID
                WHERE B.OP_ID IS NULL;
INSERT INTO DIM_BASS1_CHANNEL_OP_INFO_20150415
SELECT NVL(B.ORG_CLASS1,A.ORG_CLASS1),
       NVL(B.ORG_CLASS2,A.ORG_CLASS2),
       NVL(B.ORG_CLASS3,A.ORG_CLASS3),
       NVL(B.BASS1_CHL,A.BASS1_CHL),
       NVL(B.BASS1_CHLNAME,A.BASS1_CHLNAME),
       NVL(B.OP_ID,A.OP_ID),
       A.ORG_ID
 FROM DIM_BASS1_CHANNEL_OP_INFO_20150413 A FULL JOIN
 (SELECT ORG_CLASS1,ORG_CLASS2,ORG_CLASS3,
 CASE WHEN ORG_CLASS3='自助终端' THEN 'BASS1_ST'
      WHEN ORG_CLASS3='短信营业厅' THEN 'BASS1_SM'
      WHEN ORG_CLASS3='CBOSS' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='后台进程' THEN 'BASS1_UM'
      WHEN ORG_CLASS3='网上商城后台接口' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='客户端' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='热线电话' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='互联网分销' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='10086自助' THEN 'BASS1_HL'
      WHEN ORG_CLASS3='WAP' THEN 'WAP'
      WHEN ORG_CLASS3='统一支付平台' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='网上营业厅' THEN 'BASS1_WB'
      WHEN ORG_CLASS3='微信营业厅' THEN 'BASS1_WB'
      ELSE 'BASS1_UM'
      END AS BASS1_CHL,
      CASE WHEN ORG_CLASS3='自助终端' THEN '自助终端电子渠道'
            WHEN ORG_CLASS3='短信营业厅' THEN '短信'
            WHEN ORG_CLASS3='CBOSS' THEN '其他渠道'
            WHEN ORG_CLASS3='后台进程' THEN '其他渠道'
            WHEN ORG_CLASS3='网上商城后台接口' THEN '网站'
            WHEN ORG_CLASS3='客户端' THEN '网站'
            WHEN ORG_CLASS3='热线电话' THEN '热线'
            WHEN ORG_CLASS3='互联网分销' THEN '网站'
            WHEN ORG_CLASS3='10086自助' THEN '热线'
            WHEN ORG_CLASS3='WAP' THEN 'WAP'
            WHEN ORG_CLASS3='统一支付平台' THEN '网站'
            WHEN ORG_CLASS3='网上营业厅' THEN '网站'
            WHEN ORG_CLASS3='微信营业厅' THEN '网站'
            ELSE '其他渠道'
            END AS BASS1_CHLNAME,
      OP_ID
      FROM
 TMP_DIM_BASS1_CHANNEL_OP_INFO_20150415 ) B ON A.OP_ID=B.OP_ID;








