extends Control

const GUI_LevelLayoutEle_Tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.gd")
const GameBackground = preload("res://GameBackgroundRelated/GameBackground.gd")

const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")

const LevelUnlock_BeforeBurst_Stream_0000 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0000.png")
const LevelUnlock_BeforeBurst_Stream_0001 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0001.png")
const LevelUnlock_BeforeBurst_Stream_0002 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0002.png")
const LevelUnlock_BeforeBurst_Stream_0003 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0003.png")
const LevelUnlock_BeforeBurst_Stream_0004 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0004.png")
const LevelUnlock_BeforeBurst_Stream_0005 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0005.png")
const all_particles__level_unlock_before_burst_stream = [
	LevelUnlock_BeforeBurst_Stream_0000,
	LevelUnlock_BeforeBurst_Stream_0001,
	LevelUnlock_BeforeBurst_Stream_0002,
	LevelUnlock_BeforeBurst_Stream_0003,
	LevelUnlock_BeforeBurst_Stream_0004,
	LevelUnlock_BeforeBurst_Stream_0005,
]

##

const TILE_WIDTH : int = 46

#

signal prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)
signal prompt_entered_into_link_to_other_layout(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)

signal currently_hovered_layout_ele_changed(arg_id, arg_currently_hovered_tile)


signal triggered_circular_burst_on_curr_ele_for_victory(arg_tile_ele_for_playing_victory_animation_for, arg_level_details)
signal triggered_circular_burst_on_curr_ele_for_victory__as_additionals(arg_tile_eles)

##

var level_layout_id

#

var game_background : GameBackground

#

export(NodePath) var default_node_to_summon_cursor_on__for_first_time__path setget set_default_node_to_summon_cursor_on__for_first_time__path

const NO_CURSOR : int = -2  # if you want to delay the cursor spawn for whatever reason
const UNINITIALIZED_CURSOR : int = -1  # if you want to signal that this level layout has not been traversed yet (new to game, new to layout, etc)
var layout_ele_id_to_summon_cursor_to : int = UNINITIALIZED_CURSOR setget set_layout_ele_id_to_summon_cursor_to

#

# if can accept inputs
var is_layout_enabled : bool setget set_is_layout_enabled

#

var _is_player_cursor_active : bool
var _is_player_cursor_gliding : bool

var _next_available_id : int = 0
var _id_to_layout_ele_map : Dictionary
var _layout_ele_to_id_map : Dictionary


var _currently_hovered_layout_ele_id : int
var _currently_hovered_tile : GUI_LevelLayoutEle_Tile

#

var _rect_position_to_layout_ele_map : Dictionary

# tile ele with level only, not path nor layout
var _all_level_only_tile_ele__level_id_to_ele__map : Dictionary

#

const INPUT_DELAY_AFTER_GLIDE = 0.2
var _input_delay = 0

const INPUT_TYPE__NONE = 0
const INPUT_TYPE__LEFT = 1
const INPUT_TYPE__RIGHT = 2
const INPUT_TYPE__UP = 3
const INPUT_TYPE__DOWN = 4

var _last_input_type : int = INPUT_TYPE__NONE

#

const ELE_TILE_DIR__LEFT = 1
const ELE_TILE_DIR__RIGHT = 2
const ELE_TILE_DIR__UP = 3
const ELE_TILE_DIR__DOWN = 4

#

var gui_level_selection_whole_screen #setget set_gui_level_selection_whole_screen
var particles_container


const BEFORE_BURST_PARTICLE__COUNT = 15
const BEFORE_BURST_PARTICLE__DELAY_PER_PARTICLE = 0.08
const BEFORE_BURST_PARTICLE__COUNT_FOR_TRIGGER_NEXT_PHASE = 15

var _before_burst_particle_counter_timer : Timer
var _before_burst_particle_counter_timer__as_additionals : Timer

var _tile_ele_for_playing_victory_animation_for : GUI_LevelLayoutEle_Tile
var _tile_eles_to_play_additional_vic_animation_for : Array


var _current_burst_particle_summoned_count : int
var _current_burst_particle_summon_loop_count__for_additonal : int

#

onready var player_cursor = $MiscContainer/Cursor

