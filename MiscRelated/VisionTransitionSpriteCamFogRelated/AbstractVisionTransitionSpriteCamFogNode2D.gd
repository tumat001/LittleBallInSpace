tool
extends Node2D

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


export(float) var outer_ring__radius_start_of_fog : float = 100 setget set_outer_ring__radius_start_of_fog
export(float) var inner_ring__radius_max_fog : float = 50 setget set_inner_ring__radius_max_fog

export(float) var mod_a_of_fog__outside_of_outer_ring : float = 0.0
export(float) var mod_a_of_fog__inside_of_outer_ring : float = 0.0
export(float) var mod_a_of_fog__inside_of_inner_ring : float = 0.8

export(bool) var auto_activate_on_player_created : bool = true

#

var _tween_for_intervalue : SceneTreeTween

#

var transition_sprite__for_mod_a

###

func _init():
	if !Engine.editor_hint:
		_tween_for_intervalue = SceneTreeTween.new()

#

func set_outer_ring__radius_start_of_fog(arg_val):
	outer_ring__radius_start_of_fog = arg_val
	
	if Engine.editor_hint:
		update()

func set_inner_ring__radius_max_fog(arg_val):
	inner_ring__radius_max_fog = arg_val
	
	if Engine.editor_hint:
		update()


func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0, 0), outer_ring__radius_start_of_fog, 0, PI*2, 64, Color(1, 0, 0), 3)
		draw_arc(Vector2(0, 0), inner_ring__radius_max_fog, 0, PI*2, 64, Color(1, 1, 0), 3)
	

#

func activate_monitor_for_player():
	set_process(true)
	

func deactivate_monitor_for_player():
	set_process(false)
	

#

func _ready():
	if !Engine.editor_hint:
		if auto_activate_on_player_created:
			if SingletonsAndConsts.current_game_elements.is_player_spawned():
				activate_monitor_for_player()
			else:
				SingletonsAndConsts.current_game_elements.connect("player_spawned", self, "_on_player_spawned__for_init_on_player_spawn", [], CONNECT_ONESHOT)
			
		else:
			deactivate_monitor_for_player()
		
	else:
		set_process(false)

func _on_player_spawned__for_init_on_player_spawn(arg_player):
	activate_monitor_for_player()



func _process(delta):
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	var dist = global_position.distance_to(player.global_position)
	
	_do_actions_based_on_dist(dist)
	

func _do_actions_based_on_dist(arg_dist):
	if arg_dist > outer_ring__radius_start_of_fog:
		#outside outer
		_player_is_outside_of_outer_ring(arg_dist)
	elif arg_dist < inner_ring__radius_max_fog:
		#inside inner
		_player_is_inside_of_inner_ring(arg_dist)
	elif arg_dist > inner_ring__radius_max_fog:
		#inside outer
		_player_is_inside_of_outer_ring(arg_dist)


func _player_is_outside_of_outer_ring(arg_dist):
	_set_transition_sprite_mod_a__dist__outside_of_outer_ring(arg_dist)
	

func _player_is_inside_of_outer_ring(arg_dist):
	_set_transition_sprite_mod_a__dist__inside_of_outer_ring(arg_dist)
	

func _player_is_inside_of_inner_ring(arg_dist):
	_set_transition_sprite_mod_a__dist__inside_of_inner_ring(arg_dist)
	


#


func _set_transition_sprite_mod_a__dist__outside_of_outer_ring(arg_dist):
	set_transition_sprite_mod_a(mod_a_of_fog__outside_of_outer_ring)
	

func _set_transition_sprite_mod_a__dist__inside_of_outer_ring(arg_dist):
	var mod_a_to_use = _tween_for_intervalue.interpolate_value(mod_a_of_fog__inside_of_outer_ring, (mod_a_of_fog__inside_of_outer_ring - mod_a_of_fog__inside_of_inner_ring), (outer_ring__radius_start_of_fog - inner_ring__radius_max_fog), (arg_dist - inner_ring__radius_max_fog), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	set_transition_sprite_mod_a(mod_a_to_use)

func _set_transition_sprite_mod_a__dist__inside_of_inner_ring(arg_dist):
	set_transition_sprite_mod_a(mod_a_of_fog__inside_of_inner_ring)
	


func set_transition_sprite_mod_a(arg_mod_a):
	transition_sprite__for_mod_a.modulate.a = arg_mod_a


#todoimp visioncamerafog continue IMPS (in circular). put func to give chance to edit trans sprite that accpets the DIST as param
