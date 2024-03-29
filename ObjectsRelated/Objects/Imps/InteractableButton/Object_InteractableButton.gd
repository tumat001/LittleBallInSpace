tool
extends "res://ObjectsRelated/Objects/BaseObject.gd"



signal pressed(arg_is_pressed)

#

#const TILESET_COLOR__BLUE = Color(1/255.0, 1/255.0, 255/255.0) #Color(28/255.0, 18/255.0, 253/255.0)
const TILESET_COLOR__BLUE = Color("#1274ff")
const TILESET_COLOR__RED = Color("#ff2424") #Color(253/255.0, 17/255.0, 19/255.0)
const TILESET_COLOR__GREEN = Color("#1cff09") #Color(17/255.0, 253/255.0, 19/255.0)
const TILESET_COLOR__YELLOW = Color("#FFDC70")
const TILESET_COLOR__GRAY = Color("#B8B8B8")
const TILESET_COLOR__VIOLET = Color("#9500DB")

const BUTTON_CONTAINER_Y_CHANGE_DURATION : float = 0.5
const BUTTON_CONTAINER_Y_POS__NOT_PRESSED = -16.0
const BUTTON_CONTAINER_Y_POS__PRESSED = -7.0


#

var coll_shape_button_blocker_y_pos_diff_from_button : float 

# meant to be used at the start, and not changed
# if changable, make it rewind compatible
#
# if reverse is false: press means unfilled
# if reverse is true: press means filled
var _tilesets_to_toggle_to_is_reverse_map : Dictionary

# for convenience
export(NodePath) var tileset_01_to_register_in_toggle__path
export(bool) var tileset_01_to_register_in_toggle__is_reversed : bool = false
onready var tileset_01_to_register_in_toggle = get_node_or_null(tileset_01_to_register_in_toggle__path)
# for convenience
export(NodePath) var tileset_02_to_register_in_toggle__path
export(bool) var tileset_02_to_register_in_toggle__is_reversed : bool = false
onready var tileset_02_to_register_in_toggle = get_node_or_null(tileset_02_to_register_in_toggle__path)

########

var _portals_to_toggle : Array

# for convenience
export(NodePath) var portal_01_to_register_in_toggle__path
onready var portal_01_to_register_in_toggle = get_node_or_null(portal_01_to_register_in_toggle__path)
# for convenience
export(NodePath) var portal_02_to_register_in_toggle__path
onready var portal_02_to_register_in_toggle = get_node_or_null(portal_02_to_register_in_toggle__path)


##

var _ball_dispensers_to_toggle : Array

# for convenience
export(NodePath) var ball_dispenser_01_to_register_in_toggle__path
onready var ball_dispenser_01_to_register_in_toggle = get_node_or_null(ball_dispenser_01_to_register_in_toggle__path)
# for convenience
export(NodePath) var ball_dispenser_02_to_register_in_toggle__path
onready var ball_dispenser_02_to_register_in_toggle = get_node_or_null(ball_dispenser_02_to_register_in_toggle__path)



##

export(bool) var is_pressed : bool = false setget set_is_pressed
var _is_in_press_transition : bool = false

export(bool) var can_be_triggered_by_players : bool = true setget set_can_be_triggered_by_players
export(bool) var can_be_triggered_by_tiles : bool = false setget set_can_be_triggered_by_tiles


enum ButtonColor {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
	
	GRAY = 3,
	
	YELLOW = 4,
	VIOLET = 5,
}
export(ButtonColor) var button_color : int = ButtonColor.BLUE setget set_button_color


export(int) var pressable_count : int = 1 setget set_pressable_count

#

var _is_in_ready : bool
var force_update_pressed_state : bool = false

var _button_pos_tweener
var _coll_shape_tweener

#

var is_class_type_object_interactable_button : bool = true

var can_play_sound : bool = true

##

#const ANIM_NAME__BASE__BLUE_OFF = "blue_off"
#const ANIM_NAME__BASE__BLUE_ON = "blue_on"
#const ANIM_NAME__BASE__GREEN_OFF = "green_off"
#const ANIM_NAME__BASE__GREEN_ON = "green_on"
#const ANIM_NAME__BASE__RED_OFF = "red_off"
#const ANIM_NAME__BASE__RED_ON = "red_on"
#const ANIM_NAME__BASE__YELLOW_OFF = "yellow_off"
#const ANIM_NAME__BASE__YELLOW_ON = "yellow_on"
#const ANIM_NAME__BASE__GRAY_OFF = "gray_off"
#const ANIM_NAME__BASE__GRAY_ON = "gray_on"


