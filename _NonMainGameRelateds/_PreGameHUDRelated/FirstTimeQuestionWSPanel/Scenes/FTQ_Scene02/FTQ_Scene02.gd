extends "res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Scenes/FTQ_BaseScene.gd"

var first_line = [
	["First", []]
]

var second_line = [
	["Give the name of your beloved [color=#FEDB72]pet[/color]?", []]
]

var third_line = [
	["If you have no pet, then a name of your hypotheitcal pet,", []],
	["or someone you care about.", []]
]

var fourth_line = [
	["If you have many, then pick one <3", []]
]

var fifth_line = [
	["I hope I covered all edge cases.", []]
]

#

var _current_tweener : SceneTreeTween


var name_of_pet : String


onready var ftq_custom_label_01 = $FTQ_CustomLabel_01
onready var vbox_container = $VBoxContainer

onready var ftq_custom_label_02 = $VBoxContainer/FTQ_CustomLabel_02
onready var ftq_custom_label_03 = $VBoxContainer/FTQ_CustomLabel_03
onready var ftq_custom_label_04 = $VBoxContainer/FTQ_CustomLabel_04
onready var ftq_custom_label_05 = $VBoxContainer/FTQ_CustomLabel_05

onready var ftq_custom_line = $VBoxContainer/FTQ_CustomLine

##

func _ready():
	ftq_custom_label_01.set_desc__and_hide_tooltip(first_line)
	ftq_custom_label_02.set_desc__and_hide_tooltip(second_line)
	ftq_custom_label_03.set_desc__and_hide_tooltip(third_line)
	ftq_custom_label_04.set_desc__and_hide_tooltip(fourth_line)
	ftq_custom_label_05.set_desc__and_hide_tooltip(fifth_line)
	ftq_custom_line.visible = false
	
	####
	
	ftq_custom_label_01.set_anchors_preset(Control.PRESET_CENTER)
	vbox_container.set_anchors_preset(Control.PRESET_CENTER)


func start_display():
	.start_display()
	
	ftq_custom_label_01.start_display_of_descs__all_chars(0.5, 1.0, null)
	ftq_custom_label_01.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_01")

func _on_display_of_desc_finished__line_01(custom_char_count_to_show_upto, arg_metadata):
	var pos_moving_tweener = create_tween()
	pos_moving_tweener.set_parallel(false)
	pos_moving_tweener.tween_property(ftq_custom_label_01, "rect_position:y", ftq_custom_label_01.rect_position.y - 200, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	pos_moving_tweener.tween_callback(self, "_on_done_moving_label_01")

func _on_done_moving_label_01():
	#30
	ftq_custom_label_02.start_display_of_descs(0.75, 0.5, null, 0, 30)
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_02_01")
	
	

func _on_display_of_desc_finished__line_02_01(custom_char_count_to_show_upto, arg_metadata):
	ftq_custom_label_02.start_display_of_descs(0.3, 0.5, null, 30, ftq_custom_label_02.get_total_char_count_of_desc())
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_02_02")
	

func _on_display_of_desc_finished__line_02_02(custom_char_count_to_show_upto, arg_metadata):
	ftq_custom_line.visible = true
	ftq_custom_line.grab_focus()
	ftq_custom_line.connect("text_entered", self, "_on_text_entered")
	
	_current_tweener = create_tween()
	_current_tweener.tween_callback(self, "_delay__start_disp_of_third_line").set_delay(4.0)

func _delay__start_disp_of_third_line():
	_current_tweener = null
	
	ftq_custom_label_03.start_display_of_descs__all_chars(3.5, 1.5, null)
	ftq_custom_label_03.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_03")

func _on_display_of_desc_finished__line_03():
	ftq_custom_label_04.start_display_of_descs__all_chars(1.5, 5.0, null)
	ftq_custom_label_04.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_04")


func _on_display_of_desc_finished__line_04():
	ftq_custom_label_05.start_display_of_descs__all_chars(1.0, 0.0, null)



####################

func _on_text_entered(arg_text):
	if _current_tweener != null:
		_current_tweener.kill()
	
	name_of_pet = arg_text
	ftq_custom_line.set_editable(false)
	
	
	GameSaveManager.player_name = name_of_pet
	
	#
	
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 1.0)
	tweener.tween_callback(self, "_on_done_with_mod_a_transition")

func _on_done_with_mod_a_transition():
	emit_sequence_finished()




