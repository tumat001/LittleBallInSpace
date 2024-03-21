extends "res://WorldRelated/AbstractWorldSlice.gd"



const BaseEnemy = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/BaseEnemy.gd")
const PlayerCaptureAreaRegion = preload("res://AreaRegionRelated/Subs/PlayerCaptureAreaRegion/PlayerCaptureAreaRegion.gd")

const WorldS_S06_06H_RewindDataManager = preload("res://WorldRelated/WorldSlices/Stage_006/Level06_Hard/Subs/WorldS_S06_06H__RewindDataManager.gd")
const PositionLink2D = preload("res://WorldRelated/WorldSlices/Stage_006/Level06_Hard/Subs/PositionLink2D.gd")

#

const POS_LINK_IDENTIFIER__POSSIBLE_SPAWN = "PSpawn"
const POS_LINK_UNIT_DISTNACE = (32 * 11)
const PCA_TRAVEL_DURATION_PER_UNIT_DISTANCE = 6.0

const CAPTURE_DURATION__NORMAL = 25.0
const CAPTURE_DURATION__HARD = 40.0

const RANDOM_ATTK_CD__MIN = 1.5
const RANDOM_ATTK_CD__MAX = 4.0

#

var is_difficulty_increased : bool

#

var _all_per_unit_vec : Array
var id_to_poslink_map : Dictionary

var world_data_rewind_data_manager : WorldS_S06_06H_RewindDataManager
var starting_poslink : PositionLink2D

#

onready var enemy_container = $ObjectContainer/EnemyContainer

onready var pca_moving = $AreaRegionContainer/PCA_Moving
onready var pca_pos_container = $PCAPosContainer

onready var vis_fog_01 = $MiscContainer/VisTransitionFog_01
onready var pdar_cinematic_start = $AreaRegionContainer/PDAR_Cinematic_Start
onready var pdar_cinematic_end = $AreaRegionContainer/PDAR_Cinematic_End

onready var portal_02__exit = $ObjectContainer/Portal_Blue02

onready var alert_circle_drawer = $MiscContainer/AlertCircleDrawer

###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	
	_all_per_unit_vec.append(Vector2(POS_LINK_UNIT_DISTNACE, 0))
	_all_per_unit_vec.append(Vector2(-POS_LINK_UNIT_DISTNACE, 0))
	_all_per_unit_vec.append(Vector2(0, POS_LINK_UNIT_DISTNACE))
	_all_per_unit_vec.append(Vector2(0, -POS_LINK_UNIT_DISTNACE))
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

#

func _ready():
	portal_02__exit.visible = false
	pdar_cinematic_start.connect("player_entered_in_area", self, "_on_player_entered_in_area__cinematic_start", [], CONNECT_ONESHOT)
	pdar_cinematic_end.connect("player_entered_in_area", self, "_on_player_entered_in_area__cinematic_exit", [], CONNECT_ONESHOT)
	
	pca_moving.connect("player_entered_area_while_activated", self, "_on_player_entered_area_while_activated")
	pca_moving.duration_for_capture = CAPTURE_DURATION__NORMAL
	
	for enemy in enemy_container.get_children():
		_add_enemy_as_in_death_chamber(enemy, false)
	call_deferred("_deferred_ready")
	
	
	_disable_rewind_capability()


func _disable_rewind_capability():
	SingletonsAndConsts.current_rewind_manager.can_store_rewind_data_cond_clause.attempt_insert_clause(SingletonsAndConsts.current_rewind_manager.CanStoreRewindDataClauseIds.CUSTOM_FROM_WORLD_SLICE)
	SingletonsAndConsts.current_rewind_manager.can_cast_rewind_cond_clause.attempt_insert_clause(SingletonsAndConsts.current_rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE)

#

func _deferred_ready():
	SingletonsAndConsts.current_game_elements.initialize_all_enemy_killing_shockwave_relateds()
	


func _on_player_entered_in_area__cinematic_start():
	vis_fog_01.deactivate_monitor_for_player()

func _on_player_entered_in_area__cinematic_exit():
	_activate_all_enemies()
	vis_fog_01.lift_and_end_fog(0.75)
	
	CameraManager.set_current_default_zoom_out_vec(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL)
	

func _add_enemy_as_in_death_chamber(arg_enemy, arg_add_as_child : bool = true):
	arg_enemy.is_immovable_and_invulnerable = true
	
	if arg_add_as_child:
		enemy_container.add_child(arg_enemy)
	
	arg_enemy.prevent_draw_enemy_range_cond_clause.attempt_insert_clause(arg_enemy.PreventDrawEnemyRangeClauseId.CUSTOM_WORLD_SLICE)
	arg_enemy.starting_attack_cooldown_mode_id = arg_enemy.StartingAttackCooldownModeId.RANDOM_COOLDOWN_FROM_EXPORT
	arg_enemy.starting_random_cooldown_export__min = RANDOM_ATTK_CD__MIN
	arg_enemy.starting_random_cooldown_export__max = RANDOM_ATTK_CD__MAX

