extends MarginContainer



signal start_display_completed()
#signal uptick_to_count_completed()
signal end_display_completed()

#

const CURR_LABEL_STR_FORMAT = "%02d"
const MAX_LABEl_STR_FORMAT = "/ %02d"

const MOD_A__FADE_IN__SELF_DURATION : float = 0.5
const MOD_A__FADE_IN__ELE_DURATION : float = 0.35
const MOD_A__FADE_IN__PER_ELE_SEQUENCE_DELAY : float = 0.2

const MOD_A__ENDING__FADE_OUT__SELF_DURATION : float = 0.75

#const UPTICK_TO_COUNT__ACCEL_DURATION : float = 0.4
#const UPTICK_TO_COUNT__DECEL_DURATION : float = 0.7

#

# set this first before curr
var _threshold_count : int
var _curr_count : int
var _is_curr_count_final : bool = false

onready var star_count_curr_label = $VBoxContainer/HBoxContainer/StarCountCurrLabel
onready var star_count_max_label = $VBoxContainer/HBoxContainer/StarCountMaxLabel
onready var star_icon = $VBoxContainer/StarIcon
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
		star_count_curr_label.modulate = Color("#E1FC1D")
	elif _curr_count < _threshold_count and _is_curr_count_final:
		star_count_curr_label.modulate = Color("#FC2C2C")
	else:
		star_count_curr_label.modulate = Color("#dddddd")

###

func start_display():
	visible = true
	
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

#

#func begin_curr_count_uptick_to_count(arg_target_count : int):
#	var first_half = arg_target_count / 2
#	var second_half = arg_target_count / 2
#	second_half += arg_target_count % 2
#
#	var tweener = create_tween()
#	tweener.tween_method(self, "_set_curr_count__from_uptick_tweener", 0, first_half, UPTICK_TO_COUNT__ACCEL_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
#	tweener.tween_method(self, "_set_curr_count__from_uptick_tweener", first_half, second_half, UPTICK_TO_COUNT__DECEL_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

#func _set_curr_count__from_uptick_tweener(arg_i_count : int, arg_target_count : int):
#	set_curr_count()
#


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

#

func get_center_pos_of_star_icon() -> Vector2:
	return star_icon.rect_global_position + star_icon.texture.get_size() / 2