onready var background_container = $BackgroundContainer
onready var layout_elements_container = $LayoutElesContainer
onready var aesthetics_container = $AestheticsContainer

#

func set_default_node_to_summon_cursor_on__for_first_time__path(arg_path):
	default_node_to_summon_cursor_on__for_first_time__path = arg_path
	

####

func _ready():
	_init_id_to_layout_ele_map()
	_summon_cursor_at_appropriate_loc()
	set_is_layout_enabled(is_layout_enabled)
	
	call_deferred("_initialize_layout_ele_dependent_vars")
	call_deferred("_initialize_particles_related")
	
#

func _initialize_particles_related():
	_before_burst_particle_counter_timer = Timer.new()
	_before_burst_particle_counter_timer.one_shot = false
	_before_burst_particle_counter_timer.connect("timeout", self, "_on_before_burst_particle_counter_timer_timeout")
	add_child(_before_burst_particle_counter_timer)
	
	_before_burst_particle_counter_timer__as_additionals = Timer.new()
	_before_burst_particle_counter_timer__as_additionals.one_shot = false
	_before_burst_particle_counter_timer__as_additionals.connect("timeout", self, "_on_before_burst_particle_counter_timer__as_additionals_timeout")
	add_child(_before_burst_particle_counter_timer__as_additionals)

#

func _init_id_to_layout_ele_map():
	for child in layout_elements_container.get_children():
		_assign_layout_ele_next_available_id(child)
	

func _assign_layout_ele_next_available_id(arg_ele):
	_id_to_layout_ele_map[_next_available_id] = arg_ele
	_layout_ele_to_id_map[arg_ele] = _next_available_id
	
	arg_ele.layout_ele_id = _next_available_id
	
	_next_available_id += 1

#

func _set_is_player_cursor_active(arg_val):
	_is_player_cursor_active = arg_val
	
	if !_is_player_cursor_active:
		player_cursor.visible = false
		
	else:
		player_cursor.visible = true
		

##

func get_currently_hovered_layout_ele_id() -> int:
	return _currently_hovered_layout_ele_id

func get_currently_hovered_tile() -> GUI_LevelLayoutEle_Tile:
	return _currently_hovered_tile

##

func set_layout_ele_id_to_summon_cursor_to(arg_ele_id):
	layout_ele_id_to_summon_cursor_to = arg_ele_id
	
	if is_inside_tree():
		if !is_instance_valid(player_cursor):
			_summon_cursor_at_appropriate_loc()
		else:
			_instant_place_cursor_at_layout_ele_id(arg_ele_id, false)

func _summon_cursor_at_appropriate_loc():
	if layout_ele_id_to_summon_cursor_to == NO_CURSOR:
		_set_is_player_cursor_active(false)
		return
		
	elif layout_ele_id_to_summon_cursor_to == UNINITIALIZED_CURSOR:
		var node = get_node(default_node_to_summon_cursor_on__for_first_time__path)
		_instant_place_cursor_at_layout_ele(node, false)
		_set_is_player_cursor_active(true)
		
	else:
		_set_is_player_cursor_active(true)
		


func _instant_place_cursor_at_layout_ele_id(arg_id, arg_play_sound : bool = true):
	var ele
	if arg_id == UNINITIALIZED_CURSOR:
		ele = get_node(default_node_to_summon_cursor_on__for_first_time__path)
	elif arg_id == NO_CURSOR:
		pass
	else:
		 ele = _id_to_layout_ele_map[arg_id]
	
	if ele != null:
		_instant_place_cursor_at_layout_ele(ele, arg_play_sound)

func _instant_place_cursor_at_layout_ele(arg_ele : Control, arg_play_sound : bool = true):
	#player_cursor.rect_global_position = arg_ele.rect_global_position
	player_cursor.rect_global_position = _get_adjusted_cursor_pos__based_on_pos(arg_ele)
	
	_assign_layout_ele_as_current_hovered(arg_ele, arg_play_sound)

func _get_adjusted_cursor_pos__based_on_pos(arg_ele : Control):
	var arg_ele_size : Vector2 = arg_ele.rect_size
	var arg_ele_pos : Vector2 = arg_ele.rect_global_position
	
	var cursor_size = player_cursor.rect_size
	var diff = (cursor_size - arg_ele_size) / 2
	
	return arg_ele_pos - diff


