tool
extends Node2D

#

signal start_display_finished()

#

const MODULATE_INACTIVE := Color("#00CCCCCC")
const MODULATE_ACTIVE := Color("#CCCCCC")

const TEX_REC_BACKGROUND__MODULATE_INACTIVE := Color("#A4A4A4")
const TEX_REC_BACKGROUND__MODULATE_ACTIVE := Color("#00A4A4A4")

#

var is_start_display_finished : bool


export(bool) var use_tweener_to_start : bool = true
export(float) var tween_start_duration : float = 0.65

export(bool) var start_at_ready : bool = false

#

export(float) var snap_rotation_per_sec__deg : float = 0.0 setget set_snap_rotation_per_sec__deg
export(float) var snap_rotation_threshold__deg : float = 90.0
var _rot_below_snap : float

#

export(NodePath) var node_path_for_tex_rect_background : NodePath setget set_node_path_for_tex_rect_background

var _tex_rect_background : TextureRect
var _tex_rect_background__modulate_inactive : Color
var _tex_rect_background__modulate_active : Color


#

export(NodePath) var node_path__node_with_modulate_to_match__01 : NodePath setget set_node_path__node_with_modulate_to_match_01__as_inactive

var _node_to_match_modulate_a__01

#

func _ready() -> void:
	set_node_path_for_tex_rect_background(node_path_for_tex_rect_background)
	
	
	if Engine.editor_hint:
		return
	
	modulate = MODULATE_INACTIVE
	
	
	if start_at_ready:
		start_display()
	_update_can_do_process_based_on_vals()

##

func start_display():
	if use_tweener_to_start:
		_start_display__using_tweener()
	else:
		_start_display__using_instant_start()

#

func _start_display__using_tweener():
	var tweener = create_tween()
	tweener.set_parallel(true)
	
	tweener.tween_property(self, "modulate", MODULATE_ACTIVE, tween_start_duration)
	if is_instance_valid(_node_to_match_modulate_a__01):
		tweener.tween_property(_node_to_match_modulate_a__01, "modulate:a", 1.0, tween_start_duration)
	if is_instance_valid(_tex_rect_background):
		tweener.tween_property(_tex_rect_background, "modulate", _tex_rect_background__modulate_active, tween_start_duration)
	
	tweener.set_parallel(false)
	
	tweener.tween_callback(self, "_on_tween_start_display_finished")
	

func _on_tween_start_display_finished():
	_start_display__using_instant_start()


func _start_display__using_instant_start():
	is_start_display_finished = true
	modulate = MODULATE_ACTIVE
	if is_instance_valid(_tex_rect_background):
		_tex_rect_background.modulate = _tex_rect_background__modulate_active
	if is_instance_valid(_node_to_match_modulate_a__01):
		_node_to_match_modulate_a__01.modulate.a = 1.0
	emit_signal("start_display_finished")


##

func set_snap_rotation_per_sec__deg(arg_val):
	snap_rotation_per_sec__deg = arg_val
	
	_update_can_do_process_based_on_vals()

func _update_can_do_process_based_on_vals():
	set_process(!Engine.editor_hint and abs(snap_rotation_per_sec__deg) > 0 and is_start_display_finished)


func _process(delta: float) -> void:
	_rot_below_snap += (delta * snap_rotation_per_sec__deg)
	if abs(_rot_below_snap) >= abs(snap_rotation_threshold__deg):  #yes, i used if, not while
		rotate(deg2rad(snap_rotation_threshold__deg))
		_rot_below_snap -= snap_rotation_threshold__deg
	


###############

func set_node_path_for_tex_rect_background(arg_path):
	node_path_for_tex_rect_background = arg_path
	var tex_rect_background = get_node_or_null(arg_path)
	
	if is_instance_valid(tex_rect_background):
		pair_with_texture_rect_for_modulate__as_inactive(tex_rect_background)

func pair_with_texture_rect_for_modulate__as_inactive(arg_texture_rect : TextureRect, 
		arg_mod_inactive : Color = TEX_REC_BACKGROUND__MODULATE_INACTIVE, arg_mod_active = TEX_REC_BACKGROUND__MODULATE_ACTIVE):
	
	_tex_rect_background = arg_texture_rect
	_tex_rect_background__modulate_inactive = arg_mod_inactive
	_tex_rect_background__modulate_active = arg_mod_active
	
	_tex_rect_background.modulate = TEX_REC_BACKGROUND__MODULATE_INACTIVE
	

##

func set_node_path__node_with_modulate_to_match_01__as_inactive(arg_node_path):
	node_path__node_with_modulate_to_match__01 = arg_node_path
	_node_to_match_modulate_a__01 = get_node_or_null(arg_node_path)
	
	if !Engine.editor_hint:
		if is_instance_valid(_node_to_match_modulate_a__01):
			_node_to_match_modulate_a__01.modulate.a = 0.0
	
