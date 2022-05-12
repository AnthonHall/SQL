USE AAD

DECLARE @item_number nvarchar(30)
SET @item_number = '5e20065c323c4d000eb61b00'

SELECT DISTINCT 'ORPHANED t_iid_items.item_number'
	, t_iid_items.item_number, t_fwd_pick.item_number, forward_pick_location, location_id
FROM t_iid_items
LEFT JOIN t_fwd_pick on t_iid_items.item_number = t_fwd_pick.item_number
WHERE t_iid_items.item_number = @item_number
AND t_iid_items.forward_pick_location IS NOT NULL
AND t_fwd_pick.item_number IS NULL

SELECT DISTINCT 't_item_master' AS [table]
	, t_item_master.*
from t_item_master
where t_item_master.item_number = @item_number

SELECT DISTINCT 't_item_uom' AS [table]
	  ,[item_uom_id]
      ,[item_master_id]
      ,[item_number]
      ,[wh_id]
      ,[uom]
      ,[conversion_factor]
      ,[package_weight]
      ,[units_per_layer]
      ,[layers_per_uom]
      ,[uom_weight]
      ,[pickable]
      ,[box_type]
      ,[length]
      ,[width]
      ,[height]
      ,[no_overhang_on_top]
      ,[stack_code]
      ,[batch]
      ,[use_orientation_data]
      ,[turnable]
      ,[on_bottom_ok]
      ,[on_side_ok]
      ,[on_end_ok]
      ,[bottom_only]
      ,[top_only]
      ,[max_in_layer]
      ,[max_support_weight]
      ,[stack_index]
      ,[container_value]
      ,[load_separately]
      ,[nesting_height_increase]
      ,[nested_volume]
      ,[unit_volume]
      ,[pattern]
      ,[priority]
      ,[status]
      ,[uom_prompt]
      ,[default_receipt_uom]
      ,[default_pick_uom]
      ,[class_id]
      ,[pick_put_id]
      ,[conveyable]
      ,[std_hand_qty]
      ,[min_hand_qty]
      ,[max_hand_qty]
      ,[default_pick_area]
      ,[pick_location]
      ,[display_config]
      ,[vas_profile]
      ,[cartonization_flag]
      ,[gtin]
      ,[shippable_uom]
      ,[units_per_grab]
      ,[upright_only]
      ,[is_ship_alone]
      ,[upc]
  FROM [dbo].[t_item_uom]
where [t_item_uom].item_number = @item_number

SELECT DISTINCT 't_stored_item' as [table]
      ,t_stored_item.[type]
      ,t_stored_item.[status]
      ,t_stored_item.[expiration_date]
	  ,t_stored_item.[sto_id]
      ,t_stored_item.[sequence]
      ,t_stored_item.[item_number]
      ,t_stored_item.[actual_qty]
      ,t_stored_item.[unavailable_qty]
      ,t_stored_item.[wh_id]
      ,t_stored_item.[location_id]
      ,t_stored_item.[fifo_date]
      ,t_stored_item.[reserved_for]
      ,t_stored_item.[lot_number]
      ,t_stored_item.[inspection_code]
      ,t_stored_item.[put_away_location]
      ,t_stored_item.[stored_attribute_id]
      ,t_stored_item.[hu_id]
      ,t_stored_item.[shipment_number]
      ,t_stored_item.[po_number]
      ,t_stored_item.[po_line]
      ,t_stored_item.[ice_flag]
      ,t_stored_item.[sleeve_flag]
      ,t_stored_item.[po_line_unit_cost]
      ,t_stored_item.[freeze_flag]
      ,t_stored_item.[entered_date]
  FROM [dbo].[t_stored_item]
JOIN t_order_detail ON t_stored_item.item_number = t_order_detail.item_number
AND t_stored_item.wh_id = t_order_detail.wh_id
WHERE t_stored_item.item_number = @item_number