func _assign_layout_ele_as_current_hovered(arg_ele, arg_play_sound : bool = true):
	_currently_hovered_layout_ele_id = _layout_ele_to_id_map[arg_ele]
	_currently_hovered_tile = arg_ele
	
	GameSaveManager.last_hovered_over_level_layout_element_id = _currently_hovered_layout_ele_id
	
	if arg_play_sound:
		if !arg_ele.is_path and !SingletonsAndConsts.current_master._is_transitioning:
			AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_LevelTile_Hover, 1.0, null)
	
	emit_signal("currently_hovered_layout_ele_changed", _currently_hovered_layout_ele_id, _currently_hovered_tile)


func _glide_place_cursor_at_layout_ele(arg_ele : Control):
	if _is_player_cursor_gliding:
		player_cursor.rect_global_position = _get_adjusted_cursor_pos__based_on_pos(_currently_hovered_tile)
	
	_is_player_cursor_gliding = true
	
	var glide_duration : float = 0.2
	
	var tweener = create_tween()
	tweener.tween_property(player_cursor, "rect_global_position", _get_adjusted_cursor_pos__based_on_pos(arg_ele), glide_duration).set_ease(Tween.EASE_IN_OUT)
	tweener.tween_callback(self, "_on_player_cursor_done_gliding").set_delay(glide_duration)
	
	_assign_layout_ele_as_current_hovered(arg_ele)

func _on_player_cursor_done_gliding():
	_is_player_cursor_gliding = false
	

##

func set_is_layout_enabled(arg_val):
	var old_val = is_layout_enabled
	is_layout_enabled = arg_val
	
	if old_val != arg_val:
		if is_layout_enabled:
			#if !is_connected("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input"):
			#	connect("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input")
			
			visible = true
			pass
		else:
			#if is_connected("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input"):
			#	disconnect("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input")
			
			visible = false
			pass

##

func _unhandled_key_input(event):
	if event is InputEventKey:
		if _is_player_cursor_active and is_layout_enabled:
			
			#if !_is_player_cursor_gliding:
#			if event.is_action("ui_up") and !event.is_action_released("ui_up"):
#				_attempt_glide_cursor_from_current__to_up()
#
#			elif event.is_action("ui_down") and !event.is_action_released("ui_down"):
#				_attempt_glide_cursor_from_current__to_down()
#
#			elif event.is_action("ui_left") and !event.is_action_released("ui_left"):
#				_attempt_glide_cursor_from_current__to_left()
#
#			elif event.is_action("ui_right") and !event.is_action_released("ui_right"):
#				_attempt_glide_cursor_from_current__to_right()
#
			
			
			if event.is_action_pressed("ui_up"):
				_last_input_type = INPUT_TYPE__UP
				
			elif event.is_action_pressed("ui_down"):
				_last_input_type = INPUT_TYPE__DOWN
				
			elif event.is_action_pressed("ui_left"):
				_last_input_type = INPUT_TYPE__LEFT
				
			elif event.is_action_pressed("ui_right"):
				_last_input_type = INPUT_TYPE__RIGHT
				
			
			if event.is_action_released("ui_up"):
				if _last_input_type == INPUT_TYPE__UP:
					_last_input_type = INPUT_TYPE__NONE
			
			if event.is_action_released("ui_down"):
				if _last_input_type == INPUT_TYPE__DOWN:
					_last_input_type = INPUT_TYPE__NONE
			
			if event.is_action_released("ui_left"):
				if _last_input_type == INPUT_TYPE__LEFT:
					_last_input_type = INPUT_TYPE__NONE
			
			if event.is_action_released("ui_right"):
				if _last_input_type == INPUT_TYPE__RIGHT:
					_last_input_type = INPUT_TYPE__NONE
			
			
			##
			if event.is_action_released("ui_accept"):
				_attempt_enter_inside_current_tile()


