extends "res://WorldRelated/AbstractWorldSlice.gd"

const BaseEnemy = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/BaseEnemy.gd")

const PlayerCaptureAreaRegion = preload("res://AreaRegionRelated/Subs/PlayerCaptureAreaRegion/PlayerCaptureAreaRegion.gd")


#

const CAPTURE_DURATION__NORMAL = 30.0
const CAPTURE_DURATION__HARD = 40.0


#

const RANDOM_ATTK_CD__MIN = 1.5
const RANDOM_ATTK_CD__MAX = 4.0


#

var is_difficulty_increased : bool
var _frames_before_allow_rewind_again : int

var _after_frame_count_is_accomplished__for_diff_inc : bool

#

onready var time_left_label = $Node/MarginContainer/CenterContainer/TimerLeftLabel
onready var all_enemies_in_death_chamber_container = $ObjectContainer/AllEnemiesInDeathChamberContainer

onready var portal_01__entry = $ObjectContainer/Portal_Blue01
onready var portal_02__exit = $ObjectContainer/Portal_Blue02

onready var vis_transition_fog_01 = $Node/VisTransitionFog_01
onready var pdar_cinematic_start = $AreaRegionContainer/PDAR_Cinematic_Start
onready var pdar_cinematic_end = $AreaRegionContainer/PDAR_Cinematic_End

onready var main_PCAR = $AreaRegionContainer/PlayerCaptureAreaRegion

onready var alert_circle_drawer = $Node/AlertCircleDrawer

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	



func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))


#

func _ready():
	portal_02__exit.visible = false
	pdar_cinematic_start.connect("player_entered_in_area", self, "_on_player_entered_pdar_cinematic_start", [], CONNECT_ONESHOT)
	pdar_cinematic_end.connect("player_entered_in_area", self, "_on_player_entered_pdar_cinematic_end", [], CONNECT_ONESHOT)
	
	main_PCAR.duration_for_capture = CAPTURE_DURATION__NORMAL
	
	for enemy in all_enemies_in_death_chamber_container.get_children():
		_add_enemy_as_in_death_chamber(enemy, false)
	call_deferred("_deferred_ready")

func _deferred_ready():
	SingletonsAndConsts.current_game_elements.initialize_all_enemy_killing_shockwave_relateds()
	

#

func _on_player_entered_pdar_cinematic_start():
	vis_transition_fog_01.deactivate_monitor_for_player()

func _on_player_entered_pdar_cinematic_end():
	_listen_for_cam_visual_rotation_finished()
	_activate_all_enemies()
	vis_transition_fog_01.lift_and_end_fog(0.75)


func _listen_for_cam_visual_rotation_finished():
	CameraManager.connect("cam_visual_rotation_finished", self, "_on_cam_visual_rotation_finished", [], CONNECT_ONESHOT)

func _on_cam_visual_rotation_finished():
	CameraManager.make_control_node_rotate_with_camera(time_left_label)


func _activate_all_enemies():
	for enemy in all_enemies_in_death_chamber_container.get_children():
		enemy.activate_target_detection()
		
	


#

func _add_enemy_as_in_death_chamber(arg_enemy, arg_add_as_child : bool = true):
	if arg_add_as_child:
		all_enemies_in_death_chamber_container.add_child(arg_enemy)
	
	arg_enemy.prevent_draw_enemy_range_cond_clause.attempt_insert_clause(arg_enemy.PreventDrawEnemyRangeClauseId.CUSTOM_WORLD_SLICE)
	arg_enemy.starting_attack_cooldown_mode_id = BaseEnemy.StartingAttackCooldownModeId.RANDOM_COOLDOWN_FROM_EXPORT
	arg_enemy.starting_random_cooldown_export__min = RANDOM_ATTK_CD__MIN
	arg_enemy.starting_random_cooldown_export__max = RANDOM_ATTK_CD__MAX


# difficulty trigger

func _on_Object_InteractableButton_pressed(arg_is_pressed):
	if SingletonsAndConsts.current_game_elements.is_game_after_init and !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		_do_modifs_for_increased_difficulty()
		