onready var button_sprite = $ButtonContainer/Button
onready var base_sprite = $AnimatedSprite

onready var button_container = $ButtonContainer

onready var collision_shape_2d_02 = $CollisionShape2D2
onready var button_collision_shape_2d = $ButtonContainer/ButtonArea2D/ButtonCollisionShape2D
onready var button_area_2d = $ButtonContainer/ButtonArea2D

onready var use_count_label = $UseCountLabel

######


func set_is_pressed(arg_val):
	var old_val = is_pressed
	
	if pressable_count != 0 or (_is_in_ready or force_update_pressed_state):
		is_pressed = arg_val
	
	if is_inside_tree():
		if old_val != is_pressed or (_is_in_ready or force_update_pressed_state):
			if pressable_count != 0 or (_is_in_ready or force_update_pressed_state):
				if !SingletonsAndConsts.current_rewind_manager.is_rewinding and !_is_in_ready:
					for tileset in _tilesets_to_toggle_to_is_reverse_map.keys():
						if is_instance_valid(tileset):
							var is_reverse = _tilesets_to_toggle_to_is_reverse_map[tileset]
							
							_press_on_tileset(tileset, is_reverse)
					
					for portal in _portals_to_toggle:
						if is_instance_valid(portal):
							_press_on_portal(portal)
					
					for ball_dispenser in _ball_dispensers_to_toggle:
						if is_instance_valid(ball_dispenser):
							_press_on_ball_dispenser(ball_dispenser)
					
					if !(_is_in_ready or force_update_pressed_state):
						set_pressable_count(pressable_count - 1)
					
					#
					
					_is_in_press_transition = true
					
					#
					
					if _button_pos_tweener != null:
						_button_pos_tweener.kill()
						_is_in_press_transition = false
					if _coll_shape_tweener != null:
						_coll_shape_tweener.kill()
						_is_in_press_transition = false
					
					
					if !(_is_in_ready or force_update_pressed_state):
						_button_pos_tweener = create_tween()
						_coll_shape_tweener = create_tween()
						_button_pos_tweener.set_parallel(false)
						_coll_shape_tweener.set_parallel(false)
						if is_pressed:
							_button_pos_tweener.tween_property(button_container, "position:y", BUTTON_CONTAINER_Y_POS__PRESSED, BUTTON_CONTAINER_Y_CHANGE_DURATION)
							_coll_shape_tweener.tween_property(collision_shape_2d_02, "position:y", BUTTON_CONTAINER_Y_POS__PRESSED - coll_shape_button_blocker_y_pos_diff_from_button, BUTTON_CONTAINER_Y_CHANGE_DURATION)
							
						else:
							_button_pos_tweener.tween_property(button_container, "position:y", BUTTON_CONTAINER_Y_POS__NOT_PRESSED, BUTTON_CONTAINER_Y_CHANGE_DURATION)
							_coll_shape_tweener.tween_property(collision_shape_2d_02, "position:y", BUTTON_CONTAINER_Y_POS__NOT_PRESSED - coll_shape_button_blocker_y_pos_diff_from_button, BUTTON_CONTAINER_Y_CHANGE_DURATION)
						
						_button_pos_tweener.tween_callback(self, "_on_button_pos_change_finished")
						_coll_shape_tweener.tween_callback(self, "_on_button_pos_change_finished__coll_shape")
						
						_is_in_press_transition = true
						
						if can_play_sound:
							AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_SwitchToggle_01, global_position, 1.0, null)
						
						
					else:
						if is_pressed:
							button_container.position.y = BUTTON_CONTAINER_Y_POS__PRESSED
							collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
						else:
							button_container.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED
							collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
						
						_is_in_press_transition = false
					
					
				else:
					if _button_pos_tweener != null:
						_button_pos_tweener.kill()
						_is_in_press_transition = false
					if _coll_shape_tweener != null:
						_coll_shape_tweener.kill()
						_is_in_press_transition = false
					
					if is_pressed:
						button_container.position.y = BUTTON_CONTAINER_Y_POS__PRESSED
						collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
						
					else:
						
						button_container.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED
						collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
					
				
		
	
	_update_button_display()
	emit_signal("pressed", is_pressed)

func _on_button_pos_change_finished():
	_is_in_press_transition = false
	_button_pos_tweener = null

