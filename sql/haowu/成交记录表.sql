ALTER TABLE client_deal_record ADD build_no VARCHAR(20);
ALTER TABLE client_deal_record ADD room_no VARCHAR(20);
update client_deal_record set build_no=substring_index(substring_index(deal_room_num, '（幢）', 1),'幢',1)
, room_no= substring_index(substring_index(deal_room_num, '幢', -1), '室', 1) where deal_room_num is not null;