func _do_modifs_for_increased_difficulty():
	is_difficulty_increased = true
	
	var container_node = $Node/AdditionalEnemiesInHard
	for pos_enemy_determiner_node in container_node.get_children():
		var name_of_determiner : String = pos_enemy_determiner_node.name
		var pos = pos_enemy_determiner_node.global_position
		
		if "TypeLn" in name_of_determiner:
			_summon_enemy_at_pos__laser_normal(pos)
		elif "TypeLp" in name_of_determiner:
			_summon_enemy_at_pos__laser_predictive(pos)
		elif "TypeBn" in name_of_determiner:
			_summon_enemy_at_pos__ball_normal(pos)
		
	
	##
	
	main_PCAR.duration_for_capture = CAPTURE_DURATION__HARD
	
	##
	
	SingletonsAndConsts.current_rewind_manager.can_cast_rewind_cond_clause.attempt_insert_clause(SingletonsAndConsts.current_rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE)
	_frames_before_allow_rewind_again = 10
	
	##
	
	alert_circle_drawer.do_alert()

func _allow_rewind_after_frame_count_is_accomplished__for_diff_inc():
	if !_after_frame_count_is_accomplished__for_diff_inc:
		_after_frame_count_is_accomplished__for_diff_inc = true
		SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
		SingletonsAndConsts.current_rewind_manager.can_cast_rewind_cond_clause.remove_clause(SingletonsAndConsts.current_rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE)


func _process(delta):
	if is_difficulty_increased:
		_frames_before_allow_rewind_again -= 1
		if _frames_before_allow_rewind_again < 0:
			_allow_rewind_after_frame_count_is_accomplished__for_diff_inc()
	

#

func _summon_enemy_at_pos__laser_normal(arg_pos : Vector2):
	_summon_enemy__at_pos_with_type(arg_pos, BaseEnemy.EnemyTypeExportTemplate.LASER__NORMAL_XRAY)
	

func _summon_enemy_at_pos__laser_predictive(arg_pos : Vector2):
	_summon_enemy__at_pos_with_type(arg_pos, BaseEnemy.EnemyTypeExportTemplate.LASER__PREDICT_XRAY)
	

func _summon_enemy_at_pos__ball_normal(arg_pos : Vector2):
	_summon_enemy__at_pos_with_type(arg_pos, BaseEnemy.EnemyTypeExportTemplate.BALL)
	


func _summon_enemy__at_pos_with_type(arg_pos : Vector2, arg_type):
	var enemy = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.ENEMY)
	enemy.enemy_type_template__for_export = arg_type
	enemy.global_position = arg_pos
	
	#_add_enemy_as_in_death_chamber(enemy)
	call_deferred("_add_enemy_as_in_death_chamber", enemy)

#

func _on_PlayerCaptureAreaRegion_duration_for_capture_left_changed(arg_base_duration, arg_curr_val_left : float, delta, arg_is_from_rewind):
	if arg_curr_val_left < 0:
		arg_curr_val_left = 0
	
	if arg_curr_val_left < 10:
		_display_timer_time__as_miliseconds(arg_curr_val_left)
	else:
		_display_timer_time__as_normal(arg_curr_val_left)
	

func _display_timer_time__as_miliseconds(arg_time_val):
	time_left_label.text = "%02.2f" % arg_time_val

func _display_timer_time__as_normal(arg_time_val):
	time_left_label.text = str(floor(arg_time_val))



#


func _on_PlayerCaptureAreaRegion_region_area_captured():
	_send_shockwave__and_kill_enemies_in_shockwave()

func _send_shockwave__and_kill_enemies_in_shockwave():
	play_enemy_killing_shockwave_ring__preset_very_large(SingletonsAndConsts.current_game_elements.get_current_player().global_position)

func play_enemy_killing_shockwave_ring__preset_very_large(arg_origin):
	SingletonsAndConsts.current_game_elements.play_enemy_killing_shockwave_ring__custom_params(arg_origin, 10, 1000, 0.75, PlayerCaptureAreaRegion.PCA_Drawer_Progress__Color_Outline)


