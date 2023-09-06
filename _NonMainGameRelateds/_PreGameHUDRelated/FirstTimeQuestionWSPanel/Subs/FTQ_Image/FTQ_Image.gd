extends TextureRect

signal display_of_image_finished(arg_metadata)

#

var _current_tweener : SceneTreeTween

#

export(bool) var cutscene_initially_visible : bool = false

#

var is_class_type_ftq_image : bool = true

#

func start_display(arg_duration, arg_additional_delay_for_finish, arg_metadata, arg_target_modulate_a : float = 1.0):
	_current_tweener = create_tween()
	_current_tweener.set_parallel(false)
	_current_tweener.tween_property(self, "modulate:a", arg_target_modulate_a, arg_duration).set_delay(arg_additional_delay_for_finish)
	_current_tweener.tween_callback(self, "_on_finish_start_display", [arg_metadata])
	

func _on_finish_start_display(arg_metadata):
	emit_signal("display_of_image_finished", arg_metadata)
	



func finish_display_now():
	if _current_tweener != null and _current_tweener.is_running():
		_current_tweener.custom_step(99999)
		return true
		
	else:
		return false


