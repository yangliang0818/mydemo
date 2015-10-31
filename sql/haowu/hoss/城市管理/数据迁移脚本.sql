--海外城市sys_zone迁移脚本
UPDATE sys_zone sz JOIN php_zone pz
    ON sz.id = pz.id
SET sz.zone_name      = pz.zone_name,
  sz.zone_english     = pz.zone_english,
  sz.zone_order       = pz.zone_order,
  sz.zone_status      = pz.zone_status,
  sz.zone_description = pz.zone_description,
  sz.center_name      = pz.center_name,
  sz.center_x         = pz.center_x,
  sz.center_y         = pz.center_y
WHERE sz.id = 85;
INSERT INTO sys_zone (id, creater, create_time, version, parent_id, zone_name, zone_english, zone_order, zone_status, zone_description, zone_time, center_name, center_x, center_y)
  SELECT
    pz.id,
    -1,
    now(),
    0,
    pz.parent_id,
    pz.zone_name,
    pz.zone_english,
    pz.zone_order,
    pz.zone_status,
    pz.zone_description,
    pz.zone_time,
    pz.center_name,
    pz.center_x,
    pz.center_y
  FROM php_zone pz LEFT JOIN sys_zone sz ON pz.id = sz.id
  WHERE sz.id IS NULL AND pz.parent_id <> 0;

--板块sys_plate迁移脚本
INSERT INTO sys_plate (id, creater, create_time, version, area_id, name, plate_order, plate_statue, description, cooperate)
  SELECT
    pp.id,
    -1,
    now(),
    0,
    pp.parent_id,
    pp.name,
    pp.order,
    pp.statue,
    pp.description,
    1
  FROM php_plate pp LEFT JOIN sys_plate sp ON pp.id = sp.id
  WHERE sp.id IS NULL;

--楼盘houses迁移脚本
UPDATE houses
SET status = if(status IN (1, 2), 1, if(status = 3, 2, status));

INSERT INTO houses (id, creater, create_time, version, city_id, area_id, address, deliver_date,
                    developer_name, house_property, name, sale_start_at, status, house_price, house_favourable,
                    house_pic, house_youhui, app_tuijian, house_bj, house_total, haiwai_country, haiwai_city,
                    plate_id, house_type, haiwai_total, house_fs, house_shangjia, house_fs_time_from,
                    house_fs_time_to, house_lon, house_lat)
  SELECT
    ph.house_id                                                                AS id,
    -1                                                                         AS creater,
    now()                                                                      AS create_time,
    0                                                                          AS version,
    ph.house_city                                                              AS city_id,
    house_area                                                                 AS area_id,
    ph.house_address                                                           AS address,
    date_format(phi.info_checktime, '%Y-%c-%d %H:%i:%s')                       AS deliver_date,
    ph.house_developers                                                        AS developer_name,
    ph.house_property                                                          AS house_property,
    ph.house_name                                                              AS name,
    phi.info_opentime                                                          AS sale_start_at,
    if(ph.house_state IN (1, 2), 1, if(ph.house_state = 3, 2, ph.house_state)) AS status,
    ph.house_price                                                             AS house_price,
    ph.house_features                                                          AS house_favourable,
    ph.house_pic                                                               AS house_pic,
    ph.house_youhui                                                            AS house_youhui,
    pha.app_tuijian                                                            AS app_tuijian,
    pha.house_bj                                                               AS house_bj,
    ph.house_total                                                             AS house_total,
    ph.haiwai_country                                                          AS haiwai_country,
    ph.haiwai_city                                                             AS haiwai_city,
    ph.house_plate                                                             AS plate_id,
    ph.house_type                                                              AS house_type,
    ph.haiwai_total                                                            AS haiwai_total,
    ph.house_fs                                                                AS house_fs,
    ph.house_shangjia                                                          AS house_shangjia,
    pha.house_fs_time_from                                                     AS house_fs_time_from,
    pha.house_fs_time_to                                                       AS house_fs_time_to,
    ph.house_y                                                                 AS house_lon,
    ph.house_x                                                                 AS house_lat
  FROM php_house ph LEFT JOIN houses h ON ph.house_id = h.id
    LEFT JOIN php_house_info phi ON ph.house_id = phi.house_id
    LEFT JOIN php_house_app pha ON ph.house_id = pha.house_id
  WHERE h.id IS NULL;

--楼盘扩展信息脚本
INSERT INTO houses_extend (creater, create_time, version, houses_id, schedule,
                           country_id, province_id, business_circles_id,
                           on_park_space, owner_ship_type, hot_line, info_decoration, plot_ratio, green_rate,
                           house_hold_count, pmc_fee, pmc_name, house_introduction, comments)
  SELECT
    -1                    AS creater,
    now()                 AS create_time,
    0                     AS version,
    pa.house_id           AS houses_id,
    0                     AS schedule,
    0                     AS country_id,
    sp.id                 AS province_id,
    pa.house_plate        AS business_circles_id,
    phi.info_parking      AS on_park_space,
    pa.house_cq           AS owner_ship_type,
    phi.info_hotline      AS hot_line,
    phi.info_decoration   AS info_decoration,
    phi.info_ratio        AS plot_ratio,
    phi.info_greeningrate AS green_rate,
    phi.info_planning     AS house_hold_count,
    phi.info_fees         AS pmc_fee,
    phi.info_company      AS pmc_name,
    pa.house_description  AS house_introduction,
    phi.info_other        AS comments
  FROM php_house pa LEFT JOIN php_house_info phi ON pa.house_id = phi.house_id
    LEFT JOIN sys_city sc ON sc.id = pa.house_city
    LEFT JOIN sys_province sp ON sp.id = sc.province_id;
--楼盘户型