CREATE TABLE useraction (
  id int(11) NOT NULL auto_increment,
  SUB_ID varchar(20) default NULL,
  S_NAME varchar(500) default NULL,
  S_SEX varchar(10) default NULL,
  S_AGE INTEGER default NULL,
  S_ACTION varchar(600) default NULL,
  S_A_TIME varchar(20) default NULL,
  PRIMARY KEY  (id),
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

create table useraction
(
  id int  auto_increment primary key,
  SUB_ID varchar(20) ,
  S_NAME varchar(500) ,
  S_SEX varchar(10) ,
  S_AGE INTEGER ,
  S_ACTION varchar(600) ,
  S_A_TIME varchar(20)
);
ALTER TABLE useraction ADD INDEX keywords (id);
insert into useraction(SUB_ID,S_NAME,S_SEX,S_AGE,S_ACTION,S_A_TIME) values
('1140236','上海仁恒房地产有限公司','zh_CN',1140236,'欢迎  上海仁恒房地产有限公司！','20110409')


