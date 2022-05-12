USE AAD

DECLARE @route_id nvarchar(30)
SET @route_id = '82069095'

/*
select top 1 route_id, inserted_date
from t_route_master
where route_code like 'iD95'
order by inserted_date desc
*/

--select rtd.*
--from t_pick_detail pkd
--join t_route_detail rtd
--	on pkd.order_number = rtd.order_number
--WHERE	pkd.[status] NOT IN ('SHORTED', 'STAGED')

SELECT DISTINCT 't_message_log_inbound' [t_message_log_inbound]
	  ,[unique_id]
--      ,[route_assignment_error]

      ,[import_message]
      ,[date_inserted]
      ,[response]
      ,[date_processed]
      ,[message_id]
      ,[message_type]
      ,[environment]
  FROM [AAD].[dbo].[t_message_log_inbound]
  WHERE message_type = 'HOST_ORD_ROUTE_IMPORT'
    AND JSON_VALUE(import_message, '$.Message.Contents.OrderRoutes[0].RouteMaster.route_id') = @route_id
  ORDER BY date_inserted desc

SELECT DISTINCT 't_route_master' AS [t_route_master]
	  ,[wh_id]
      ,[route_id]
      ,[description]
      ,[notes]
      ,[scheduled_departure_start_date]
      ,[driver_name]
      ,[driver_email]
      ,[driver_phone]
      ,[status]
      ,[inserted_date]
      ,[type]
      ,[route_code]
      ,[door]
      ,[check_in_time]
      ,[check_in_notes]
      ,[rls_pick_date]
      ,[rls_rpln_date]
      ,[rls_prep_date]
      ,[route_assignment_error_datetime]
  FROM [dbo].[t_route_master]
WHERE route_id = @route_id

SELECT DISTINCT 't_route_detail' [t_route_detail]
	  ,[t_route_detail].[wh_id]
      ,[t_route_detail].[route_id]
      ,[order_number]
      ,[stop_sequence]
      ,[scheduled_arrival_date_time]
      ,[t_route_detail].[inserted_date]
      ,[pending_subcartonization]
  FROM [dbo].[t_route_detail]
WHERE route_id = @route_id

SELECT [order_id]
      ,[error_msg]
--important fields above
      ,t_order.[wh_id]
      ,t_order.[order_number]
      ,[store_order_number]
      ,[type_id]
      ,[customer_id]
      ,[cust_po_number]
      ,[customer_name]
      ,[customer_phone]
      ,[customer_fax]
      ,[customer_email]
      ,[department]
      ,[load_id]
      ,[load_seq]
      ,[bol_number]
      ,[pro_number]
      ,[master_bol_number]
      ,[carrier]
      ,[carrier_scac]
      ,[freight_terms]
      ,[rush]
      ,[priority]
      ,[order_date]
      ,[arrive_date]
      ,[actual_arrival_date]
      ,[date_picked]
      ,[date_expected]
      ,[promised_date]
      ,[weight]
      ,[cubic_volume]
      ,[containers]
      ,[backorder]
      ,[pre_paid]
      ,[cod_amount]
      ,[insurance_amount]
      ,[pip_amount]
      ,[freight_cost]
      ,[region]
      ,[bill_to_code]
      ,[bill_to_name]
      ,[bill_to_addr1]
      ,[bill_to_addr2]
      ,[bill_to_addr3]
      ,[bill_to_city]
      ,[bill_to_state]
      ,[bill_to_zip]
      ,[bill_to_country_code]
      ,[bill_to_country_name]
      ,[bill_to_phone]
      ,[ship_to_code]
      ,[ship_to_name]
      ,[ship_to_addr1]
      ,[ship_to_addr2]
      ,[ship_to_addr3]
      ,[ship_to_city]
      ,[ship_to_state]
      ,[ship_to_zip]
      ,[ship_to_country_code]
      ,[ship_to_country_name]
      ,[ship_to_phone]
      ,[ship_to_ein]
      ,[delivery_name]
      ,[delivery_addr1]
      ,[delivery_addr2]
      ,[delivery_addr3]
      ,[delivery_city]
      ,[delivery_state]
      ,[delivery_zip]
      ,[delivery_country_code]
      ,[delivery_country_name]
      ,[delivery_phone]
      ,[bill_frght_to_code]
      ,[bill_frght_to_name]
      ,[bill_frght_to_addr1]
      ,[bill_frght_to_addr2]
      ,[bill_frght_to_addr3]
      ,[bill_frght_to_city]
      ,[bill_frght_to_state]
      ,[bill_frght_to_zip]
      ,[bill_frght_to_country_code]
      ,[bill_frght_to_country_name]
      ,[bill_frght_to_phone]
      ,[return_to_code]
      ,[return_to_name]
      ,[return_to_addr1]
      ,[return_to_addr2]
      ,[return_to_addr3]
      ,[return_to_city]
      ,[return_to_state]
      ,[return_to_zip]
      ,[return_to_country_code]
      ,[return_to_country_name]
      ,[return_to_phone]
      ,[appointment_number]
      ,[appointment_status]
      ,[scheduled_location]
      ,[scheduled_start]
      ,[scheduled_duration]
      ,[rma_number]
      ,[rma_expiration_date]
      ,[carton_label]
      ,[ver_flag]
      ,[full_pallets]
      ,[haz_flag]
      ,[order_wgt]
      ,[status]
      ,[zone]
      ,[drop_ship]
      ,[lock_flag]
      ,[partial_order_flag]
      ,[earliest_ship_date]
      ,[latest_ship_date]
      ,[actual_ship_date]
      ,[earliest_delivery_date]
      ,[latest_delivery_date]
      ,[actual_delivery_date]
      ,[route]
      ,[baseline_rate]
      ,[planning_rate]
      ,[carrier_id]
      ,[manifest_carrier_id]
      ,[ship_via_id]
      ,[display_order_number]
      ,[client_code]
      ,[ship_to_residential_flag]
      ,[carrier_mode]
      ,[service_level]
      ,[ship_to_attention]
      ,[earliest_appt_time]
      ,[latest_appt_time]
      ,[image_entity_item_id]
      ,[order_type]
      ,[updated_date_time]
      ,[is_gift]
      ,[gift_recipient_name]
      ,[cutoff_date_time]
      ,[customer_first_name]
      ,[customer_last_name]
      ,[host_status]
      ,[cartonization_job_id]
      ,[release_relpen_date]
      ,[release_prep_date]
      ,[release_pick_date]
      ,[is_will_call]
      ,[retry_cartonize]
      ,[retry_cartonize_datetime]
  FROM [dbo].[t_order]
  JOIN t_route_detail
  ON t_order.order_number = t_route_detail.order_number
