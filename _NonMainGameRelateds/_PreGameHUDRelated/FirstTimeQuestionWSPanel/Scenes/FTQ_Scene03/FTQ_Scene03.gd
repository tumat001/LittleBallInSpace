extends "res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Scenes/FTQ_BaseScene.gd"

const FTQ_ChoicesPanel = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Subs/FTQ_ChoicesPanel/FTQ_ChoicesPanel.gd")


var first_line = [
	[".....", []]
]

var second_line = [
	["What are you? [color=#9BB4FD]A dog person[/color], or a [color=#FF8000]cat person?[/color]", []]
]

#

var _choice_made : bool = false

#

onready var ftq_custom_label_01 = $FTQ_CustomLabel_01

onready var vbox_container = $VBoxContainer

onready var ftq_custom_label_02 = $VBoxContainer/FTQ_CustomLabel_02
onready var ftq_choices_panel = $VBoxContainer/FTQ_ChoicesPanel

########

func _ready():
	ftq_custom_label_01.set_desc__and_hide_tooltip(first_line)
	ftq_custom_label_02.set_desc__and_hide_tooltip(second_line)
	
	vbox_container.set_anchors_preset(Control.PRESET_CENTER)
	
	#
	
	var choice_details__dog = FTQ_ChoicesPanel.ChoiceDetails.new()
	choice_details__dog.choice_as_text = "Dog\nPerson"
	choice_details__dog.func_source__on_click = self
	choice_details__dog.func_name__on_click = "_on_choice_selected__dog_person"
	choice_details__dog.func_param__on_click = null
	
	var choice_details__cat = FTQ_ChoicesPanel.ChoiceDetails.new()
	choice_details__cat.choice_as_text = "Cat\nPerson"
	choice_details__cat.func_source__on_click = self
	choice_details__cat.func_name__on_click = "_on_choice_selected__cat_person"
	choice_details__cat.func_param__on_click = null
	
	ftq_choices_panel.set_choice_details([choice_details__dog, choice_details__cat])
	ftq_choices_panel.visible = false
	ftq_choices_panel.set_anchors_preset(Control.PRESET_CENTER)


#######

func start_display():
	.start_display()
	
	_current_custom_steppable_control = ftq_custom_label_01
	ftq_custom_label_01.start_display_of_descs__all_chars(0.75, 1.25, null)
	#ftq_custom_label_01.call_deferred("start_display_of_descs__all_chars", 0.75, 1.25, null)
	ftq_custom_label_01.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__line_01", [], CONNECT_ONESHOT)
	

func _on_display_of_desc_finished__line_01(custom_char_count_to_show_upto, arg_metadata):
	var pos_moving_tweener = create_tween()
	pos_moving_tweener.set_parallel(false)
	pos_moving_tweener.tween_property(ftq_custom_label_01, "rect_position:y", ftq_custom_label_01.rect_position.y - 200, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	pos_moving_tweener.tween_callback(self, "_on_done_moving_label_01")



func _on_done_moving_label_01():
	#14
	_current_custom_steppable_control = ftq_custom_label_02
	ftq_custom_label_02.start_display_of_descs(0.75, 1.0, null, 0, 14)
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_02__01", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__seq_02__01(custom_char_count_to_show_upto, arg_metadata):
	#28
	ftq_custom_label_02.start_display_of_descs(0.75, 0.75, null, 14, 14+14)
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_02__02", [], CONNECT_ONESHOT)
	
	

func _on_display_of_desc_finished__seq_02__02(custom_char_count_to_show_upto, arg_metadata):
	#28+16
	ftq_custom_label_02.start_display_of_descs(0.75, 0.75, null, 28, 28+16)
	ftq_custom_label_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__seq_02", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__seq_02(custom_char_count_to_show_upto, arg_metadata):
	ftq_choices_panel.modulate.a = 0
	ftq_choices_panel.visible = true
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(ftq_choices_panel, "modulate:a", 1.0, 0.5)
	tweener.tween_callback(self, "_on_ftq_choices_panel__fully_visible")

func _on_ftq_choices_panel__fully_visible():
	ftq_choices_panel.grab_focus__onto_first_choice()


######

func _on_choice_selected__dog_person(arg_params):
	if !_choice_made:
		GameSaveManager.animal_choice_id = GameSaveManager.AnimalChoiceId.DOG
		_start_invis_tween__for_end_of_scene()
		
		_choice_made = true

func _on_choice_selected__cat_person(arg_params):
	if !_choice_made:
		GameSaveManager.animal_choice_id = GameSaveManager.AnimalChoiceId.CAT
		_start_invis_tween__for_end_of_scene()
		
		_choice_made = true

func _start_invis_tween__for_end_of_scene():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_on_self_fully_invis")
	



func _on_self_fully_invis():
	emit_sequence_finished()



