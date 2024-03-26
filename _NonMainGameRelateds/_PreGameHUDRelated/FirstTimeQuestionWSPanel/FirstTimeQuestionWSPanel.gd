extends MarginContainer

signal question_panel_finished()

#


var _current_ftq_scene

#

onready var ftq_scene02 = $FreeFormControl/FTQ_Scene02
onready var ftq_scene03 = $FreeFormControl/FTQ_Scene03
onready var ftq_scene04 = $FreeFormControl/FTQ_Scene04


#

func _ready():
	ftq_scene02.visible = false
	ftq_scene03.visible = false
	ftq_scene04.visible = false
	
	call_deferred("_start_scene_sequence__02")

func _start_scene_sequence__02():
	_current_ftq_scene = ftq_scene02
	ftq_scene02.visible = true
	ftq_scene02.start_display()
	ftq_scene02.connect("sequence_finished", self, "_on_sequence_finished__scene_02", [], CONNECT_DEFERRED)

func _on_sequence_finished__scene_02():
	ftq_scene02.visible = false
	ftq_scene02.queue_free()
	
	##
	
	_current_ftq_scene = ftq_scene03
	ftq_scene03.visible = true
	ftq_scene03.start_display()
	#ftq_scene03.call_deferred("start_display")
	ftq_scene03.connect("sequence_finished", self, "_on_sequence_finished__scene_03", [], CONNECT_DEFERRED)


func _on_sequence_finished__scene_03():
	ftq_scene03.visible = false
	ftq_scene03.queue_free()
	
	##
	
	_current_ftq_scene = ftq_scene04
	ftq_scene04.visible = true
	ftq_scene04.start_display()
	ftq_scene04.connect("sequence_finished", self, "_on_sequence_finished__scene_04")

##

func _on_sequence_finished__scene_04():
	#var wait_tweener = create_tween()
	#wait_tweener.tween_callback(self, "_emit_finished").set_delay(2.0)
	
	_current_ftq_scene = null
	_emit_finished()

func _emit_finished():
	emit_signal("question_panel_finished")


##

func _on_FirstTimeQuestionWSPanel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT: #and event.doubleclick:
			if is_instance_valid(_current_ftq_scene):
				_current_ftq_scene.custom_step_current_control_tweener(0.5)
				

func _unhandled_input(event):
	get_viewport().set_input_as_handled()