SELECT DISTINCT 't_location' AS [table]
      ,t_location.[status]
      ,t_location.[type]
      ,t_location.[sub_type]
	  ,t_location.[wh_id]
      ,t_location.[location_id]
      ,t_location.[description]
      ,t_location.[short_location_id]
      ,t_location.[zone]
      ,t_location.[picking_flow]
      ,t_location.[capacity_uom]
      ,t_location.[capacity_qty]
      ,t_location.[stored_qty]
      ,t_location.[fifo_date]
      ,t_location.[cycle_count_class]
      ,t_location.[last_count_date]
      ,t_location.[last_physical_date]
      ,t_location.[user_count]
      ,t_location.[capacity_volume]
      ,t_location.[time_between_maintenance]
      ,t_location.[last_maintained]
      ,t_location.[length]
      ,t_location.[width]
      ,t_location.[height]
      ,t_location.[replenishment_location_id]
      ,t_location.[pick_area]
      ,t_location.[allow_bulk_pick]
      ,t_location.[slot_rank]
      ,t_location.[slot_status]
      ,t_location.[item_hu_indicator]
      ,t_location.[c1]
      ,t_location.[c2]
      ,t_location.[c3]
      ,t_location.[random_cc]
      ,t_location.[x_coordinate]
      ,t_location.[y_coordinate]
      ,t_location.[z_coordinate]
      ,t_location.[storage_device_id]
      ,t_location.[equipment_type]
      ,t_location.[location_group]
      ,t_location.[is_pallet_controlled]
      ,t_location.[pick_put_seq]
      ,t_location.[dynamic_flag]
      ,t_location.[aisle]
      ,t_location.[bay]
      ,t_location.[sub_bay]
      ,t_location.[position]
      ,t_location.[shelf]
      ,t_location.[check_digit]
      ,t_location.[inserted_date]
      ,t_location.[stage_replen]
      ,t_location.[match_sequence]
      ,t_location.[updated_by]
      ,t_location.[updated_from]
  FROM [dbo].[t_location]
join t_stored_item on t_location.location_id = t_stored_item.location_id
join t_order_detail on t_stored_item.item_number = t_order_detail.item_number
and t_location.wh_id = t_order_detail.wh_id
where t_stored_item.item_number = @item_number

SELECT DISTINCT 't_hu_master' as [table]
      ,t_hu_master.[status]
      ,t_hu_master.[type]
	  ,t_hu_master.[hu_id]
      ,t_hu_master.[control_number]
      ,t_hu_master.[location_id]
      ,t_hu_master.[subtype]
      ,t_hu_master.[fifo_date]
      ,t_hu_master.[wh_id]
      ,t_hu_master.[load_position]
      ,t_hu_master.[haz_material]
      ,t_hu_master.[load_id]
      ,t_hu_master.[load_seq]
      ,t_hu_master.[ver_flag]
      ,t_hu_master.[zone]
      ,t_hu_master.[reserved_for]
      ,t_hu_master.[container_type]
      ,t_hu_master.[stop_id]
      ,t_hu_master.[parent_hu_id]
      ,t_hu_master.[user_id]
      ,t_hu_master.[dwell_start]
      ,t_hu_master.[sell_by_date]
      ,t_hu_master.[length]
      ,t_hu_master.[width]
      ,t_hu_master.[height]
      ,t_hu_master.[box_type]
      ,t_hu_master.[po_number]
      ,t_hu_master.[po_line_number]
      ,t_hu_master.[ice_flag]
      ,t_hu_master.[last_qa_check]
      ,t_hu_master.[qa_check_needed]
      ,t_hu_master.[last_tran_date]
      ,t_hu_master.[last_cc_date]
  FROM [dbo].[t_hu_master]
JOIN t_stored_item on t_hu_master.location_id = t_stored_item.location_id
	AND t_hu_master.wh_id = t_stored_item.wh_id
	AND item_number = @item_number

select distinct 't_fwd_pick' as [table], t_fwd_pick.*
from t_fwd_pick
--join t_stored_item on t_fwd_pick.location_id = t_stored_item.location_id
--join t_order_detail on t_stored_item.item_number = t_order_detail.item_number
--and t_fwd_pick.wh_id = t_order_detail.wh_id
where item_number = @item_number

SELECT DISTINCT 't_replen_fwd_pick_locs' AS [table]
	  ,[unique_id]
      ,[location_id]
      ,[zone]
      ,[wh_id]
      ,[item_number]
      ,[min_qty]
      ,[max_qty]
      ,[cur_qty]
      ,[max_volume]
      ,[used_volume]
      ,[dynamic]
      ,[uom]
      ,[status]
      ,[single_replen_flag]
      ,[pick_put_seq]
      ,[demand_qty]
      ,[drop_location]
      ,[allocated_qty]
      ,[open_work_q_id]
      ,[error_msg]
      ,[reserve_qty]
      ,[transit_qty]
      ,[open_work_q_qty]
      ,[open_work_q_transit_qty]
      ,[cur_avail_qty]
  FROM [dbo].[t_replen_fwd_pick_locs]
WHERE t_replen_fwd_pick_locs.item_number = @item_number

