extends AnimatedSprite



signal sprite_frames_changed(arg_sframes)

###

const ANIM_NAME__WALK = "walk"
const ANIM_NAME__IDLE = "idle"

#

const MAX_CHAR_SPEED_FOR_IDLE : float = 2.0

#

const SPEED_SCALE__ANIM_WALK__MIN : float = 0.3
const SPEED_SCALE__ANIM_WALK__MAX : float = 1.0

const MIN_CHAR_SPEED_FOR__ANIM_WALK__MIN : float = 20.0
const MIN_CHAR_SPEED_FOR__ANIM_WALK__MAX : float = 180.0

##

var _tween_for_intervalue : SceneTreeTween

# samples only from one frame btw
var sprite_size : Vector2



var player_to_watch_speed
var speed_scale_multiplier : float = 1.0

#######

func _ready():
	_tween_for_intervalue = SceneTreeTween.new()
	
	set_process(false)

#

func config_as_dead():
	# YA CANT DO THIS MATEY... THIS THING's MAT IS ALREADY SETTED
#	var shader_mat = ShaderMaterial.new()
#	shader_mat.shader = load("res://MiscRelated/ShadersRelated/Shader_Saturation.tres")
#	shader_mat.set_shader_param("saturation", 0.0)
#	material = shader_mat
	
	speed_scale_multiplier = 0.5
	

#

func config_set_sprite_frames(arg_sframes):
	frames = arg_sframes
	
	sprite_size = frames.get_frame(ANIM_NAME__WALK, 0).get_size()
	
	emit_signal("sprite_frames_changed", arg_sframes)

#

func config_set_player_to_watch_speed(arg_player):
	player_to_watch_speed = arg_player
	
	set_process(true)

func update_self_based_on_char_speed(arg_char_speed):
	if arg_char_speed <= MAX_CHAR_SPEED_FOR_IDLE:
		_play_anim__idle()
	else:
		_play_anim__walk__using_char_speed(arg_char_speed)
	

func _play_anim__idle():
	play(ANIM_NAME__IDLE)

func _play_anim__walk__using_char_speed(arg_char_speed):
	var speed_scale_to_use
	if arg_char_speed >= MIN_CHAR_SPEED_FOR__ANIM_WALK__MAX:
		speed_scale_to_use = SPEED_SCALE__ANIM_WALK__MAX
	elif arg_char_speed <= MIN_CHAR_SPEED_FOR__ANIM_WALK__MIN:
		speed_scale_to_use = SPEED_SCALE__ANIM_WALK__MIN
	else:
		var ratio = _tween_for_intervalue.interpolate_value(SPEED_SCALE__ANIM_WALK__MAX, SPEED_SCALE__ANIM_WALK__MIN, (MIN_CHAR_SPEED_FOR__ANIM_WALK__MAX - arg_char_speed), (MIN_CHAR_SPEED_FOR__ANIM_WALK__MAX - MIN_CHAR_SPEED_FOR__ANIM_WALK__MIN), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		speed_scale_to_use = ratio
	
	speed_scale_to_use *= speed_scale_multiplier
	speed_scale = speed_scale_to_use
	
	play(ANIM_NAME__WALK)
	

#####

func _process(delta):
	if is_instance_valid(player_to_watch_speed):
		var speed = player_to_watch_speed.linear_velocity.length()
		update_self_based_on_char_speed(speed)
		
		var is_flipped_x = player_to_watch_speed.linear_velocity.normalized().x < 0
		if !is_zero_approx(speed):
			flip_h = is_flipped_x
	