WHERE route_id = @route_id

SELECT DISTINCT 't_pick_detail' [t_pick_detail]
	, pkd.*
FROM t_pick_detail pkd
JOIN t_route_detail rtd
	ON pkd.order_number = rtd.order_number
	AND pkd.wh_id = rtd.wh_id
WHERE route_id = @route_id

SELECT DISTINCT 't_pick_container' [t_pick_container]
	  ,[container_id]
      ,[t_pick_container].[wh_id]
      ,[container_type]
      ,[t_pick_container].[order_number]
      ,[t_pick_container].[status]
      ,[user_assigned]
      ,[container_label]
      ,[label_status]
      ,[cartonization_batch_id]
      ,[manifest_status]
      ,[tracking_number]
      ,[actual_length]
      ,[actual_width]
      ,[actual_height]
      ,[actual_weight]
      ,[carrier_id]
      ,[manifest_carrier_id]
      ,[ship_via_id]
      ,[sat_delivery_flag]
      ,[registered_mail_flag]
      ,[restricted_mail_flag]
      ,[freight_cost]
      ,[insurance_flag]
      ,[insured_amount]
      ,[target_ship_date]
      ,[actual_ship_date]
      ,[shipment_id]
      ,[print_sequence]
      ,[print_data]
      ,[bol_number]
      ,[create_date]
      ,[is_vas_verified]
      ,[label_print_date]
      ,[requires_audit]
      ,[is_override_exception]
      ,[box_sequence]
  FROM [dbo].[t_pick_container]
JOIN t_route_detail ON t_pick_container.order_number = t_route_detail.order_number
	AND  t_pick_container.wh_id = t_route_detail.wh_id
WHERE route_id = @route_id

--SELECT DISTINCT 't_load_working_bk' [t_load_working_bk]
--	  ,[unique_id]
--      ,t_load_working_bk.[wh_id]
--      ,[user_id]
--      ,[hu_id]
--      ,t_load_working_bk.[route_id]
--      ,[scanned_flag]
--      ,[create_date]
--  FROM [dbo].[t_load_working_bk]
--WHERE route_id = @route_id

SELECT DISTINCT 't_ww_working_route_release' [t_ww_working_route_release]
	  ,t_ww_working_route_release.[wh_id]
      ,t_ww_working_route_release.[route_id]
      ,[employee_id]
      ,[date_inserted]
  FROM [dbo].[t_ww_working_route_release]
WHERE route_id = @route_id

SELECT DISTINCT 't_route_zone_pick' [t_route_zone_pick]
	  ,t_route_zone_pick.[route_id]
      ,t_route_zone_pick.[wh_id]
      ,[zone_pick_type]
  FROM [dbo].[t_route_zone_pick]
WHERE route_id = @route_id

SELECT DISTINCT 't_pcs_cart_building' [t_pcs_cart_building]
	  ,t_pcs_cart_building.[wh_id]
      ,[parent_hu_id]
      ,t_pcs_cart_building.[route_id]
      ,[date_started]
  FROM [dbo].[t_pcs_cart_building]
WHERE route_id = @route_id

SELECT DISTINCT 't_ship_working' [t_ship_working]
	  ,[unique_id]
      ,t_ship_working.[wh_id]
      ,t_ship_working.[route_id]
      ,[user_id]
      ,[hu_id]
      ,[create_date]
  FROM [dbo].[t_ship_working]
WHERE route_id = @route_id

SELECT DISTINCT 't_load_working' [t_load_working]
	  ,[unique_id]
      ,t_load_working.[wh_id]
      ,[user_id]
      ,[hu_id]
      ,t_load_working.[route_id]
      ,[scanned_flag]
      ,[create_date]
  FROM [dbo].[t_load_working]
WHERE route_id = @route_id

SELECT 't_message_log_outbound' [t_message_log_outbound]
	  ,[unique_id]
      ,[message_data]
      ,[date_inserted]
      ,[results]
      ,[processing_start]
      ,[message_id]
      ,[message_type]
      ,[environment]
      ,[mlo].[status]
      ,[attempted_connections]
      ,[uri]
      ,[http_headers]
      ,[time_out]
      ,[processing_end]
      ,[server_response_time]
      ,[server_response_code]
      ,[mlo].[wh_id]
      ,[failed]
      ,[max_attempts]
  FROM [dbo].[t_message_log_outbound] AS [mlo]
  WHERE message_type = 'HOST_SHIPMENT_EXPORT'
	  AND JSON_VALUE(message_data, '$.Message.Contents.Shipments[0].Shipment.route_id') = @route_id
	ORDER BY date_inserted desc
