USE [AAD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  OBJECT_ID(N'tempdb.[dbo].[#tmp_location]') IS NOT NULL
	BEGIN
		DROP TABLE [dbo].[#tmp_location]
	END

CREATE TABLE #tmp_location(
    [wh_id] [nvarchar](10),
	[pick_area] [nvarchar](10),
	[zone] [nvarchar](10),
	[location_id] [nvarchar](50),
	[type] [nvarchar](3),
	[length] [float],
	[width] [float],
	[height] [float],
	[picking_flow] [nvarchar](10),
	[class_id] [nvarchar](10),
	[item_hu_indicator] [nchar](1)
	);

BEGIN TRY
	BEGIN TRANSACTION
		PRINT 'BULK INSERT #tmp_location'
		BULK INSERT #tmp_location
		FROM 'D:\Deploy\MSSQL-2741.csv'
		WITH
		(
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'
		)


--Fix leading zero padding for picking_flow
UPDATE #tmp_location
SET picking_flow = RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10), #tmp_location.[picking_flow]), 10)

		--backup
		--records to be updated
		PRINT 'backup locations to be updated'
		select distinct l.wh_id, l.location_id, l.picking_flow, l.zone, l.pick_area, l.type, l.allow_bulk_pick, l.length, l.width, l.height, l.item_hu_indicator
		into tmp_t_location_mssql_2741
		from t_location l
		join #tmp_location on l.wh_id = #tmp_location.wh_id and l.location_id = #tmp_location.location_id

		--records to be inserted
		PRINT 'backup zones to be inserted'
		select distinct #tmp_location.wh_id, UPPER(#tmp_location.zone) [zone]
		into tmp_t_zone_mssql_2741
		from #tmp_location
		left join t_zone on #tmp_location.wh_id = t_zone.wh_id and UPPER(#tmp_location.zone) = t_zone.zone
		where t_zone.zone is NULL and t_zone.wh_id is NULL

		PRINT 'backup pick areas to be inserted'
		select distinct #tmp_location.wh_id, UPPER(#tmp_location.pick_area) [pick_area]
		into tmp_t_pick_area_mssql_2741
		from #tmp_location
		left join t_pick_area on #tmp_location.wh_id = t_pick_area.wh_id and UPPER(#tmp_location.pick_area) = t_pick_area.pick_area
		where t_pick_area.pick_area is NULL and t_pick_area.wh_id is NULL

		PRINT 'backup locations to be inserted'
		select #tmp_location.wh_id, #tmp_location.location_id, #tmp_location.picking_flow
		into tmp_t_location_mssql_2741b
		from #tmp_location
		left join t_location on #tmp_location.wh_id = t_location.wh_id and #tmp_location.location_id = t_location.location_id
		where t_location.location_id is NULL

		PRINT 'backup location zones to be inserted'
		SELECT DISTINCT #tmp_location.wh_id, UPPER(#tmp_location.zone) [zone], #tmp_location.[location_id]
		INTO tmp_t_zone_loca_mssql_2741
		FROM #tmp_location
		LEFT JOIN t_zone_loca tzl ON #tmp_location.wh_id = tzl.wh_id AND #tmp_location.[location_id] = tzl.location_id AND UPPER(#tmp_location.zone) = tzl.zone
		WHERE tzl.location_id IS NULL AND tzl.wh_id IS NULL AND tzl.zone IS NULL;

		PRINT 'backup location zones "ALL" to be inserted'
		INSERT INTO tmp_t_zone_loca_mssql_2741
			(wh_id, zone, location_id)
		SELECT DISTINCT #tmp_location.wh_id, 'ALL', #tmp_location.[location_id]
		FROM #tmp_location
		LEFT JOIN t_zone_loca tzl ON #tmp_location.wh_id = tzl.wh_id AND #tmp_location.[location_id] = tzl.location_id AND tzl.zone = 'ALL'
		WHERE tzl.location_id IS NULL AND tzl.wh_id IS NULL AND tzl.zone IS NULL;

		PRINT 'backup classes to be inserted'
	 	SELECT DISTINCT #tmp_location.wh_id, #tmp_location.class_id
		INTO tmp_t_class_mssql_2741
		FROM #tmp_location
		LEFT JOIN t_class tc ON #tmp_location.wh_id = tc.wh_id AND #tmp_location.class_id = tc.class_id
		WHERE tc.wh_id IS NULL AND tc.class_id IS NULL;

		PRINT 'backup location class to be inserted'
		SELECT DISTINCT #tmp_location.wh_id, #tmp_location.class_id, #tmp_location.[location_id]
		INTO tmp_t_class_loca_mssql_2741
		FROM #tmp_location
		LEFT JOIN t_class_loca tcl ON #tmp_location.wh_id = tcl.wh_id AND #tmp_location.[location_id] = tcl.location_id AND #tmp_location.class_id = tcl.class_id
		WHERE tcl.location_id IS NULL AND tcl.wh_id IS NULL AND tcl.class_id IS NULL;

