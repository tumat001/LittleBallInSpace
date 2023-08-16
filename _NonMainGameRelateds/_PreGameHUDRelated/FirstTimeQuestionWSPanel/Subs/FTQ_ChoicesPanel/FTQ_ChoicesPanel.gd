extends MarginContainer

const FTQ_ChoiceButton = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Subs/FTQ_ChoiceButton/FTQ_ChoiceButton.gd")
const FTQ_ChoiceButton_Scene = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/FirstTimeQuestionWSPanel/Subs/FTQ_ChoiceButton/FTQ_ChoiceButton.tscn")



onready var hbox_container = $HBoxContainer

var _choice_details : Array

#

class ChoiceDetails:
	
	var choice_as_text : String
	
	# accepts 1 param: the param supplied here
	var func_source__on_click
	var func_name__on_click
	var func_param__on_click
	
	var _button_associated

#

func set_choice_details(arg_details : Array):
	for detail in arg_details:
		add_choice_details(detail)
	
	

func add_choice_details(arg_detail : ChoiceDetails):
	_choice_details.append(arg_detail)
	
	#
	
	var choice_button = FTQ_ChoiceButton_Scene.instance()
	choice_button.connect("button_pressed", self, "_on_button_pressed", [arg_detail])
	
	arg_detail._button_associated = choice_button
	
	hbox_container.add_child(choice_button)
	
	#
	
	_configure_choice_button_focus_neighbors(choice_button)

func clear_choice_details():
	for detail in _choice_details:
		detail._button_associated.queue_free()
	
	_choice_details.clear()



func _configure_choice_button_focus_neighbors(arg_recently_added_button : FTQ_ChoiceButton):
	if _choice_details.size() > 1:
		var first_button : FTQ_ChoiceButton = _choice_details[0]._button_associated
		first_button.set_focus_neighbour_left(arg_recently_added_button)
		
		var prev_from_recent_button : FTQ_ChoiceButton = _choice_details[_choice_details.size() - 2]._button_associated
		prev_from_recent_button.set_focus_neighbour_right(arg_recently_added_button)
		
		arg_recently_added_button.set_focus_neighbour_left(prev_from_recent_button)
		arg_recently_added_button.set_focus_neighbour_right(first_button)

##

func _on_button_pressed(arg_detail : ChoiceDetails):
	arg_detail.func_source__on_click.call(arg_detail.func_name__on_click, arg_detail.func_param__on_click)
	

#

func grab_focus__onto_first_choice():
	if _choice_details.size() != 0:
		var first_button = _choice_details[0]
		first_button.grab_focus()

