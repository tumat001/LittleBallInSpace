extends Control

signal end_of_anim()
signal ready_finished()


enum WinMessageType {
	VICTORY = 0,
	CONGRATULATIONS = 1,
}
var win_message_type : int = WinMessageType.VICTORY setget set_win_message_type

const win_messege_type_to_text_map : Dictionary = {
	WinMessageType.VICTORY : "Victory",
	WinMessageType.CONGRATULATIONS : "Congratulations",
}


enum LoseMessageType {
	DEFEAT = 0,
	YOU_LOST = 1,
	YOU_DIED = 2,
}
var lose_message_type : int = LoseMessageType.DEFEAT setget set_lose_message_type

const lose_messege_type_to_text_map : Dictionary = {
	LoseMessageType.DEFEAT : "Defeat",
	LoseMessageType.YOU_LOST : "You Lost",
	LoseMessageType.YOU_DIED : "You Died",
	
}

#

func set_win_message_type(arg_type):
	win_message_type = arg_type
	

func get_win_message() -> String:
	return win_messege_type_to_text_map[win_message_type]

#

func set_lose_message_type(arg_type):
	lose_message_type = arg_type
	

func get_lose_message() -> String:
	return lose_messege_type_to_text_map[lose_message_type]


#########

func _ready():
	var rect_of_screen = get_viewport().get_visible_rect()
	rect_size = Vector2(rect_of_screen.size.x, rect_of_screen.size.y)
	
	
	#emit_signal("ready_finished")
	call_deferred("emit_signal", "ready_finished")

##

func start_show():
	reset_show()
	

func reset_show():
	pass
	


func _end_of_anim():
	emit_signal("end_of_anim")

#func helper__stretch_control_to_final_scale(arg_control : Control, 
#		arg_final_scale : Vector2, arg_duration : float, 
#		tween : SceneTreeTween = create_tween()) -> PropertyTweener:
#
#	return tween.tween_property(arg_control, "rect_scale", arg_final_scale, arg_duration)
