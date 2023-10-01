extends Node2D

#

signal fog_hide_finished()

#

var _mod_a_tweener : SceneTreeTween

#

#export (RectangleShape2D) var shape : RectangleShape2D setget set_shape

export(bool) var is_showing_fog__at_ready : bool
export(float) var tween_duration : float = 2.0

#

onready var dialog_template__as_fog = $DialogTemplate_Body_CBM

#

func _ready():
	#update_fog__based_on_shape()
	
	z_index += 1
	
	if is_showing_fog__at_ready:
		start_show_fog(0)


func start_show_fog(arg_tweener_duration : float = tween_duration):
	_kill_mod_a_tweener()
	
	_mod_a_tweener = create_tween()
	_mod_a_tweener.tween_property(self, "modulate:a", 1.0, arg_tweener_duration)

func start_hide_fog(arg_tweener_duration : float = tween_duration):
	_kill_mod_a_tweener()
	
	_mod_a_tweener = create_tween()
	_mod_a_tweener.tween_property(self, "modulate:a", 0.0, arg_tweener_duration)
	_mod_a_tweener.tween_callback(self, "_on_fog_hide_finished")

func _kill_mod_a_tweener():
	if _mod_a_tweener != null and _mod_a_tweener.is_valid():
		_mod_a_tweener.kill()
	

#

func _on_fog_hide_finished():
	emit_signal("fog_hide_finished")

##

#func update_fog__based_on_shape():
#	if is_inside_tree():
#		dialog_template__as_fog.rect_size = shape.extents
#		dialog_template__as_fog.rect_position = global_position
#


