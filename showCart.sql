/*
showCart: displays all information regarding the current status of a cart in the database

2021.10.14  anthon.hall created
2021.10.18	anthon.hall	added sorting to t_order and t_pick_detail
*/

USE AAD
DECLARE @cart NVARCHAR(22)
SET @cart = 'PCRTK9' -- Change this value to what warehouse tech gives you.

--common errors are checked here
DECLARE
		@out_sys_shortmsg NVARCHAR(20)
	,	@out_deadlock_flag INT
	,	@out_ice_station_flag INT
	,	@in_wh_id	NVARCHAR(10)	= 'VRN1'
	,	@in_cart_id NVARCHAR(22) = @cart
	,	@in_device_id NVARCHAR(100) = ''
	,	@in_employee_id NVARCHAR(100) = ''
	,	@in_zone_pick_type NVARCHAR(10) = 'NONE'
	,	@in_debug INT = 0
	;
SELECT @in_zone_pick_type = CASE LEFT(@in_cart_id,4) WHEN 'BCRT' THEN 'PRODUCE' ELSE 'NONE' END
EXEC [dbo].[usp_pbc_ice_check]
		@in_tran_type				= ''
	,	@in_wh_id					= @in_wh_id
	,	@in_employee_id				= ''
	,	@in_device_id				= @in_device_id
	,	@in_fork_id					= @in_employee_id
	,	@in_calling_procedure		= ''
	,	@out_sys_shortmsg			= @out_sys_shortmsg		OUTPUT
	,	@out_deadlock_flag 		= @out_deadlock_flag	OUTPUT
	,	@in_cart_id					= @in_cart_id
	,	@in_zone_pick_type			= @in_zone_pick_type
	,	@out_ice_station_flag		= @out_ice_station_flag	OUTPUT
	,	@in_debug					= @in_debug
;
SELECT @out_sys_shortmsg, @out_deadlock_flag, @out_ice_station_flag

  
SELECT
    pkd.wh_id
  ,	hum.parent_hu_id
  ,	hum.hu_id
  ,	CASE WHEN ISNULL(cls.ice_item_number,'') <> '' THEN 1 ELSE 0 END
  ,	MAX(ISNULL(hum.ice_flag,0)) -- carton is iced.
  ,	pkd.item_number
  ,	ISNULL(itm.needs_sleeve,0)
  ,	MAX(ISNULL(sto.sleeve_flag,0)) -- item is sleeved
  ,	pkd.[status]
  ,	sto.sto_id
FROM usf_get_pick_container_info ('VRN1', NULL, 'NONE') pkd	--NCC 20210902 Use a function to get the necessary table information
--FROM AAD.dbo.t_pick_detail AS [pkd] WITH(NOLOCK)
INNER JOIN AAD.dbo.t_hu_master AS [hum] WITH(NOLOCK)
  ON	hum.hu_id = pkd.container_id
  AND hum.wh_id = pkd.wh_id
INNER JOIN AAD.dbo.t_item_master AS [itm] WITH(NOLOCK)
  ON	itm.item_number = pkd.item_number
  AND	itm.wh_id = pkd.wh_id
INNER JOIN AAD.dbo.t_class AS [cls] WITH(NOLOCK)
  ON	cls.class_id = itm.class_id
  AND cls.wh_id = itm.wh_id
LEFT OUTER JOIN AAD.dbo.t_stored_item AS [sto] WITH(NOLOCK)		-- need to use OUTER join since we also want to consider RELEASED picks.
  ON	sto.[type] = pkd.pick_id
WHERE	--hum.parent_hu_id = @in_cart_id
    hum.wh_id = @in_wh_id						-- either:
    AND hum.parent_hu_id = @in_cart_id
    AND  (	( ISNULL(itm.needs_sleeve,0) = 1 )			-- needs a sleeve
    OR	( ISNULL(cls.ice_item_number, '')  <> '')
    )	-- needs carton
  /*edward.moreno 2021.05.25
  don't restrict on pkd.status. We have to care about two exception paths. either:
    A) picks are on CART despite being in some status other than PICKED.
      In which case we want to send the user to the ice station.
    B) picks are not on CART and in a status other than PICKED.
      In which case we DO NOT send the user to the ice station.

  so instead of filtering on status, we need to filter on pkd.status + sto.sto_id (exists on cart/picked)

  if an item is on the cart that is not one of its picks, then it will not be considered as a part of this logic.
  something has really gone wrong if this occurs.
  -- AND pkd.[status] IN ('RELEASED', 'PICKED')
  */