func _activate_all_enemies():
	for enemy in enemy_container.get_children():
		enemy.activate_target_detection()
		
	

# diff trigger

func _on_Object_InteractableButton_pressed(arg_is_pressed):
	if SingletonsAndConsts.current_game_elements.is_game_after_init and !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		_do_modifs_for_increased_difficulty()
		

func _do_modifs_for_increased_difficulty():
	is_difficulty_increased = true
	
	pca_moving.duration_for_capture = CAPTURE_DURATION__HARD
	
	alert_circle_drawer.do_alert()


func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if world_data_rewind_data_manager.is_activated__marker_data:
			_delta_passed_activated__advance_data(delta)

#


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))
	
	_init_world_data_rewind_data_manager()
	call_deferred("deferred_link_up_all_poslinks")

#

func _init_world_data_rewind_data_manager():
	world_data_rewind_data_manager = WorldS_S06_06H_RewindDataManager.new()
	game_elements.rewind_manager.add_to_rewindables(world_data_rewind_data_manager)
	
	world_data_rewind_data_manager.duration_per_travel = PCA_TRAVEL_DURATION_PER_UNIT_DISTANCE

#

func deferred_link_up_all_poslinks():
	var glob_pos_to_poslink_map : Dictionary = {}
	var all_viable_starter_poslinks : Array = []
	var id = 0
	for poslink in pca_pos_container.get_children():
		glob_pos_to_poslink_map[poslink.global_position] = poslink
		poslink.id = id
		id += 1
		
		id_to_poslink_map[id] = poslink
		
		if poslink.name.find(POS_LINK_IDENTIFIER__POSSIBLE_SPAWN) != -1:
			all_viable_starter_poslinks.append(poslink)
	
	#
	
	starting_poslink = StoreOfRNG.randomly_select_one_element(all_viable_starter_poslinks, SingletonsAndConsts.non_essential_rng)
	pca_moving.global_position = starting_poslink.global_position
	
	#
	
	for poslink in pca_pos_container.get_children():
		var pos_of_poslink = poslink.global_position
		for per_unit_vec in _all_per_unit_vec:
			var candidate_pos = pos_of_poslink + per_unit_vec
			
			if glob_pos_to_poslink_map.has(candidate_pos):
				var cand_poslink_to_link = glob_pos_to_poslink_map[candidate_pos]
				if !poslink.all_position_links.has(cand_poslink_to_link):
					poslink.all_position_links.append(cand_poslink_to_link)
	

###

func _on_player_entered_area_while_activated():
	if !world_data_rewind_data_manager.is_activated__marker_data:
		world_data_rewind_data_manager.is_activated__marker_data = true
		#world_data_rewind_data_manager.set_curr_poslink_and_prev_poslink(starting_poslink.randomly_choose_position_link(null), starting_poslink)
		var new_poslink = world_data_rewind_data_manager.get_latest_in_rewinded_decided_poslinks__or_arg(starting_poslink.randomly_choose_position_link(null))
		world_data_rewind_data_manager.set_curr_poslink_and_prev_poslink(new_poslink, starting_poslink)

func _delta_passed_activated__advance_data(arg_delta):
	var excess = world_data_rewind_data_manager.delta_update(arg_delta)
	while excess != -1:
		var curr_poslink = world_data_rewind_data_manager.get_current_poslink_to_path_to()
		var new_poslink = world_data_rewind_data_manager.get_next_poslink_to_path_to() #curr_poslink.randomly_choose_position_link(world_data_rewind_data_manager.get_prev_poslink_to_path_to())
		
		world_data_rewind_data_manager.set_curr_poslink_and_prev_poslink(new_poslink, curr_poslink)
		excess = world_data_rewind_data_manager.delta_update(arg_delta)
	
	var pos = world_data_rewind_data_manager.get_final_pos_based_on_curr_path_duration()
	pca_moving.global_position = pos
	

##

func _on_PCA_Moving_region_area_captured():
	_send_shockwave__and_kill_enemies_in_shockwave()

func _send_shockwave__and_kill_enemies_in_shockwave():
	play_enemy_killing_shockwave_ring__preset_very_large(SingletonsAndConsts.current_game_elements.get_current_player().global_position)

func play_enemy_killing_shockwave_ring__preset_very_large(arg_origin):
	SingletonsAndConsts.current_game_elements.play_enemy_killing_shockwave_ring__custom_params(arg_origin, 10, 1000, 0.75, PlayerCaptureAreaRegion.PCA_Drawer_Progress__Color_Outline)