func _process(delta):
	if SingletonsAndConsts.current_master.can_level_layout_move_cursor():
		if _input_delay > 0:
			_input_delay -= delta
		
		if _input_delay <= 0:
			if _is_player_cursor_active and is_layout_enabled:
				
				if _last_input_type == INPUT_TYPE__LEFT:
					_attempt_glide_cursor_from_current__to_left()
					_input_delay += INPUT_DELAY_AFTER_GLIDE
					
				elif _last_input_type == INPUT_TYPE__RIGHT:
					_attempt_glide_cursor_from_current__to_right()
					_input_delay += INPUT_DELAY_AFTER_GLIDE
					
				elif _last_input_type == INPUT_TYPE__UP:
					_attempt_glide_cursor_from_current__to_up()
					_input_delay += INPUT_DELAY_AFTER_GLIDE
					
				elif _last_input_type == INPUT_TYPE__DOWN:
					_attempt_glide_cursor_from_current__to_down()
					_input_delay += INPUT_DELAY_AFTER_GLIDE
					
				
				


#
#func _on_GUI_AbstractLevelLayout_gui_input(event):
#	if event is InputEventKey:
#		if _is_player_cursor_active:
#
#			if !_is_player_cursor_gliding:
#				if event.is_action("ui_up"):
#					_attempt_glide_cursor_from_current__to_up()
#
#				elif event.is_action("ui_down"):
#					_attempt_glide_cursor_from_current__to_down()
#
#				elif event.is_action("ui_left"):
#					_attempt_glide_cursor_from_current__to_left()
#
#				elif event.is_action("ui_right"):
#					_attempt_glide_cursor_from_current__to_right()
#
#
#			if event.is_action_released("ui_accept"):
#				_attempt_enter_inside_current_tile()
#
#
#

func _attempt_glide_cursor_from_current__to_up():
	var tile = _currently_hovered_tile.layout_element_tile__up
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_down():
	var tile = _currently_hovered_tile.layout_element_tile__down
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_left():
	var tile = _currently_hovered_tile.layout_element_tile__left
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_right():
	var tile = _currently_hovered_tile.layout_element_tile__right
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _if_can_hover_over_tile(tile) -> bool:
	return is_instance_valid(tile) and tile.is_hoverable_by_player_cursor()



func _attempt_enter_inside_current_tile():
	if SingletonsAndConsts.current_master.can_level_layout_do_action():
		if _currently_hovered_tile.level_details != null:
			emit_signal("prompt_entered_into_level", _currently_hovered_tile, _currently_hovered_layout_ele_id)
			
		elif _currently_hovered_tile.is_link_to_layout():
			emit_signal("prompt_entered_into_link_to_other_layout", _currently_hovered_tile, _currently_hovered_layout_ele_id)
			
	


#

func play_victory_animation_on_level_id(arg_id) -> bool:
	if _all_level_only_tile_ele__level_id_to_ele__map.has(arg_id):
		_start_show_stream_of_particles_from_center_of_ele(_all_level_only_tile_ele__level_id_to_ele__map[arg_id])
		return true
	else:
		return false


func _start_show_stream_of_particles_from_center_of_ele(arg_ele : GUI_LevelLayoutEle_Tile):
	_tile_ele_for_playing_victory_animation_for = arg_ele
	
	_current_burst_particle_summoned_count = 0
	
	var is_last = _show_before_burst_particle__and_other_actions()
	if !is_last:
		_before_burst_particle_counter_timer.start(BEFORE_BURST_PARTICLE__DELAY_PER_PARTICLE)


func _on_before_burst_particle_counter_timer_timeout():
	_show_before_burst_particle__and_other_actions()

func _show_before_burst_particle__and_other_actions() -> bool:
	var center_pos_of_ele = _tile_ele_for_playing_victory_animation_for.get_center_position()
	_create_before_burst_stream_particle(center_pos_of_ele)
	_create_before_burst_stream_particle(center_pos_of_ele)
	
	_current_burst_particle_summoned_count += 1
	if _current_burst_particle_summoned_count == BEFORE_BURST_PARTICLE__COUNT_FOR_TRIGGER_NEXT_PHASE:
		_trigger_circular_burst_on_curr_ele_for_victory()
	
	if _current_burst_particle_summoned_count >= BEFORE_BURST_PARTICLE__COUNT:
		_before_burst_particle_counter_timer.stop()
		return true
	else:
		return false

