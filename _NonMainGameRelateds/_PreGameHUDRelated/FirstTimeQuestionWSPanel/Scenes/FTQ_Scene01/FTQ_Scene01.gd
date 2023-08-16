extends "res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Scenes/FTQ_BaseScene.gd"


var first_line = [
	["Before we proceed,", []],
	["there are two questions you must answer.", []]
]

#

onready var ftq_custom_label = $FTQ_CustomLabel

#

func _ready():
	ftq_custom_label.set_desc__and_hide_tooltip(first_line)
	ftq_custom_label.set_anchors_preset(Control.PRESET_CENTER, true)
	

#

func start_display():
	.start_display()
	
	ftq_custom_label.start_display_of_descs(1.75, 1.5, null, 0, 18)
	ftq_custom_label.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__first_line", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__first_line(custom_char_count_to_show_upto, arg_metadata):
	var total_char = ftq_custom_label.get_total_char_count_of_desc()
	
	ftq_custom_label.start_display_of_descs(2.25, 3.0, null, 18, total_char)
	ftq_custom_label.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__second_line", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__second_line(custom_char_count_to_show_upto, arg_metadata):
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 1.0)
	tweener.tween_callback(self, "_on_fully_invis")

func _on_fully_invis():
	emit_sequence_finished()