GROUP BY
    pkd.wh_id
  ,	hum.parent_hu_id
  ,	hum.hu_id
  ,	pkd.item_number
  ,	pkd.[status]
  ,	itm.needs_sleeve
  ,	cls.ice_item_number
  ,	sto.sto_id
ORDER BY
    hum.parent_hu_id
  ,	pkd.wh_id
;

--table relations are checked here
select DISTINCT [hum].[parent_hu_id]
	, [hum].[control_number] [hum.control_number]
	, [orm].[order_number] [orm.order_number]
	, [pkd].[order_number] [pkd.order_number]
	, [od].[order_number] [od.order_number]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
LEFT JOIN AAD.dbo.t_order AS [orm] WITH(NOLOCK) 
	ON 	orm.order_number =  hum.control_number
	AND orm.wh_id = hum.wh_id
LEFT JOIN AAD.dbo.t_pick_detail AS [pkd] WITH(NOLOCK) 
	ON 	pkd.order_number =  hum.control_number
	AND pkd.wh_id = hum.wh_id
LEFT JOIN AAD.dbo.[t_order_detail] AS [od] WITH(NOLOCK) 
	ON 	od.order_number =  hum.control_number
	AND od.wh_id = hum.wh_id

WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart

--raw data goes here
SELECT DISTINCT 't_hu_master' [table]
      ,[parent_hu_id]
	  ,[hu_id]
      ,[type]
      ,[control_number]
      ,[location_id]
      ,[subtype]
      ,[status]
      ,[fifo_date]
      ,[wh_id]
      ,[load_position]
      ,[haz_material]
      ,[load_id]
      ,[load_seq]
      ,[ver_flag]
      ,[zone]
      ,[reserved_for]
      ,[container_type]
      ,[stop_id]
      ,[user_id]
      ,[dwell_start]
      ,[sell_by_date]
      ,[length]
      ,[width]
      ,[height]
      ,[box_type]
      ,[po_number]
      ,[po_line_number]
      ,[ice_flag]
      ,[last_qa_check]
      ,[qa_check_needed]
      ,[last_tran_date]
      ,[last_cc_date]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart


