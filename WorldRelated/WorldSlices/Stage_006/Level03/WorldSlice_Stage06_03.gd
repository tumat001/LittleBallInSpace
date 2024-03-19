extends "res://WorldRelated/AbstractWorldSlice.gd"

const BaseEnemy = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/BaseEnemy.gd")


#

onready var portal_win = $ObjectContainer/Portal_Win

onready var enemy_type_pos_marker_left = $EnemyTypePosMarker_Left
onready var enemy_type_pos_marker_right = $EnemyTypePosMarker_Right
onready var enemy_type_pos_marker_bot = $EnemyTypePosMarker_Bot

onready var vision_fog__left = $MiscContainer/VisionFog_Left
onready var vision_fog__right = $MiscContainer/VisionFog_Right
onready var vision_fog__bot = $MiscContainer/VisionFog_Bot

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	vision_fog__bot.visible = true
	vision_fog__left.visible = true
	vision_fog__right.visible = true

##

func _on_Portal_Win_player_entered__as_scene_transition(arg_player) -> void:
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	


####

func _on_PDAR_ForLeft_player_entered_in_area() -> void:
	_begin_actions__summon_enemies_in_sector(enemy_type_pos_marker_left)
	
	vision_fog__left.start_hide_fog()

func _on_PDAR_ForRight_player_entered_in_area() -> void:
	_begin_actions__summon_enemies_in_sector(enemy_type_pos_marker_right)
	
	vision_fog__right.start_hide_fog()

func _on_PDAR_ForBot_player_entered_in_area() -> void:
	_begin_actions__summon_enemies_in_sector(enemy_type_pos_marker_bot)
	
	vision_fog__bot.start_hide_fog()


func _begin_actions__summon_enemies_in_sector(arg_enemy_container : Node):
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	call_deferred("_deferred_summon_enemies_in_node_container__then_allow_rewind", arg_enemy_container)

func _deferred_summon_enemies_in_node_container__then_allow_rewind(arg_container : Node):
	_summon_enemies_in_node_container(arg_container)
	
	var tweener = create_tween()
	tweener.tween_interval(0.2)
	tweener.tween_callback(game_elements, "allow_rewind_manager_to_store_and_cast_rewind")
	#game_elements.allow_rewind_manager_to_store_and_cast_rewind()


func _summon_enemies_in_node_container(arg_container : Node):
	for marker in arg_container.get_children():
		_summon_enemy_on_marker_based_on_marker_name(marker)

func _summon_enemy_on_marker_based_on_marker_name(arg_marker : Node2D):
	var enemy = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.ENEMY)
	enemy.global_position = arg_marker.global_position
	
	var enemy_type 
	if arg_marker.name.ends_with("LaserN"):
		enemy_type = BaseEnemy.EnemyTypeExportTemplate.LASER__NORMAL_XRAY
	elif arg_marker.name.ends_with("LaserP"):
		enemy_type = BaseEnemy.EnemyTypeExportTemplate.LASER__PREDICT_XRAY
	elif arg_marker.name.ends_with("Ball"):
		enemy_type = BaseEnemy.EnemyTypeExportTemplate.BALL
	
	enemy.enemy_type_template__for_export = enemy_type
	
	object_container.add_child(enemy)
	enemy.call_deferred("activate_target_detection")