SELECT DISTINCT 't_iid_items' AS [table]
	  ,[wh_id]
      ,[item_number]
      ,[exception_cycle_count_locations]
      ,[pending_qty]
      ,[released_qty]
      ,[total_onhand]
      ,[transit_replen]
      ,[pickable_qty]
      ,[unavailable_qty]
      ,[rc_inventory]
      ,[lost_ic_hold_inventory]
      ,[raw_lost_ic_hold_inventory]
      ,[raw_total_onhand]
      ,[raw_transit_replen]
      ,[raw_pickable_qty]
      ,[raw_rc_inventory]
      ,[raw_unavailable_qty]
      ,[raw_pre_prep_inventory]
      ,[next_po_date]
      ,[foward_pick_count]
      ,[forward_pick_location]
      ,[supplier_name]
      ,[supplier_info_last_updated]
      ,[bom_conversion_factor]
      ,[substitutions_available_qty]
      ,[has_substitutions]
  FROM [dbo].[t_iid_items]
  WHERE item_number = @item_number

SELECT DISTINCT 't_order_detail' AS [table], od.order_number, od.qty 
--sum(od.qty) as [demand]
from t_order_detail od
join t_order o on od.order_number = o.order_number
where item_number  = @item_number
and o.status <> 'SHIPPED'

SELECT DISTINCT 't_pick_detail' as [table]
      ,[status]
      ,[pick_loc_exp_date]
      ,[work_type]
--default order below, important fields above
	  ,[pick_id]
      ,[order_number]
      ,[line_number]
      ,[type]
      ,[uom]
      ,[work_q_id]
      ,[item_number]
      ,[lot_number]
      ,[unplanned_quantity]
      ,[planned_quantity]
      ,[picked_quantity]
      ,[staged_quantity]
      ,[loaded_quantity]
      ,[packed_quantity]
      ,[shipped_quantity]
      ,[staging_location]
      ,[zone]
      ,[wave_id]
      ,[load_id]
      ,[load_sequence]
      ,[stop_id]
      ,[container_id]
      ,[pick_category]
      ,[user_assigned]
      ,[bulk_pick_flag]
      ,[stacking_sequence]
      ,[pick_area]
      ,[wh_id]
      ,[cartonization_batch_id]
      ,[manifest_batch_id]
      ,[stored_attribute_id]
      ,[create_date]
      ,[before_pick_rule]
      ,[during_pick_rule]
      ,[hold_reason_id]
      ,[pick_run]
      ,[pick_location]
      ,[priority]
      ,[container_type]
      ,[previous_pick_id]
      ,[pick_datetime]
      ,[pick_loc_change_datetime]
      ,[inserted_datetime]
      ,[cartonization_pick_id]
      ,[rls_prep_date]
      ,[rls_rpln_date]
      ,[rls_pick_date]
      ,[sub_container_id]
      ,[zone_pick_type]
  FROM [dbo].[t_pick_detail]
WHERE item_number = @item_number
AND status <> 'SHIPPED'

SELECT DISTINCT 't_work_q' AS [table]
	  ,[work_q_id]
      ,[work_type]
      ,[description]
      ,[pick_ref_number]
      ,[priority]
      ,[date_due]
      ,[time_due]
      ,[item_number]
      ,[wh_id]
      ,[location_id]
      ,[from_location_id]
      ,[work_status]
      ,[qty]
      ,[workers_required]
      ,[workers_assigned]
      ,[zone]
      ,[employee_id]
      ,[priority_overridden]
      ,[datetime_stamp]
      ,[parent_hu_id]
      ,[hu_id]
      ,[strict_assignment]
      ,[unique_id]
  FROM [dbo].[t_work_q]
WHERE item_number = @item_number

select t_order.cutoff_date_time, sum(pkd.planned_quantity) as [count]
from t_pick_detail pkd
join t_order on pkd.order_number = t_order.order_number
where item_number = @item_number
and pkd.status <> 'SHIPPED'
group by t_order.cutoff_date_time

select distinct 't_class_loca' as [table], cl.*
from t_class_loca cl
right join t_stored_item si on cl.location_id = si.location_id and cl.wh_id = si.wh_id
where item_number = @item_number

select distinct 't_work_q' as [table], wq.*
from t_work_q wq
right join t_stored_item si on wq.location_id = si.location_id and wq.wh_id = si.wh_id
where si.item_number = @item_number

select distinct 't_tran_log' as [table], tlog.*
from t_tran_log tlog
--right join t_stored_item si on tlog.location_id = si.location_id and tlog.wh_id = si.wh_id
where tlog.item_number = @item_number
order by start_tran_date, start_tran_time

select distinct 't_item_substitute' as [table]
--	, pick_loc_exp_date
	, *
from t_item_substitute
where item_number = @item_number

select distinct 't_bom_detail' as [table]
	, *
from t_bom_detail
where detail_item_number = @item_number
	or master_item_number = @item_number
