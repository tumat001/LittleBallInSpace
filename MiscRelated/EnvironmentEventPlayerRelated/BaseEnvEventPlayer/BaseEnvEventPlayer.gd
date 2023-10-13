extends Node2D


export(float) var radius_for_event : float setget set_radius_for_event
export(float) var player_pos_checker_interval : float = 5.0

var _is_active : bool

var _curr_checker_interval_wait_sec : float 

#

func set_radius_for_event(arg_val):
	radius_for_event = arg_val
	
	if Engine.editor_hint:
		update()

func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0, 0), radius_for_event, 0, PI*2, 64, Color(0, 1, 0), 3)
	

#

func _ready():
	pass
	

func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		_curr_checker_interval_wait_sec -= delta
		if _curr_checker_interval_wait_sec < 0:
			_curr_checker_interval_wait_sec += player_pos_checker_interval
			_check_for_player_dist()

#

func _check_for_player_dist():
	if SingletonsAndConsts.current_game_elements.is_player_spawned():
		var player = SingletonsAndConsts.current_game_elements.get_current_player()
		var dist = player.global_position.distance_to(global_position)
		
		if dist <= radius_for_event:
			_set_is_active(true)
		else:
			_set_is_active(false)
		
	else:
		_set_is_active(false)

func _set_is_active(arg_val):
	var old_val = _is_active
	_is_active = arg_val
	
	if old_val != arg_val:
		_on_set_as_active__true()
	else:
		_on_set_as_active__false()



func _on_set_as_active__true():
	pass
	

func _on_set_as_active__false():
	pass
	

