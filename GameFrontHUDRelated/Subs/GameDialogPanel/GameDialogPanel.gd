extends MarginContainer


signal display_of_desc_finished(arg_metadata)

#

const DEFAULT_DURATION__SHOW_OR_HIDE_SELF : float = 0.65

#

onready var dialog_background = $DialogBackground
onready var tooltip_body = $MarginContainer/TooltipBody



#

func _ready():
	visible = false

###

func start_display_of_descs(arg_desc, arg_duration, arg_additional_delay_for_finish, arg_metadata):
	tooltip_body.descriptions = arg_desc
	tooltip_body.update_display()
	
	tooltip_body.start_tween_display_of_text(arg_duration, self, "_on_tooltip_body_started_displaying_text__tween", [arg_duration, arg_additional_delay_for_finish, arg_metadata])

func _on_tooltip_body_started_displaying_text__tween(details, arg_params):
	var arg_duration = arg_params[0]
	var arg_additional_delay_for_finish = arg_params[1]
	var arg_metadata = arg_params[2]
	
	var tweener : SceneTreeTween = details[0]
	tweener.tween_callback(self, "_on_tweener_finished_displaying_descs", [arg_metadata]).set_delay(arg_duration + arg_additional_delay_for_finish)


func _on_tweener_finished_displaying_descs(arg_metadata):
	emit_signal("display_of_desc_finished", arg_metadata)
	

#

func show_self(arg_duration : float = DEFAULT_DURATION__SHOW_OR_HIDE_SELF):
	if !visible:
		visible = true
		modulate.a = 0
	
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 1.0, arg_duration)
	

func hide_self(arg_duration : float = DEFAULT_DURATION__SHOW_OR_HIDE_SELF):
	if visible:
		var tweener = create_tween()
		tweener.set_parallel(false)
		tweener.tween_property(self, "modulate:a", 0.0, arg_duration)
		tweener.tween_callback(self, "_on_tweener_made_modulate_a_zero__from_hide_self")


func _on_tweener_made_modulate_a_zero__from_hide_self():
	visible = false
	


