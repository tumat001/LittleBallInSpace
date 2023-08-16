extends "res://ObjectsRelated/Objects/BaseObject.gd"


const TILESET_COLOR__BLUE = Color(98/255.0, 78/255.0, 253/255.0)
const TILESET_COLOR__RED = Color(253/255.0, 77/255.0, 79/255.0)
const TILESET_COLOR__GREEN = Color(77/255.0, 253/255.0, 120/255.0)


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


##

export(bool) var is_pressed : bool = false setget set_is_pressed
var _is_in_press_transition : bool = false

export(bool) var can_be_triggered_by_players : bool = true setget set_can_be_triggered_by_players
export(bool) var can_be_triggered_by_tiles : bool = false setget set_can_be_triggered_by_tiles


enum ButtonColor {
	RED,
	GREEN,
	BLUE,
}
export(ButtonColor) var button_color : int = ButtonColor.BLUE setget set_button_color


export(int) var pressable_count : int = 1 setget set_pressable_count

#

var _is_in_ready : bool

##

const ANIM_NAME__BASE__BLUE_OFF = "blue_off"
const ANIM_NAME__BASE__BLUE_ON = "blue_on"
const ANIM_NAME__BASE__GREEN_OFF = "green_off"
const ANIM_NAME__BASE__GREEN_ON = "green_on"
const ANIM_NAME__BASE__RED_OFF = "red_off"
const ANIM_NAME__BASE__RED_ON = "red_on"


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
	
	if pressable_count != 0 or _is_in_ready:
		is_pressed = arg_val
	
	if is_inside_tree():
		if old_val != is_pressed:
			if pressable_count != 0:
				if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
					for tileset in _tilesets_to_toggle_to_is_reverse_map.keys():
						if is_instance_valid(tileset):
							var is_reverse = _tilesets_to_toggle_to_is_reverse_map[tileset]
							
							_press_on_tileset(tileset, is_reverse)
						
					
					#
					
					_is_in_press_transition = true
					
					var button_pos_tweener = create_tween()
					var coll_shape_tweener = create_tween()
					button_pos_tweener.set_parallel(false)
					if is_pressed:
						button_pos_tweener.tween_property(button_container, "position:y", BUTTON_CONTAINER_Y_POS__PRESSED, BUTTON_CONTAINER_Y_CHANGE_DURATION)
						coll_shape_tweener.tween_property(collision_shape_2d_02, "position:y", BUTTON_CONTAINER_Y_POS__PRESSED - coll_shape_button_blocker_y_pos_diff_from_button, BUTTON_CONTAINER_Y_CHANGE_DURATION)
						
					else:
						button_pos_tweener.tween_property(button_container, "position:y", BUTTON_CONTAINER_Y_POS__NOT_PRESSED, BUTTON_CONTAINER_Y_CHANGE_DURATION)
						coll_shape_tweener.tween_property(collision_shape_2d_02, "position:y", BUTTON_CONTAINER_Y_POS__NOT_PRESSED - coll_shape_button_blocker_y_pos_diff_from_button, BUTTON_CONTAINER_Y_CHANGE_DURATION)
					
					button_pos_tweener.tween_callback(self, "_on_button_pos_change_finished")
					
					#
					
					AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_SwitchToggle_01, global_position, 1.0, null)
					
					
				else:
					if is_pressed:
						button_container.position.y = BUTTON_CONTAINER_Y_POS__PRESSED
						collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
						
					else:
						button_container.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED
						collision_shape_2d_02.position.y = BUTTON_CONTAINER_Y_POS__NOT_PRESSED - coll_shape_button_blocker_y_pos_diff_from_button
						
				
				
	
	_update_button_display()

func _on_button_pos_change_finished():
	_is_in_press_transition = false


##

func set_button_color(arg_color):
	button_color = arg_color
	
	var color
	if button_color == ButtonColor.BLUE:
		color = TILESET_COLOR__BLUE
	elif button_color == ButtonColor.GREEN:
		color = TILESET_COLOR__GREEN
	elif button_color == ButtonColor.RED:
		color = TILESET_COLOR__RED
	
	for tileset in _tilesets_to_toggle_to_is_reverse_map.keys():
		tileset.set_modulate_for_tilemap(tileset.TilemapModulateIds.BUTTON_ASSOCIATED, color)
	
	#
	
	_update_button_display()

func _update_button_display():
	if is_inside_tree():
		if button_color == ButtonColor.RED:
			button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Red.png")
			if is_pressed:
				base_sprite.play("red_on")
				
			else:
				base_sprite.play("red_off")
				
			
		elif button_color == ButtonColor.GREEN:
			button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Green.png")
			if is_pressed:
				base_sprite.play("green_on")
				
			else:
				base_sprite.play("green_off")
				
			
		elif button_color == ButtonColor.BLUE:
			button_sprite.texture = preload("res://ObjectsRelated/Objects/Imps/InteractableButton/Assets/InteractableButton_MultiUse_Blue.png")
			if is_pressed:
				base_sprite.play("blue_on")
				
			else:
				base_sprite.play("blue_off")
				
			
	

#

func set_pressable_count(arg_val):
	pressable_count = arg_val
	
	if is_inside_tree():
		use_count_label.text = str(arg_val)
	


#

func _ready():
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
	
	_is_in_ready = false

#
# meant to be used at the start, and not changed
func add_tileset_to_toggle_to_is_reverse_map(arg_tileset, arg_is_reversed):
	_tilesets_to_toggle_to_is_reverse_map[arg_tileset] = arg_is_reversed
	
	var color
	if button_color == ButtonColor.BLUE:
		color = TILESET_COLOR__BLUE
	elif button_color == ButtonColor.GREEN:
		color = TILESET_COLOR__GREEN
	elif button_color == ButtonColor.RED:
		color = TILESET_COLOR__RED
	arg_tileset.set_modulate_for_tilemap(arg_tileset.TilemapModulateIds.BUTTON_ASSOCIATED, color)
	
	arg_tileset.make_tileset_rewindable()
	
	#_press_on_tileset(arg_tileset, arg_is_reversed)


func _press_on_tileset(arg_tileset, arg_is_reversed):
	if pressable_count > 0:
		arg_tileset.toggle_fill_to_unfilled_and_vise_versa()
		set_pressable_count(pressable_count - 1)
	
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
	if !_is_in_press_transition:
		set_is_pressed(!is_pressed)
	


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



func stared_rewind():
	.stared_rewind()
	
	collision_shape_2d_02.set_deferred("disabled", true)
	
	button_collision_shape_2d.set_deferred("disabled", true)


func ended_rewind():
	.ended_rewind()
	
	collision_shape_2d_02.set_deferred("disabled", false)
	
	button_collision_shape_2d.set_deferred("disabled", false)

