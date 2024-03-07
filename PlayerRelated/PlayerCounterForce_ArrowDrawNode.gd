extends "res://MiscRelated/DrawRelated/ArrowDrawNode/ArrowDrawNode.gd"


const ARROW_DURATION_BEFORE_FADE_TRIGGER_PROCESS : float = 0.5

var arrow_before_fade_trigger_timer : Timer

#

func _ready() -> void:
	_init_arrow_before_fade_trigger_timer()

func _init_arrow_before_fade_trigger_timer():
	arrow_before_fade_trigger_timer = Timer.new()
	arrow_before_fade_trigger_timer
	
	add_child(arrow_before_fade_trigger_timer)

#

func play_and_draw_arrow_based_on_args(arg_counter_mov : Vector2):
	var mov_angle = arg_counter_mov.angle()
	
