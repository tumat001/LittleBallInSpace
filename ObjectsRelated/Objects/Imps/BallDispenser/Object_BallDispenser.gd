
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

export(float) var ball_dispense_speed : float = 125

#

enum DispenserColor {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
}
export(DispenserColor) var dispenser_color : int = DispenserColor.BLUE setget set_dispenser_color


export(int) var triggerable_count : int setget set_triggerable_count

#

var _is_done_in_ready : bool = false

#

onready var ball_indicator_anim_sprite = $BallIndicatorAnimSprite
onready var triggerable_count_label = $TriggerableCountLabel

onready var coll_shape_2d__2 = $CollisionShape2D2
onready var coll_shape_2d__3 = $CollisionShape2D3
onready var coll_shape_2d__for_ball_absorb_area = $BallAbsorbArea2D/CollisionShape2D

#

func _ready():
	#16 = half of this size
	#8 = radius of ball
	BALL_SPAWN_POINT_OFFSET = Vector2(16 + 8, 0)
	
	set_dispenser_color(dispenser_color)
	set_triggerable_count(triggerable_count)
	
	add_monitor_to_collision_shape_for_rewind(coll_shape_2d__2)
	add_monitor_to_collision_shape_for_rewind(coll_shape_2d__3)
	add_monitor_to_collision_shape_for_rewind(coll_shape_2d__for_ball_absorb_area)
	
	_is_done_in_ready = true

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
	
	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)
	SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(ball)
	
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
	
	#yeah, use _is_done_in_ready instead of is_inside_tree()...
	if _is_done_in_ready or Engine.editor_hint:
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

func get_rewind_save_state():
	var state = .get_rewind_save_state()
	
	state["triggerable_count"] = triggerable_count
	
	return state

func load_into_rewind_save_state(arg_state):
	.load_into_rewind_save_state(arg_state)
	
	var count = arg_state["triggerable_count"]
	if triggerable_count != count:
		set_triggerable_count(count)


func ended_rewind():
	.ended_rewind()
	

###

func _on_BallAbsorbArea2D_body_entered(body):
	if body.get("is_class_type_obj_ball"):
		if _is_ball_is_considered_moving_toward_self(body):
			_absorb_ball(body)
			

func _is_ball_is_considered_moving_toward_self(arg_ball : RigidBody2D):
	var ball_pos = arg_ball.global_position
	
	var dist = ball_pos.distance_squared_to(global_position)
	var telegraphed_dist = (ball_pos + (arg_ball.linear_velocity * 0.05)).distance_squared_to(global_position)
	
	return telegraphed_dist < dist


func _absorb_ball(arg_ball):
	arg_ball.queue_free()
	set_triggerable_count(triggerable_count + 1)
	
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_BallDispenserAbsorb_01, global_position, 1.0, null)