func _create_before_burst_stream_particle(arg_pos : Vector2):
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	particle.center_pos_of_basis = arg_pos
	particle.initial_speed_towards_center = -120
	particle.speed_accel_towards_center = -50
	particle.min_starting_distance_from_center = 15
	particle.max_starting_distance_from_center = 23
	particle.texture_to_use = StoreOfRNG.randomly_select_one_element(all_particles__level_unlock_before_burst_stream, StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL))
	particle.queue_free_at_end_of_lifetime = true
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.visible = true
	particle.lifetime = 0.4
	
	particle.lifetime_to_start_transparency = 0.2
	particle.transparency_per_sec = 1.0 / (particle.lifetime - particle.lifetime_to_start_transparency)
	
	particles_container.add_child(particle)



func _trigger_circular_burst_on_curr_ele_for_victory():
	_create_circular_burst_effect(_tile_ele_for_playing_victory_animation_for.get_center_position())
	
	emit_signal("triggered_circular_burst_on_curr_ele_for_victory", _tile_ele_for_playing_victory_animation_for, _tile_ele_for_playing_victory_animation_for.level_details)


func _create_circular_burst_effect(arg_pos : Vector2):
	gui_level_selection_whole_screen.play_circular_draw_node__circle_burst__for_victory(arg_pos)

#

func play_victory_animation_on_level_ids__as_additonals(arg_ids : Array) -> bool:
	var eles = []
	for id in arg_ids:
		if !_all_level_only_tile_ele__level_id_to_ele__map.has(id):
			return false
		else:
			eles.append(_all_level_only_tile_ele__level_id_to_ele__map[id])
	
	_start_show_stream_of_particles_from_center_of_eles__as_additionals(eles)
	return true


func _start_show_stream_of_particles_from_center_of_eles__as_additionals(arg_eles : Array):
	_tile_eles_to_play_additional_vic_animation_for = arg_eles
	
	_current_burst_particle_summon_loop_count__for_additonal = 0
	
	var is_last = _show_before_burst_particle__and_other_actions__for_additionals()
	if !is_last:
		_before_burst_particle_counter_timer__as_additionals.start(BEFORE_BURST_PARTICLE__DELAY_PER_PARTICLE)
	

func _on_before_burst_particle_counter_timer__as_additionals_timeout():
	_show_before_burst_particle__and_other_actions__for_additionals()
	

func _show_before_burst_particle__and_other_actions__for_additionals() -> bool:
	for ele in _tile_eles_to_play_additional_vic_animation_for:
		var center_pos_of_ele = ele.get_center_position()
		_create_before_burst_stream_particle(center_pos_of_ele)
		_create_before_burst_stream_particle(center_pos_of_ele)
	
	_current_burst_particle_summon_loop_count__for_additonal += 1
	if _current_burst_particle_summon_loop_count__for_additonal == BEFORE_BURST_PARTICLE__COUNT_FOR_TRIGGER_NEXT_PHASE:
		_trigger_circular_burst_on_curr_ele_for_victory__as_additionals()
	
	if _current_burst_particle_summon_loop_count__for_additonal >= BEFORE_BURST_PARTICLE__COUNT:
		_before_burst_particle_counter_timer__as_additionals.stop()
		return true
	else:
		return false

func _trigger_circular_burst_on_curr_ele_for_victory__as_additionals():
	for ele in _tile_eles_to_play_additional_vic_animation_for:
		_create_circular_burst_effect(ele.get_center_position())
	
	emit_signal("triggered_circular_burst_on_curr_ele_for_victory__as_additionals", _tile_eles_to_play_additional_vic_animation_for)


################################
##
################################

func _initialize_layout_ele_dependent_vars():
	for child in layout_elements_container.get_children():
		_rect_position_to_layout_ele_map[child.rect_global_position] = child
	
	for child in layout_elements_container.get_children():
		_init_signals_with_tile_ele(child)
		_configure_ele_tile_neighbors(child)
		_attempt_add_tile_ele_as_level_only_ele(child)
		_check_for_if_invis_by_default__and_do_appropriate_action(child)
	


