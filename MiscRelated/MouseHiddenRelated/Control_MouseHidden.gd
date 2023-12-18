extends Control


export(float) var outer_ring__radius_start_of_reveal : float = 100 setget set_outer_ring__radius_start_of_reveal
export(float) var inner_ring__radius_max_reveal : float = 50 setget set_inner_ring__radius_max_reveal

export(float) var mod_a__outside_of_outer_ring : float = 0.0
export(float) var mod_a__inside_of_outer_ring : float = 0.0
export(float) var mod_a__inside_of_inner_ring : float = 1.0


export(bool) var activate_on_ready : bool = true

#

var _tween_for_intervalue : SceneTreeTween

#

func _init():
	_tween_for_intervalue = SceneTreeTween.new()

#


func set_outer_ring__radius_start_of_reveal(arg_val):
	outer_ring__radius_start_of_reveal = arg_val
	
	if Engine.editor_hint:
		update()

func set_inner_ring__radius_max_reveal(arg_val):
	inner_ring__radius_max_reveal = arg_val
	
	if Engine.editor_hint:
		update()


func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0, 0), outer_ring__radius_start_of_reveal, 0, PI*2, 64, Color(0, 0, 1), 3)
		draw_arc(Vector2(0, 0), inner_ring__radius_max_reveal, 0, PI*2, 64, Color(0.4, 0.4, 1), 3)
	

#

func _ready():
	if activate_on_ready:
		activate()

#

func activate():
	set_process(true)
	

func unactivate():
	set_process(false)
	modulate.a = 0


#####

func _process(delta):
	var mouse_global_position = get_viewport().get_mouse_position()
	var self_pos = get_global_transform_with_canvas().get_origin()
	var mouse_dist_from_self = mouse_global_position.distance_to(self_pos)
	_do_actions_based_on_dist(mouse_dist_from_self)


func _do_actions_based_on_dist(arg_dist):
	if arg_dist > outer_ring__radius_start_of_reveal:
		#outside outer
		_player_is_outside_of_outer_ring(arg_dist)
	elif arg_dist < inner_ring__radius_max_reveal:
		#inside inner
		_player_is_inside_of_inner_ring(arg_dist)
	elif arg_dist > inner_ring__radius_max_reveal:
		#inside outer
		_player_is_inside_of_outer_ring(arg_dist)


func _player_is_outside_of_outer_ring(arg_dist):
	_set_mod_a__dist__outside_of_outer_ring(arg_dist)

func _player_is_inside_of_outer_ring(arg_dist):
	_set_mod_a__dist__inside_of_outer_ring(arg_dist)

func _player_is_inside_of_inner_ring(arg_dist):
	_set_mod_a__dist__inside_of_inner_ring(arg_dist)



func _set_mod_a__dist__outside_of_outer_ring(arg_dist):
	set_mod_a(mod_a__outside_of_outer_ring)
	

func _set_mod_a__dist__inside_of_outer_ring(arg_dist):
	var mod_a_to_use = _tween_for_intervalue.interpolate_value(mod_a__inside_of_outer_ring, (mod_a__inside_of_inner_ring - mod_a__inside_of_outer_ring), (arg_dist - inner_ring__radius_max_reveal), (outer_ring__radius_start_of_reveal - inner_ring__radius_max_reveal), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	mod_a_to_use = 1 - mod_a_to_use
	set_mod_a(mod_a_to_use)
	

func _set_mod_a__dist__inside_of_inner_ring(arg_dist):
	set_mod_a(mod_a__inside_of_inner_ring)
	


func set_mod_a(arg_mod_a):
	modulate.a = arg_mod_a