func _on_button_pos_change_finished__coll_shape():
	_coll_shape_tweener = null
	

##

func set_button_color(arg_color):
	button_color = arg_color
	
	var color = _get_tileset_color_associated_with_button_color_id(button_color)
	
	if !Engine.editor_hint:
		for tileset in _tilesets_to_toggle_to_is_reverse_map.keys():
			tileset.set_modulate_for_tilemap(tileset.TilemapModulateIds.BUTTON_ASSOCIATED, color)
		
		for portal in _portals_to_toggle:
			portal.set_portal_color(button_color)
		
		for ball_dispenser in _ball_dispensers_to_toggle:
			ball_dispenser.set_dispenser_color(button_color)
	
	#
	
	_update_button_display()

func _get_tileset_color_associated_with_button_color_id(arg_button_color):
	var color = -1
	
	match arg_button_color:
		ButtonColor.BLUE:
			color = TILESET_COLOR__BLUE
		ButtonColor.GREEN:
			color = TILESET_COLOR__GREEN
		ButtonColor.RED:
			color = TILESET_COLOR__RED
		ButtonColor.YELLOW:
			color = TILESET_COLOR__YELLOW
		ButtonColor.GRAY:
			color = TILESET_COLOR__GRAY
		ButtonColor.VIOLET:
			color = TILESET_COLOR__VIOLET
	
	return color


func _update_button_display():
	if is_inside_tree():
		match button_color:
			ButtonColor.RED:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Red.png")
				if is_pressed:
					base_sprite.play("red_on")
				else:
					base_sprite.play("red_off")
				
				
			ButtonColor.GREEN:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Green.png")
				if is_pressed:
					base_sprite.play("green_on")
				else:
					base_sprite.play("green_off")
				
				
			ButtonColor.BLUE:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Blue.png")
				if is_pressed:
					base_sprite.play("blue_on")
				else:
					base_sprite.play("blue_off")
				
				
			ButtonColor.YELLOW:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Yellow.png")
				if is_pressed:
					base_sprite.play("yellow_on")
				else:
					base_sprite.play("yellow_off")
				
				
			ButtonColor.GRAY:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Gray.png")
				if is_pressed:
					base_sprite.play("gray_on")
				else:
					base_sprite.play("gray_off")
				
			ButtonColor.VIOLET:
				button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Violet.png")
				if is_pressed:
					base_sprite.play("violet_on")
				else:
					base_sprite.play("violet_off")
				

#

func set_pressable_count(arg_val):
	pressable_count = arg_val
	
	if is_inside_tree():
		use_count_label.text = str(arg_val)


#

func _ready():
	
	if Engine.editor_hint:
		set_button_color(button_color)
		return
	
	#
	
	_is_in_ready = true
	
	coll_shape_button_blocker_y_pos_diff_from_button = button_container.position.y - collision_shape_2d_02.position.y
	# order matters
	set_pressable_count(pressable_count)
	set_is_pressed(is_pressed)
	#
	set_button_color(button_color)
	
	if is_instance_valid(tileset_01_to_register_in_toggle):
		add_tileset_to_toggle_to_is_reverse_map(tileset_01_to_register_in_toggle, tileset_01_to_register_in_toggle__is_reversed)
	if is_instance_valid(tileset_02_to_register_in_toggle):
		add_tileset_to_toggle_to_is_reverse_map(tileset_02_to_register_in_toggle, tileset_02_to_register_in_toggle__is_reversed)
	
	set_can_be_triggered_by_players(can_be_triggered_by_players)
	set_can_be_triggered_by_tiles(can_be_triggered_by_tiles)
	
	if is_instance_valid(portal_01_to_register_in_toggle):
		add_portal_to_toggle_on_press(portal_01_to_register_in_toggle)
	if is_instance_valid(portal_02_to_register_in_toggle):
		add_portal_to_toggle_on_press(portal_02_to_register_in_toggle)
	
	
	if is_instance_valid(ball_dispenser_01_to_register_in_toggle):
		add_ball_dispenser_to_toggle_on_press(ball_dispenser_01_to_register_in_toggle)
	if is_instance_valid(ball_dispenser_02_to_register_in_toggle):
		add_ball_dispenser_to_toggle_on_press(ball_dispenser_02_to_register_in_toggle)
	
	
	_is_in_ready = false

