use AAD;

--rollback
PRINT 'restore locations'
update t_location
SET picking_flow = tmp_t_location_mssql_2741.picking_flow, zone = tmp_t_location_mssql_2741.zone, pick_area = tmp_t_location_mssql_2741.pick_area, type = tmp_t_location_mssql_2741.type, allow_bulk_pick = tmp_t_location_mssql_2741.allow_bulk_pick, length = tmp_t_location_mssql_2741.length, width = tmp_t_location_mssql_2741.width, height = tmp_t_location_mssql_2741.height, item_hu_indicator = tmp_t_location_mssql_2741.item_hu_indicator
	from t_location
join tmp_t_location_mssql_2741 on t_location.wh_id = tmp_t_location_mssql_2741.wh_id and t_location.location_id = tmp_t_location_mssql_2741.location_id

PRINT 'remove new location zones (if any)'
DELETE zl FROM t_zone_loca zl
	join tmp_t_zone_loca_mssql_2741 on zl.location_id = tmp_t_zone_loca_mssql_2741.location_id AND zl.[wh_id] = tmp_t_zone_loca_mssql_2741.[wh_id] AND zl.zone = tmp_t_zone_loca_mssql_2741.zone
  
PRINT 'remove new location classes (if any)'
DELETE cl FROM t_class_loca cl
	join tmp_t_class_loca_mssql_2741 on cl.location_id = tmp_t_class_loca_mssql_2741.location_id AND cl.[wh_id] = tmp_t_class_loca_mssql_2741.[wh_id] AND cl.class_id = tmp_t_class_loca_mssql_2741.class_id

PRINT 'remove new locations (if any)'
DELETE l FROM t_location l
	join tmp_t_location_mssql_2741b on l.location_id = tmp_t_location_mssql_2741b.location_id AND l.[wh_id] = tmp_t_location_mssql_2741b.[wh_id]

PRINT 'remove new wave control (if any)'
DELETE wc FROM t_wave_control_ostk wc
	join tmp_t_pick_area_mssql_2741 on wc.pick_area = tmp_t_pick_area_mssql_2741.pick_area AND wc.[wh_id] = tmp_t_pick_area_mssql_2741.[wh_id]

PRINT 'remove new pick areas (if any)'
DELETE pa FROM t_pick_area pa
	join tmp_t_pick_area_mssql_2741 on pa.pick_area = tmp_t_pick_area_mssql_2741.pick_area AND pa.[wh_id] = tmp_t_pick_area_mssql_2741.[wh_id]

PRINT 'remove new zones (if any)'
DELETE z FROM t_zone z
	join tmp_t_zone_mssql_2741 on z.zone = tmp_t_zone_mssql_2741.zone AND z.[wh_id] = tmp_t_zone_mssql_2741.[wh_id]

PRINT 'remove new classes (if any)'
DELETE c FROM t_class c
	join tmp_t_class_mssql_2741 on c.[wh_id] = tmp_t_class_mssql_2741.[wh_id] AND c.class_id = tmp_t_class_mssql_2741.class_id

--Saved for when we need to insert the picking flow somewhere other than at the end of the existing flow
PRINT 'shift picking flow back in (if needed)'

DECLARE @shift_offset int;
DECLARE @shift_start [nvarchar](10);

SET @shift_offset = (SELECT COUNT(1) FROM tmp_t_location_mssql_2741b) + (SELECT COUNT(1) FROM tmp_t_location_mssql_2741) + 1;
SET @shift_start = (
	SELECT MAX(picking_flow) FROM (
		select picking_flow from tmp_t_location_mssql_2741b
		union
		select picking_flow from tmp_t_location_mssql_2741
		) combined
	)

--PRINT '@shift_offset = ' + CAST(@shift_offset as varchar)
--PRINT '@shift_start = ' + @shift_start


update t_location
	SET picking_flow = picking_flow - @shift_offset
FROM t_location
--join tmp_t_location_mssql_2741b on t_location.wh_id = tmp_t_location_mssql_2741b.wh_id  and t_location.picking_flow = tmp_t_location_mssql_2741b.picking_flow
where wh_id = (select top 1 wh_id from (select distinct wh_id from tmp_t_location_mssql_2741
										union
										select distinct wh_id from tmp_t_location_mssql_2741b) combined)
	and picking_flow > @shift_start