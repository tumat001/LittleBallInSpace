extends Control

const LABEL_BACKGROUND__GREEN := Color(11/255.0, 81/255.0, 1/255.0)
const LABEL_BACKGROUND__YELLOW := Color(79/255.0, 87/255.0, 0/255.0)
const LABEL_BACKGROUND__ORANGE := Color(116/255.0, 43/255.0, 1/255.0)
const LABEL_BACKGROUND__RED := Color(86/255.0, 1/255.0, 2/255.0)

const LABEL_STRING_FORMAT = "%.2f"

const speed_color_thresholds = [
	250.0,
	400.0,
	700.0,
	2000.0,
]

const angle_deg_thresholds = [
	59.0,
	124.0,
	155.0,
	180.0,
]


var _player

onready var label_background_tex_rect = $LabelContainer/LabelBackground
onready var speed_label = $LabelContainer/MarginContainer/SpeedLabel
onready var speed_arrow = $SpeedArrow

#######

func set_player(arg_player):
	_player = arg_player
	

#

func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if is_instance_valid(_player):
			_update_display_based_on_speed(_player.linear_velocity.length())

#

func _ready():
	_update_display_based_on_speed(0)

# weight_to_b being 0 means color will be color_a
# weight_to_b being 1 means color will be color_b
func _update_display_based_on_speed(arg_speed):
	var color_a : Color
	var color_b : Color
	var weight_to_b : float
	
	var angle_a : float
	var angle_b : float
	#var angle_weight_to_b : float
	
	#
	
	var i = 0
	var prev_speed = 0
	var prev_angle = 0
	for speed in speed_color_thresholds:
		if arg_speed < speed:
			angle_a = prev_angle
			angle_b = angle_deg_thresholds[i]
			weight_to_b = _get_weight_of_number_between_range(arg_speed, prev_speed, speed)
			
			if i == 0:
				color_a = LABEL_BACKGROUND__GREEN
				color_b = LABEL_BACKGROUND__YELLOW
				break
				
			elif i == 1:
				color_a = LABEL_BACKGROUND__YELLOW
				color_b = LABEL_BACKGROUND__ORANGE
				break
				
			elif i == 2:
				color_a = LABEL_BACKGROUND__ORANGE
				color_b = LABEL_BACKGROUND__RED
				break
				
			elif i == 3:
				color_a = LABEL_BACKGROUND__RED
				color_b = LABEL_BACKGROUND__RED
				break
			
		
		# beyond all
		if i == 3:
			color_a = LABEL_BACKGROUND__RED
			color_b = LABEL_BACKGROUND__RED
			weight_to_b = 1
			
			angle_a = 180.0
			angle_b = 180.0
		
		prev_speed = speed
		prev_angle = angle_deg_thresholds[i]
		i += 1
	
	
	#
	
	var finalized_color_a = color_a * (1 - weight_to_b)
	var finalized_color_b = color_b * (weight_to_b)
	var final_color = (finalized_color_a + finalized_color_b)
	
	var finalized_angle_a = angle_a * (1 - weight_to_b)
	var finalized_angle_b = angle_b * (weight_to_b)
	var final_angle = (finalized_angle_a + finalized_angle_b)
	
	##########
	
	label_background_tex_rect.modulate = final_color
	speed_arrow.rect_rotation = final_angle
	speed_label.text = LABEL_STRING_FORMAT % arg_speed

func _get_weight_of_number_between_range(arg_num, arg_r_a, arg_r_b):
	var diff = arg_r_a - arg_r_b
	
	return (diff - (arg_num - arg_r_b)) / float(diff)