#
# meant to be used at the start, and not changed
func add_tileset_to_toggle_to_is_reverse_map(arg_tileset, arg_is_reversed):
	_tilesets_to_toggle_to_is_reverse_map[arg_tileset] = arg_is_reversed
	
	var color = _get_tileset_color_associated_with_button_color_id(button_color)
	
	arg_tileset.set_modulate_for_tilemap(arg_tileset.TilemapModulateIds.BUTTON_ASSOCIATED, color)
	
	arg_tileset.make_tileset_rewindable()
	
	#_press_on_tileset(arg_tileset, arg_is_reversed)


func _press_on_tileset(arg_tileset, arg_is_reversed):
	if pressable_count > 0:
		#arg_tileset.toggle_fill_to_unfilled_and_vise_versa()
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			_start_wait_tween__to_toggle(arg_tileset)
		else:
			arg_tileset.toggle_fill_to_unfilled_and_vise_versa()
		
		

func _start_wait_tween__to_toggle(arg_tileset):
	var tween = create_tween()
	tween.tween_callback(self, "_on_wait_finished__to_toggle_tileset", [arg_tileset]).set_delay(0.1)
	
	SingletonsAndConsts.current_rewind_manager.add_node_to_block_rewind_cast(self)

func _on_wait_finished__to_toggle_tileset(arg_tileset):
	if is_instance_valid(arg_tileset):
		arg_tileset.toggle_fill_to_unfilled_and_vise_versa()
		
		SingletonsAndConsts.current_rewind_manager.remove_node_from_block_rewind_cast(self)

#	if is_pressed:
#		if arg_is_reversed:
#			arg_tileset.convert_all_unfilled_tiles_to_filled()
#		else:
#			arg_tileset.convert_all_filled_tiles_to_unfilled()
#
#	else:
#		if arg_is_reversed:
#			arg_tileset.convert_all_filled_tiles_to_unfilled()
#		else:
#			arg_tileset.convert_all_unfilled_tiles_to_filled()
#
	

#

func set_can_be_triggered_by_players(arg_val):
	can_be_triggered_by_players = arg_val
	
	if is_inside_tree():
		if can_be_triggered_by_players:
			button_area_2d.set_collision_mask_bit(0, true)
			
		else:
			button_area_2d.set_collision_mask_bit(0, false)

func set_can_be_triggered_by_tiles(arg_val):
	can_be_triggered_by_tiles = arg_val
	
	if is_inside_tree():
		if can_be_triggered_by_tiles:
			button_area_2d.set_collision_mask_bit(3, true)
			
		else:
			button_area_2d.set_collision_mask_bit(3, false)
			

########

func _on_ButtonArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print(_is_in_press_transition)
	
	if !_is_in_press_transition:
		if !body.get("is_class_type_object_tile_fragment"):
			set_is_pressed(!is_pressed)
			
	

#########

func add_portal_to_toggle_on_press(arg_portal):
	if !_portals_to_toggle.has(arg_portal):
		_portals_to_toggle.append(arg_portal)
	
	arg_portal.set_portal_color(button_color)

func _press_on_portal(arg_portal):
	arg_portal.toggle_is_disabled()


##########

func add_ball_dispenser_to_toggle_on_press(arg_dispenser):
	if !_ball_dispensers_to_toggle.has(arg_dispenser):
		_ball_dispensers_to_toggle.append(arg_dispenser)
	
	arg_dispenser.set_dispenser_color(button_color)

func _press_on_ball_dispenser(arg_dispenser):
	arg_dispenser.attempt_trigger_and_spawn_ball()


#############################################


func get_rewind_save_state():
	var save_state = .get_rewind_save_state()
	
	save_state["pressable_count"] = pressable_count
	save_state["is_pressed"] = is_pressed
	
	return save_state

func load_into_rewind_save_state(arg_state):
	.load_into_rewind_save_state(arg_state)
	
	# order matters
	set_pressable_count(arg_state["pressable_count"])
	set_is_pressed(arg_state["is_pressed"])
	
	if body_mode_to_use == BodyMode.RIGID:
		rotation = _rewinded__transform.get_rotation()


func started_rewind():
	.started_rewind()
	
	collision_shape_2d_02.set_deferred("disabled", true)
	button_collision_shape_2d.set_deferred("disabled", true)


func ended_rewind():
	.ended_rewind()
	
	collision_shape_2d_02.set_deferred("disabled", false)
	button_collision_shape_2d.set_deferred("disabled", false)