SELECT DISTINCT 't_order' [table]
	  ,orm.[order_id]
      ,orm.[wh_id]
      ,orm.[order_number]
      ,orm.[store_order_number]
      ,orm.[type_id]
      ,orm.[customer_id]
      ,orm.[cust_po_number]
      ,orm.[customer_name]
      ,orm.[customer_phone]
      ,orm.[customer_fax]
      ,orm.[customer_email]
      ,orm.[department]
      ,orm.[load_id]
      ,orm.[load_seq]
      ,orm.[bol_number]
      ,orm.[pro_number]
      ,orm.[master_bol_number]
      ,orm.[carrier]
      ,orm.[carrier_scac]
      ,orm.[freight_terms]
      ,orm.[rush]
      ,orm.[priority]
      ,orm.[order_date]
      ,orm.[arrive_date]
      ,orm.[actual_arrival_date]
      ,orm.[date_picked]
      ,orm.[date_expected]
      ,orm.[promised_date]
      ,orm.[weight]
      ,orm.[cubic_volume]
      ,orm.[containers]
      ,orm.[backorder]
      ,orm.[pre_paid]
      ,orm.[cod_amount]
      ,orm.[insurance_amount]
      ,orm.[pip_amount]
      ,orm.[freight_cost]
      ,orm.[region]
      ,orm.[bill_to_code]
      ,orm.[bill_to_name]
      ,orm.[bill_to_addr1]
      ,orm.[bill_to_addr2]
      ,orm.[bill_to_addr3]
      ,orm.[bill_to_city]
      ,orm.[bill_to_state]
      ,orm.[bill_to_zip]
      ,orm.[bill_to_country_code]
      ,orm.[bill_to_country_name]
      ,orm.[bill_to_phone]
      ,orm.[ship_to_code]
      ,orm.[ship_to_name]
      ,orm.[ship_to_addr1]
      ,orm.[ship_to_addr2]
      ,orm.[ship_to_addr3]
      ,orm.[ship_to_city]
      ,orm.[ship_to_state]
      ,orm.[ship_to_zip]
      ,orm.[ship_to_country_code]
      ,orm.[ship_to_country_name]
      ,orm.[ship_to_phone]
      ,orm.[ship_to_ein]
      ,orm.[delivery_name]
      ,orm.[delivery_addr1]
      ,orm.[delivery_addr2]
      ,orm.[delivery_addr3]
      ,orm.[delivery_city]
      ,orm.[delivery_state]
      ,orm.[delivery_zip]
      ,orm.[delivery_country_code]
      ,orm.[delivery_country_name]
      ,orm.[delivery_phone]
      ,orm.[bill_frght_to_code]
      ,orm.[bill_frght_to_name]
      ,orm.[bill_frght_to_addr1]
      ,orm.[bill_frght_to_addr2]
      ,orm.[bill_frght_to_addr3]
      ,orm.[bill_frght_to_city]
      ,orm.[bill_frght_to_state]
      ,orm.[bill_frght_to_zip]
      ,orm.[bill_frght_to_country_code]
      ,orm.[bill_frght_to_country_name]
      ,orm.[bill_frght_to_phone]
      ,orm.[return_to_code]
      ,orm.[return_to_name]
      ,orm.[return_to_addr1]
      ,orm.[return_to_addr2]
      ,orm.[return_to_addr3]
      ,orm.[return_to_city]
      ,orm.[return_to_state]
      ,orm.[return_to_zip]
      ,orm.[return_to_country_code]
      ,orm.[return_to_country_name]
      ,orm.[return_to_phone]
      ,orm.[appointment_number]
      ,orm.[appointment_status]
      ,orm.[scheduled_location]
      ,orm.[scheduled_start]
      ,orm.[scheduled_duration]
      ,orm.[rma_number]
      ,orm.[rma_expiration_date]
      ,orm.[carton_label]
      ,orm.[ver_flag]
      ,orm.[full_pallets]
      ,orm.[haz_flag]
      ,orm.[order_wgt]
      ,orm.[status]
      ,orm.[zone]
      ,orm.[drop_ship]
      ,orm.[lock_flag]
      ,orm.[partial_order_flag]
      ,orm.[earliest_ship_date]
      ,orm.[latest_ship_date]
      ,orm.[actual_ship_date]
      ,orm.[earliest_delivery_date]
      ,orm.[latest_delivery_date]
      ,orm.[actual_delivery_date]
      ,orm.[route]
      ,orm.[baseline_rate]
      ,orm.[planning_rate]
      ,orm.[carrier_id]
      ,orm.[manifest_carrier_id]
      ,orm.[ship_via_id]
      ,orm.[display_order_number]
      ,orm.[client_code]
      ,orm.[ship_to_residential_flag]
      ,orm.[carrier_mode]
      ,orm.[service_level]
      ,orm.[ship_to_attention]
      ,orm.[earliest_appt_time]
      ,orm.[latest_appt_time]
      ,orm.[image_entity_item_id]
      ,orm.[order_type]
      ,orm.[updated_date_time]
      ,orm.[is_gift]
      ,orm.[gift_recipient_name]
      ,orm.[cutoff_date_time]
      ,orm.[customer_first_name]
      ,orm.[customer_last_name]
      ,orm.[host_status]
      ,orm.[error_msg]
      ,orm.[cartonization_job_id]
      ,orm.[release_relpen_date]
      ,orm.[release_prep_date]
      ,orm.[release_pick_date]
      ,orm.[is_will_call]
      ,orm.[retry_cartonize]
      ,orm.[retry_cartonize_datetime]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
INNER JOIN AAD.dbo.t_order AS [orm] WITH(NOLOCK) 
	ON 	orm.order_number =  hum.control_number
	AND orm.wh_id = hum.wh_id
WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart
ORDER BY order_id

