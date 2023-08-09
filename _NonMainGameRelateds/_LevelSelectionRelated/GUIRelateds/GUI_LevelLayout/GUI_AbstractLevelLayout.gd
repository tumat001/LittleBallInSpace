extends Control

const GUI_LevelLayoutEle_Tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.gd")

#

const TILE_WIDTH : int = 46

#

signal prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)
signal prompt_entered_into_link_to_other_layout(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)

signal currently_hovered_layout_ele_changed(arg_id, arg_currently_hovered_tile)

##

var level_layout_id

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
	
	_initialize_layout_ele_adjacencies()
	#call_deferred("_initialize_layout_ele_adjacencies")

#

func _init_id_to_layout_ele_map():
	for child in layout_elements_container.get_children():
		_assign_layout_ele_next_available_id(child)
	

func _assign_layout_ele_next_available_id(arg_ele):
	_id_to_layout_ele_map[_next_available_id] = arg_ele
	_layout_ele_to_id_map[arg_ele] = _next_available_id
	
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
			_instant_place_cursor_at_layout_ele_id(arg_ele_id)

func _summon_cursor_at_appropriate_loc():
	if layout_ele_id_to_summon_cursor_to == NO_CURSOR:
		_set_is_player_cursor_active(false)
		return
		
	elif layout_ele_id_to_summon_cursor_to == UNINITIALIZED_CURSOR:
		var node = get_node(default_node_to_summon_cursor_on__for_first_time__path)
		_instant_place_cursor_at_layout_ele(node)
		_set_is_player_cursor_active(true)
		
	else:
		_set_is_player_cursor_active(true)
		


func _instant_place_cursor_at_layout_ele_id(arg_id):
	var ele
	if arg_id == UNINITIALIZED_CURSOR:
		ele = get_node(default_node_to_summon_cursor_on__for_first_time__path)
	elif arg_id == NO_CURSOR:
		pass
	else:
		 ele = _id_to_layout_ele_map[arg_id]
	
	if ele != null:
		_instant_place_cursor_at_layout_ele(ele)

func _instant_place_cursor_at_layout_ele(arg_ele : Control):
	#player_cursor.rect_global_position = arg_ele.rect_global_position
	player_cursor.rect_global_position = _get_adjusted_cursor_pos__based_on_pos(arg_ele)
	
	_assign_layout_ele_as_current_hovered(arg_ele)

func _get_adjusted_cursor_pos__based_on_pos(arg_ele : Control):
	var arg_ele_size : Vector2 = arg_ele.rect_size
	var arg_ele_pos : Vector2 = arg_ele.rect_global_position
	
	var cursor_size = player_cursor.rect_size
	var diff = (cursor_size - arg_ele_size) / 2
	
	return arg_ele_pos - diff


func _assign_layout_ele_as_current_hovered(arg_ele):
	_currently_hovered_layout_ele_id = _layout_ele_to_id_map[arg_ele]
	_currently_hovered_tile = arg_ele
	
	GameSaveManager.last_hovered_over_level_layout_element_id = _currently_hovered_layout_ele_id
	
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
			pass
		else:
			#if is_connected("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input"):
			#	disconnect("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input")
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
	if _currently_hovered_tile.level_details != null:
		emit_signal("prompt_entered_into_level", _currently_hovered_tile, _currently_hovered_layout_ele_id)
		
	elif _currently_hovered_tile.is_link_to_another_layout():
		emit_signal("prompt_entered_into_link_to_other_layout", _currently_hovered_tile, _currently_hovered_layout_ele_id)
		
	


################################
##
################################

func _initialize_layout_ele_adjacencies():
	for child in layout_elements_container.get_children():
		_rect_position_to_layout_ele_map[child.rect_global_position] = child
		
	
	for child in layout_elements_container.get_children():
		_configure_ele_tile_neighbors(child)
		

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





