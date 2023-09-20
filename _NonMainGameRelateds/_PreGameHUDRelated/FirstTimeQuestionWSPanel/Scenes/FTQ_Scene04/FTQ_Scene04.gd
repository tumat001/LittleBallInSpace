extends "res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Scenes/FTQ_BaseScene.gd"



var first_line = [
	["In this [color=#FD686A]universe[/color]", []]
]

var second_line = [
	["[color=#F6FEAE]You[/color] are", []]
]

var third_line = [
	["A little [color=#91FE81]ball[/color]", []]
]

var fourth_line = [
	["In [color=#C0B9FE]space[/color]", []]
]

#

onready var ftq_custom_label_01 = $FTQ_CustomLabel_01
onready var ftq_custom_label_02 = $FTQ_CustomLabel_02
onready var ftq_custom_label_03 = $FTQ_CustomLabel_03
onready var ftq_custom_label_04 = $FTQ_CustomLabel_04


##################

func _ready():
	ftq_custom_label_01.set_desc__and_hide_tooltip(first_line)
	ftq_custom_label_02.set_desc__and_hide_tooltip(second_line)
	ftq_custom_label_03.set_desc__and_hide_tooltip(third_line)
	ftq_custom_label_04.set_desc__and_hide_tooltip(fourth_line)
	

func start_display():
	.start_display()
	
	_current_custom_steppable_control = ftq_custom_label_01
	ftq_custom_label_01.start_display_of_descs__all_chars(0.5, 1.25, null)
	ftq_custom_label_01.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_01", [], CONNECT_ONESHOT)
	

func _on_display_of_desc_finished__seq_01(custom_char_count_to_show_upto, arg_metadata):
	var pos_moving_tweener = create_tween()
	pos_moving_tweener.set_parallel(false)
	pos_moving_tweener.tween_property(ftq_custom_label_01, "rect_position:y", ftq_custom_label_01.rect_position.y - 150, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	pos_moving_tweener.tween_callback(self, "_on_done_moving_label_01")

func _on_done_moving_label_01():
	_current_custom_steppable_control = ftq_custom_label_02
	ftq_custom_label_02.start_display_of_descs__all_chars(0.5, 1.25, null)
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_02", [], CONNECT_ONESHOT)
	

func _on_display_of_desc_finished__seq_02(custom_char_count_to_show_upto, arg_metadata):
	var pos_moving_tweener = create_tween()
	pos_moving_tweener.set_parallel(false)
	pos_moving_tweener.tween_property(ftq_custom_label_02, "rect_position:y", ftq_custom_label_02.rect_position.y - 100, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	pos_moving_tweener.tween_callback(self, "_on_done_moving_label_02")

func _on_done_moving_label_02():
	_current_custom_steppable_control = ftq_custom_label_03
	ftq_custom_label_03.start_display_of_descs__all_chars(0.5, 1.0, null)
	ftq_custom_label_03.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_03", [], CONNECT_ONESHOT)
	

func _on_display_of_desc_finished__seq_03(custom_char_count_to_show_upto, arg_metadata):
	var pos_moving_tweener = create_tween()
	pos_moving_tweener.set_parallel(false)
	pos_moving_tweener.tween_property(ftq_custom_label_03, "rect_position:y", ftq_custom_label_03.rect_position.y + 100, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	pos_moving_tweener.tween_callback(self, "_on_done_moving_label_03")
	

func _on_done_moving_label_03():
	_current_custom_steppable_control = ftq_custom_label_04
	ftq_custom_label_04.rect_position.y += 150
	
	ftq_custom_label_04.start_display_of_descs__all_chars(0.5, 2, null)
	ftq_custom_label_04.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_04", [], CONNECT_ONESHOT)
	


func  _on_display_of_desc_finished__seq_04(custom_char_count_to_show_upto, arg_metadata):
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_on_self_fully_invis")
	

func _on_self_fully_invis():
	emit_sequence_finished()