SELECT DISTINCT 't_pick_detail' [table]
-- sorted fields we definately want to see
      ,pkd.[user_assigned]
      ,pkd.[status]
      ,pkd.[pick_location]
      ,pkd.[container_id]
      ,pkd.[sub_container_id]
      ,pkd.[container_type]
-- everything else
   --	,pkd.[pick_id]
   --   ,pkd.[order_number]
   --   ,pkd.[line_number]
   --   ,pkd.[type]
   --   ,pkd.[uom]
   --   ,pkd.[work_q_id]
   --   ,pkd.[work_type]
   --   ,pkd.[item_number]
   --   ,pkd.[lot_number]
   --   ,pkd.[unplanned_quantity]
   --   ,pkd.[planned_quantity]
   --   ,pkd.[picked_quantity]
   --   ,pkd.[staged_quantity]
   --   ,pkd.[loaded_quantity]
   --   ,pkd.[packed_quantity]
   --   ,pkd.[shipped_quantity]
   --   ,pkd.[staging_location]
   --   ,pkd.[zone]
   --   ,pkd.[wave_id]
   --   ,pkd.[load_id]
   --   ,pkd.[load_sequence]
   --   ,pkd.[stop_id]
   --   ,pkd.[pick_category]
   --   ,pkd.[bulk_pick_flag]
   --   ,pkd.[stacking_sequence]
   --   ,pkd.[pick_area]
   --   ,pkd.[wh_id]
   --   ,pkd.[cartonization_batch_id]
   --   ,pkd.[manifest_batch_id]
   --   ,pkd.[stored_attribute_id]
   --   ,pkd.[create_date]
   --   ,pkd.[before_pick_rule]
   --   ,pkd.[during_pick_rule]
   --   ,pkd.[hold_reason_id]
   --   ,pkd.[pick_run]
   --   ,pkd.[pick_loc_exp_date]
   --   ,pkd.[priority]
   --   ,pkd.[previous_pick_id]
   --   ,pkd.[pick_datetime]
   --   ,pkd.[pick_loc_change_datetime]
   --   ,pkd.[inserted_datetime]
   --   ,pkd.[cartonization_pick_id]
   --   ,pkd.[rls_prep_date]
   --   ,pkd.[rls_rpln_date]
   --   ,pkd.[rls_pick_date]
   --   ,pkd.[zone_pick_type]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
JOIN AAD.dbo.t_pick_detail AS [pkd] WITH(NOLOCK) 
	ON 	pkd.order_number =  hum.control_number
	AND pkd.wh_id = hum.wh_id
WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart
ORDER BY container_type

SELECT DISTINCT 't_stored_item' [table]
-- sorted fields we definately want to see
	  ,[sto].[hu_id]
      ,[sto].[location_id]

	  --,[sto].[sto_id]
   --   ,[sto].[sequence]
   --   ,[sto].[item_number]
   --   ,[sto].[actual_qty]
   --   ,[sto].[unavailable_qty]
   --   ,[sto].[status]
   --   ,[sto].[wh_id]
   --   ,[sto].[fifo_date]
   --   ,[sto].[expiration_date]
   --   ,[sto].[reserved_for]
   --   ,[sto].[lot_number]
   --   ,[sto].[inspection_code]
   --   ,[sto].[type]
   --   ,[sto].[put_away_location]
   --   ,[sto].[stored_attribute_id]
   --   ,[sto].[shipment_number]
   --   ,[sto].[po_number]
   --   ,[sto].[po_line]
   --   ,[sto].[ice_flag]
   --   ,[sto].[sleeve_flag]
   --   ,[sto].[po_line_unit_cost]
   --   ,[sto].[freeze_flag]
   --   ,[sto].[entered_date]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
JOIN AAD.dbo.[t_stored_item] AS [sto] WITH(NOLOCK) 
	ON 	sto.hu_id =  hum.hu_id
	AND sto.wh_id = hum.wh_id
WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart

