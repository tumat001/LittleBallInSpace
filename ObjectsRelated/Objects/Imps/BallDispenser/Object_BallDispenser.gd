
extends "res://ObjectsRelated/Objects/BaseObject.gd"


var BALL_SPAWN_POINT_OFFSET #:= Vector2(0, -11)
#const BALL_LINEAR_VELOCITY := Vector2(250, 0)


const ANIM__BLUE = "blue"
const ANIM__GREEN = "green"
const ANIM__RED = "red"


const MODULATE_NORMAL = Color(1, 1, 1, 1)
const MODULATE_HYPER_BRIGHT = Color(2, 2, 2, 1)
const FLASH_GLOW_DURATION = 0.2

#

export(float) var ball_dispense_speed : float = 250

#

enum DispenserColor {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
}
export(DispenserColor) var dispenser_color : int = DispenserColor.BLUE setget set_dispenser_color


export(int) var triggerable_count : int setget set_triggerable_count

#

onready var ball_indicator_anim_sprite = $BallIndicatorAnimSprite
onready var triggerable_count_label = $TriggerableCountLabel

#

func _ready():
	#16 = half of this size
	#8 = radius of ball
	BALL_SPAWN_POINT_OFFSET = Vector2(16 + 8, 0)
	
	set_dispenser_color(dispenser_color)
	set_triggerable_count(triggerable_count)

#

func deferred_attempt_trigger_and_spawn_ball():
	call_deferred("trigger_and_spawn_ball")

func attempt_trigger_and_spawn_ball():
	if triggerable_count > 0:
		_spawn_and_launch_ball()
		_tween_make_ball_indicator_flash_glow()
		set_triggerable_count(triggerable_count - 1)

func _spawn_and_launch_ball():
	var ball = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.BALL)
	
	ball.global_position = get_ball_spawn_point()
	StoreOfObjects.helper_ball__configure_as_player_ball_proj(ball, 0, 0)
	
	StoreOfObjects.helper_ball__launch_at_vec(ball, Vector2(ball_dispense_speed, 0).rotated(get_ball_spawn_face_rotation()))
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)
	
	###
	
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_BallDispenserLaunch_01, global_position, 1.0, null)


func get_ball_spawn_point() -> Vector2:
	return global_position + BALL_SPAWN_POINT_OFFSET.rotated(get_ball_spawn_face_rotation())


func get_ball_spawn_face_rotation() -> float:
	return rotation - PI/2


#

func _tween_make_ball_indicator_flash_glow():
	var tweener = create_tween()
	tweener.tween_property(ball_indicator_anim_sprite, "modulate", MODULATE_HYPER_BRIGHT, FLASH_GLOW_DURATION/2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tweener.tween_property(ball_indicator_anim_sprite, "modulate", MODULATE_NORMAL, FLASH_GLOW_DURATION/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	

#

func set_triggerable_count(arg_val):
	triggerable_count = arg_val
	
	if is_inside_tree() or Engine.editor_hint:
		triggerable_count_label.text = str(triggerable_count)
		

#

func set_dispenser_color(arg_color):
	dispenser_color = arg_color
	
	if is_inside_tree() or Engine.editor_hint:
		var anim_name = _get_anim_name_to_play_based_on_dispenser_color()
		anim_sprite.play(anim_name)
		ball_indicator_anim_sprite.play(anim_name)

func _get_anim_name_to_play_based_on_dispenser_color():
	match dispenser_color:
		DispenserColor.BLUE:
			return ANIM__BLUE
		DispenserColor.GREEN:
			return ANIM__GREEN
		DispenserColor.RED:
			return ANIM__RED
	


#########

var _rewinded__triggerable_count

func get_rewind_save_state():
	var state = .get_rewind_save_state()
	
	state["triggerable_count"] = triggerable_count
	
	return state

func load_into_rewind_save_state(arg_state):
	.load_into_rewind_save_state(arg_state)
	
	_rewinded__triggerable_count = arg_state["triggerable_count"]
	

func ended_rewind():
	.ended_rewind()
	
	if _rewinded__triggerable_count != triggerable_count:
		set_triggerable_count(_rewinded__triggerable_count)