func _init_signals_with_tile_ele(arg_ele_tile : GUI_LevelLayoutEle_Tile):
	arg_ele_tile.connect("tile_pressed", self, "_on_tile_pressed", [arg_ele_tile])

func _on_tile_pressed(arg_ele_tile : GUI_LevelLayoutEle_Tile):
	if _if_can_hover_over_tile(arg_ele_tile):
		if _currently_hovered_tile != arg_ele_tile:
			_instant_place_cursor_at_layout_ele(arg_ele_tile)
		else:
			_attempt_enter_inside_current_tile()


func _configure_ele_tile_neighbors(arg_ele_tile : GUI_LevelLayoutEle_Tile):
	var neighoring_poses = _get_four_neighboring_poses_from_center(arg_ele_tile.rect_global_position)
	for pos in neighoring_poses.keys():
		if _rect_position_to_layout_ele_map.has(pos):
			var direction_identif : int = neighoring_poses[pos]
			var layout_ele_at_direction : GUI_LevelLayoutEle_Tile = _rect_position_to_layout_ele_map[pos]
			
			if direction_identif == ELE_TILE_DIR__LEFT:
				arg_ele_tile.layout_element_tile__left = layout_ele_at_direction
				
			elif direction_identif == ELE_TILE_DIR__RIGHT:
				arg_ele_tile.layout_element_tile__right = layout_ele_at_direction
				
			elif direction_identif == ELE_TILE_DIR__UP:
				arg_ele_tile.layout_element_tile__up = layout_ele_at_direction
				
			elif direction_identif == ELE_TILE_DIR__DOWN:
				arg_ele_tile.layout_element_tile__down = layout_ele_at_direction
				
			


# 1 = left, 2 = right, 3 = up, 4 = down
func _get_four_neighboring_poses_from_center(arg_pos : Vector2):
	var map = {}
	
	map[Vector2(arg_pos.x - TILE_WIDTH, arg_pos.y)] = ELE_TILE_DIR__LEFT
	map[Vector2(arg_pos.x + TILE_WIDTH, arg_pos.y)] = ELE_TILE_DIR__RIGHT
	map[Vector2(arg_pos.x, arg_pos.y - TILE_WIDTH)] = ELE_TILE_DIR__UP
	map[Vector2(arg_pos.x, arg_pos.y + TILE_WIDTH)] = ELE_TILE_DIR__DOWN
	
	return map
	#var bucket = []
	#bucket.append(Vector2(arg_pos.x + TILE_WIDTH, arg_pos.y))
	#bucket.append(Vector2(arg_pos.x - TILE_WIDTH, arg_pos.y))
	#bucket.append(Vector2(arg_pos.x, arg_pos.y + TILE_WIDTH))
	#bucket.append(Vector2(arg_pos.x, arg_pos.y - TILE_WIDTH))
	#return bucket



func _attempt_add_tile_ele_as_level_only_ele(arg_ele : GUI_LevelLayoutEle_Tile):
	if arg_ele.is_link_to_level():
		_all_level_only_tile_ele__level_id_to_ele__map[arg_ele.level_details.level_id] = arg_ele


func _check_for_if_invis_by_default__and_do_appropriate_action(arg_ele : GUI_LevelLayoutEle_Tile):
	if arg_ele.is_layout_element_invis_by_default:
		if GameSaveManager.is_layout_id__layout_element_id_invis__val_registered(level_layout_id, arg_ele.layout_ele_id):
			var is_invis = GameSaveManager.get_layout_id__layout_element_id__is_invis(level_layout_id, arg_ele.layout_ele_id)
			arg_ele.is_layout_element_invis = is_invis
		else:
			arg_ele.is_layout_element_invis = arg_ele.is_layout_element_invis_by_default
			GameSaveManager.set_layout_id__layout_element_id__is_invis(level_layout_id, arg_ele.layout_ele_id, arg_ele.is_layout_element_invis)
	


#######

#func set_gui_level_selection_whole_screen(arg_gui):
#	gui_level_selection_whole_screen = arg_gui
#	_overridable__setup_game_background()

func _overridable__setup_game_background(arg_is_instant_in_transition):
	var level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(level_layout_id)
	game_background.set_current_background_type(level_layout_details.background_type, arg_is_instant_in_transition)
	