SELECT DISTINCT 't_order_detail' [table]
-- sorted fields we definately want to see
      ,[od].[item_number]


	  --,[od].[order_detail_id]
   --   ,[od].[order_id]
   --   ,[od].[item_master_id]
   --   ,[od].[wh_id]
   --   ,[od].[order_number]
   --   ,[od].[line_number]
   --   ,[od].[bo_qty]
   --   ,[od].[bo_description]
   --   ,[od].[bo_weight]
   --   ,[od].[qty]
   --   ,[od].[afo_plan_qty]
   --   ,[od].[unit_pack]
   --   ,[od].[item_weight]
   --   ,[od].[item_tare_weight]
   --   ,[od].[haz_material]
   --   ,[od].[b_o_l_class]
   --   ,[od].[b_o_l_line1]
   --   ,[od].[b_o_l_line2]
   --   ,[od].[b_o_l_line3]
   --   ,[od].[b_o_l_plac_code]
   --   ,[od].[b_o_l_plac_desc]
   --   ,[od].[b_o_l_code]
   --   ,[od].[qty_shipped]
   --   ,[od].[line_type]
   --   ,[od].[item_description]
   --   ,[od].[stacking_seq]
   --   ,[od].[cust_part]
   --   ,[od].[lot_number]
   --   ,[od].[picking_flow]
   --   ,[od].[unit_weight]
   --   ,[od].[unit_volume]
   --   ,[od].[extended_weight]
   --   ,[od].[extended_volume]
   --   ,[od].[over_alloc_qty]
   --   ,[od].[date_expected]
   --   ,[od].[order_uom]
   --   ,[od].[host_wave_id]
   --   ,[od].[tran_plan_qty]
   --   ,[od].[use_shippable_uom]
   --   ,[od].[unit_insurance_amount]
   --   ,[od].[stored_attribute_id]
   --   ,[od].[hold_reason_id]
   --   ,[od].[short_priority]
   --   ,[od].[allow_subs]
   --   ,[od].[error_msg]
FROM AAD.dbo.t_hu_master AS [hum] WITH (NOLOCK)
JOIN AAD.dbo.[t_order_detail] AS [od] WITH(NOLOCK) 
	ON 	od.order_number =  hum.control_number
	AND od.wh_id = hum.wh_id
WHERE  
		hum.type = 'SO'
		AND parent_hu_id like @cart




--Select pkd.user_assigned, pkd.status, pkd.pick_location, pkd.container_id, pkd.sub_container_id, sto.hu_id, sto.location_id, hu.parent_hu_id,  *
--from t_hu_master hum WITH(NOLOCK)
--inner  join t_pick_detail pkd WITH(NOLOCK)
--	ON pkd.wh_id = hum.wh_id
--	AND pkd.container_id = hum.hu_id
--left outer join t_stored_item sto WITH(NOLOCK)
--	oN sto.wh_id = pkd.wh_id
--	AND sto.type = pkd.pick_id
--left outer join t_hu_master hu WITH(NOLOCK)
--	ON hu.wh_id = sto.wh_id
--	AND hu.hu_id = sto.hu_id
--WHERE hum.parent_hu_id like @cart

select uom.is_ship_alone, od.item_number, pkd.item_number, pkd.user_assigned, pkd.planned_quantity, *
from t_pick_detail pkd WITH(NOLOCK)
inner join t_order_detail od WITH(NOLOCK)
	ON od.wh_id = pkd.wh_id
	AND od.order_number = pkd.order_number
	AND od.line_number = pkd.line_number
inner join t_item_uom uom WITH(NOLOCK)
	ON uom.wh_id = pkd.wh_id
	AND uom.item_number = pkd.item_number
	AND uom.conversion_factor = 1
WHERE sub_container_id = '000000000000000005TIQI'

SELECT tran_type, description, end_tran_date+end_tran_time end_tran, source_hu_id, destination_hu_id, source_parent_hu_id, destination_parent_hu_id,source_location_id, destination_location_id, pick_id, outbound_order_number
FROM t_tran_log WITH(NOLOCK)
WHERE (source_hu_id = '000000000000000005S3D7'
		OR destination_hu_id = '000000000000000005S3D7')
ORDER BY tran_log_id desc

SELECT tran_type, description, end_tran_date+end_tran_time end_tran, source_hu_id, destination_hu_id, source_parent_hu_id, destination_parent_hu_id,source_location_id, destination_location_id, pick_id, outbound_order_number
FROM t_tran_log WITH(NOLOCK)
WHERE employee_id = '220027'
ORDER BY tran_log_id desc