----Saved for when we need to insert the picking flow somewhere other than at the end of the existing flow
DECLARE @shift_offset int;

SET @shift_offset = (SELECT COUNT(1)+1 FROM #tmp_location);

PRINT 'shift picking flow out (if needed)'
update t_location
	SET picking_flow = picking_flow + @shift_offset
FROM t_location
where (wh_id = (select top 1 wh_id from #tmp_location) 
	and picking_flow >= (SELECT MIN(picking_flow) FROM #tmp_location WHERE wh_id = (select top 1 wh_id from #tmp_location)))

--insert missing zone(s)
PRINT 'insert missing zones (if any)'
INSERT INTO [dbo].[t_zone]
           ([wh_id]
           ,[zone]
           ,[description])
 	SELECT distinct #tmp_location.wh_id, UPPER(#tmp_location.zone), #tmp_location.zone
		FROM #tmp_location
		LEFT JOIN [t_zone] ON #tmp_location.wh_id = [t_zone].wh_id AND UPPER(#tmp_location.zone) = [t_zone].zone
		WHERE [t_zone].wh_id IS NULL AND [t_zone].zone IS NULL;

--insert missing pick area(s)
PRINT 'insert missing pick areas (if any)'
INSERT INTO [dbo].[t_pick_area]
           ([pick_area]
           ,[wh_id]
           ,[pick_area_type]
           ,[target_pick_percent]
           ,[work_type]
           ,[description]
           ,[container_class]
           ,[default_printer]
           ,[premanifest_flag]
           ,[wh_code])
 	SELECT distinct UPPER(#tmp_location.pick_area), #tmp_location.wh_id, 'R', 0, '04', #tmp_location.pick_area, NULL, NULL, 'N', IIF(#tmp_location.wh_id = 'WSL', 1, IIF(#tmp_location.wh_id = '3PL', 7, IIF(#tmp_location.wh_id = 'CPA', 8, IIF(#tmp_location.wh_id = 'WKC', 9, NULL))))
		FROM #tmp_location
		LEFT JOIN t_pick_area ON #tmp_location.wh_id = t_pick_area.wh_id AND UPPER(#tmp_location.pick_area) = t_pick_area.pick_area
		WHERE t_pick_area.wh_id IS NULL AND t_pick_area.pick_area IS NULL;

PRINT 'update t_location'
	UPDATE t_location
	SET picking_flow = #tmp_location.[picking_flow], zone = UPPER(#tmp_location.zone), pick_area = UPPER(#tmp_location.pick_area), type = #tmp_location.type, allow_bulk_pick = 'YES', length = #tmp_location.length, width = #tmp_location.width, height = #tmp_location.height, item_hu_indicator = #tmp_location.item_hu_indicator
	FROM t_location
	JOIN #tmp_location on t_location.wh_id = #tmp_location.wh_id 
		and t_location.location_id = #tmp_location.location_id

	--insert missing locations 
	PRINT 'insert missing locations (if any)'
		INSERT INTO t_location
		(wh_id, location_id, [description], short_location_id, [status], zone, picking_flow, capacity_uom, capacity_qty, stored_qty, [type], fifo_date, cycle_count_class, last_count_date, last_physical_date, user_count, capacity_volume
			, time_between_maintenance, last_maintained, length, width, height, replenishment_location_id, pick_area, allow_bulk_pick, slot_rank, slot_status, item_hu_indicator, c1, c2, c3, random_cc, x_coordinate, y_coordinate, z_coordinate
			, storage_device_id, space_calc_unit)
		SELECT #tmp_location.wh_id, #tmp_location.location_id, null, null, 'E',MIN(UPPER(#tmp_location.[zone])), MIN(#tmp_location.[picking_flow]), 'EA', '0', '0', MIN(UPPER(#tmp_location.[type]))
			, '1900-01-01 00:00:00.000', '1', GETDATE(), GETDATE(), '0', '0', '0',null, MIN(#tmp_location.length), MIN(#tmp_location.width), MIN(#tmp_location.height), null, MIN(UPPER(#tmp_location.[pick_area])), 'NO', null, null, MIN(#tmp_location.item_hu_indicator), null, null, null
			, '0', null, null, null, null, 'CUBE'
			from #tmp_location
			left join t_location on #tmp_location.wh_id = t_location.wh_id and #tmp_location.location_id = t_location.location_id
			where t_location.location_id is NULL
			GROUP BY #tmp_location.wh_id, #tmp_location.location_id;

	PRINT 'insert missing location zones "ALL" (if any)'
	INSERT INTO t_zone_loca
		(wh_id, zone, location_id, pick_seq)
		SELECT DISTINCT #tmp_location.wh_id, 'ALL', #tmp_location.[location_id], '000'
		FROM #tmp_location
		LEFT JOIN t_zone_loca tzl ON #tmp_location.wh_id = tzl.wh_id AND #tmp_location.[location_id] = tzl.location_id AND tzl.zone = 'ALL'
		WHERE tzl.location_id IS NULL AND tzl.wh_id IS NULL AND tzl.zone IS NULL;

	PRINT 'insert missing locations zones (if any)'
	INSERT INTO t_zone_loca
		(wh_id, zone, location_id, pick_seq)
		SELECT DISTINCT #tmp_location.wh_id, UPPER(#tmp_location.zone), #tmp_location.[location_id], '000'
		FROM #tmp_location
		LEFT JOIN t_zone_loca tzl ON #tmp_location.wh_id = tzl.wh_id AND #tmp_location.[location_id] = tzl.location_id AND UPPER(#tmp_location.zone) = tzl.zone
		WHERE tzl.location_id IS NULL AND tzl.wh_id IS NULL AND tzl.zone IS NULL;

	PRINT 'insert missing classes (if any)'
	INSERT INTO t_class
		(wh_id, class_id, target_put_percent)
		SELECT DISTINCT #tmp_location.wh_id, #tmp_location.class_id, 0
		FROM #tmp_location
		LEFT JOIN t_class tc ON #tmp_location.wh_id = tc.wh_id AND #tmp_location.class_id = tc.class_id
		WHERE tc.wh_id IS NULL AND tc.class_id IS NULL;

	PRINT 'insert missing location classes (if any)'
	INSERT INTO t_class_loca
		(wh_id, class_id, location_id, fill_seq)
		SELECT DISTINCT #tmp_location.wh_id, #tmp_location.class_id, #tmp_location.[location_id], 'N'
		FROM #tmp_location
		LEFT JOIN t_class_loca tcl ON #tmp_location.wh_id = tcl.wh_id AND #tmp_location.[location_id] = tcl.location_id AND #tmp_location.class_id = tcl.class_id
		WHERE tcl.location_id IS NULL AND tcl.wh_id IS NULL AND tcl.class_id IS NULL;

	PRINT 'insert missing wave control (if any)'
	INSERT INTO [dbo].[t_wave_control_ostk]
		([wh_id]
		,[pick_area]
		,[pick_span]
		,[sequence]
		,[style_limit]
		,[single_limit]
		,[status]
		,[priority])
	SELECT distinct #tmp_location.wh_id, UPPER(#tmp_location.pick_area), 'P' ,17 ,NULL ,5 ,'A' ,'10'
		FROM #tmp_location
		LEFT JOIN [t_wave_control_ostk] ON #tmp_location.wh_id = [t_wave_control_ostk].wh_id AND UPPER(#tmp_location.pick_area) = [t_wave_control_ostk].pick_area
		WHERE [t_wave_control_ostk].wh_id IS NULL AND [t_wave_control_ostk].pick_area IS NULL;

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	--PRINT 'An Error Occurred in the script'
	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
		,ERROR_SEVERITY() AS ErrorSeverity  
		,ERROR_STATE() AS ErrorState  
		,ERROR_PROCEDURE() AS ErrorProcedure  
		,ERROR_LINE() AS ErrorLine  
		,ERROR_MESSAGE() AS ErrorMessage;  
	ROLLBACK TRANSACTION
END CATCH

DROP TABLE #tmp_location