extends MarginContainer



signal start_display_completed()
signal end_display_completed()

#

const CURR_LABEL_STR_FORMAT = "%02d"
const MAX_LABEl_STR_FORMAT = "/ %02d"

const MOD_A__FADE_IN__SELF_DURATION : float = 0.5
const MOD_A__FADE_IN__ELE_DURATION : float = 0.35
const MOD_A__FADE_IN__PER_ELE_SEQUENCE_DELAY : float = 0.2

const MOD_A__ENDING__FADE_OUT__SELF_DURATION : float = 0.75

#

# set this first before curr
var _threshold_count : int
var _curr_count : int
var _is_curr_count_final : bool = false

onready var star_count_curr_label = $HBoxContainer/StarCountCurrLabel
onready var star_count_max_label = $HBoxContainer/StarCountMaxLabel
onready var star_icon = $HBoxContainer/StarIcon
onready var all_ele_in_sequence : Array = [
	star_count_curr_label,
	star_count_max_label,
	star_icon,
]

#

enum EndDisplayTypeId {
	FADE_OUT = 0
}

#

func _ready() -> void:
	modulate.a = 0
	visible = false
	
	for ele in all_ele_in_sequence:
		ele.modulate.a = 0

#

# set this first before curr
func set_threshold_count(arg_count):
	_threshold_count = arg_count
	
	star_count_max_label.text = MAX_LABEl_STR_FORMAT % arg_count

# set max first before this
func set_curr_count(arg_count : int, arg_is_curr_count_final : bool):
	_curr_count = arg_count
	_is_curr_count_final = arg_is_curr_count_final
	
	star_count_curr_label.text = CURR_LABEL_STR_FORMAT % arg_count
	
	_update_curr_label_modulate_based_on_states()

func _update_curr_label_modulate_based_on_states():
	if _curr_count >= _threshold_count:
		star_count_curr_label.modulate = Color("#F6FEBA")
	elif _curr_count < _threshold_count and _is_curr_count_final:
		star_count_curr_label.modulate = Color("#FEB9B9")
	else:
		star_count_curr_label.modulate = Color("#dddddd")

###

func start_display():
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 1.0, MOD_A__FADE_IN__SELF_DURATION)
	
	
	var i = 0
	tweener.set_parallel(true)
	for ele in all_ele_in_sequence:
		tweener.tween_property(ele, "modulate:a", 1.0, MOD_A__FADE_IN__ELE_DURATION).set_delay(i * MOD_A__FADE_IN__PER_ELE_SEQUENCE_DELAY)
		
		i += 1
	
	tweener.connect("finished", self, "_on_start_display_tween_finished", [], CONNECT_ONESHOT)

func _on_start_display_tween_finished():
	emit_signal("start_display_completed")


###

func end_display(arg_end_display_type : int):
	match arg_end_display_type:
		EndDisplayTypeId.FADE_OUT:
			_end_display__as_fade_out()
	

func _end_display__as_fade_out():
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 0.0, MOD_A__ENDING__FADE_OUT__SELF_DURATION)
	tweener.tween_callback(self, "_on_end_display_tween_finished")

func _on_end_display_tween_finished():
	emit_signal("end_display_completed")




