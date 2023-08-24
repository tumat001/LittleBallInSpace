extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"


#signal show_outside_of_map_bounds_warning()
#signal hide_outside_of_map_bounds_warning()


##

var game_front_hud

var _is_player_in_map_bounds : bool

var _frames_to_check_for_out_of_map_bounds : int

#

func _ready():
	connect("player_entered_in_area", self, "_on_player_entered_area__map_bounds")
	connect("player_exited_in_area", self, "_on_player_exited_in_area__map_bounds")
	
	call_deferred("_deferred_ready")
	
	set_process(false)

func _deferred_ready():
	_is_player_in_map_bounds = true
	SingletonsAndConsts.current_rewind_manager.connect("rewinding_started", self, "_on_rewinding_started__pdar_map_bounds")
	SingletonsAndConsts.current_rewind_manager.connect("done_ending_rewind", self, "_on_done_ending_rewind__pdar_map_bounds")
	SingletonsAndConsts.current_game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided__pdar_map_bounds")
	#SingletonsAndConsts.current_game_front_hud
	
	if !is_instance_valid(SingletonsAndConsts.current_game_front_hud):
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized")
	else:
		game_front_hud = SingletonsAndConsts.current_game_front_hud

func _on_game_front_hud_initialized(arg_front_hud):
	game_front_hud = arg_front_hud

func _on_game_result_decided__pdar_map_bounds(arg_result):
	game_front_hud.hide_warning_out_of_map_bounds()


###

func _on_player_entered_area__map_bounds():
	_is_player_in_map_bounds = true
	
	_cancel_frames_to_check_for_out_of_map_bounds()
	
	if is_instance_valid(game_front_hud):
		game_front_hud.hide_warning_out_of_map_bounds()

func _on_player_exited_in_area__map_bounds():
	_is_player_in_map_bounds = false
	
	if _can_show_out_of_bounds_warning(): #and _frames_to_ignore_out_of_map_bounds <= 0:
		game_front_hud.show_warning_out_of_map_bounds()

func _can_show_out_of_bounds_warning():
	if is_instance_valid(SingletonsAndConsts.current_rewind_manager):
		return !SingletonsAndConsts.current_rewind_manager.is_rewinding and !SingletonsAndConsts.current_game_elements.game_result_manager.is_game_result_decided
	else:
		return false


func _on_rewinding_started__pdar_map_bounds():
	game_front_hud.hide_warning_out_of_map_bounds()
	

func _on_done_ending_rewind__pdar_map_bounds():
	_frames_to_check_for_out_of_map_bounds = 2
	set_process(true)


func _process(delta):
	if _frames_to_check_for_out_of_map_bounds > 0:
		_frames_to_check_for_out_of_map_bounds -= 1
		
		if _frames_to_check_for_out_of_map_bounds <= 0:
			_cancel_frames_to_check_for_out_of_map_bounds()
			
			if !_is_player_in_map_bounds:
				if _can_show_out_of_bounds_warning():
					game_front_hud.show_warning_out_of_map_bounds()

func _cancel_frames_to_check_for_out_of_map_bounds():
	_frames_to_check_for_out_of_map_bounds = 0
	set_process(false)


