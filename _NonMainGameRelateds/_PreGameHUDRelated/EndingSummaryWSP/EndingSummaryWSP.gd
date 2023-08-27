extends Control

signal ending_panel_finished()



var _heart_sprite : Sprite

onready var position_for_heart = $PositionForHeart

onready var es_scene01 = $ES_Scene01

#######

func _ready():
	es_scene01.visible = false
	
	#start_display()


func start_display():
	var dead_heart_details = SingletonsAndConsts.current_game_front_hud.trophy_panel.get_player_dead_tex_rect_pos__and_center_pos__and_texture__and_is_vis()
	var is_dead = dead_heart_details[3]
	
	if is_dead:
		_start_unique_display__as_dead(dead_heart_details)
	else:
		_start_unique_display__as_alive()



func _start_unique_display__as_dead(dead_heart_details):
	var dead_heart_glob_pos = dead_heart_details[1]
	var dead_heart_texture = dead_heart_details[2]
	
	var sprite = Sprite.new()
	sprite.texture = dead_heart_texture
	sprite.global_position = dead_heart_glob_pos
	add_child(sprite)
	_heart_sprite = sprite
	
	SingletonsAndConsts.current_master.connect("switching_from_game_elements__as_win__transition_ended", self, "_on_switching_from_game_elements__as_win__transition_ended", [], CONNECT_ONESHOT)
	es_scene01.connect("fade_out_modulate_reached", self, "_on_fade_out_modulate_reached")

func _on_switching_from_game_elements__as_win__transition_ended():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(_heart_sprite, "global_position", position_for_heart.rect_global_position, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_callback(self, "_on_heart_done_moving").set_delay(0.25)
	

func _on_heart_done_moving():
	_start_scene_sequence__01()


##

func _start_unique_display__as_alive():
	_start_scene_sequence__01()
	


##

func _start_scene_sequence__01():
	es_scene01.visible = true
	es_scene01.start_display()
	es_scene01.connect("sequence_finished", self, "_on_sequence_finished__scene_01")
	

#

func _on_fade_out_modulate_reached(arg_modulate_a_val):
	_heart_sprite.modulate.a = arg_modulate_a_val

func _on_sequence_finished__scene_01():
	if is_instance_valid(_heart_sprite):
		_heart_sprite.visible = false
		_heart_sprite.queue_free()
	
	emit_signal("ending_panel_finished")
	

