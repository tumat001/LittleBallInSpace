extends "res://ObjectsRelated/Objects/BaseObject.gd"

signal after_ready()


const COLOR_RED := Color(255/255.0, 14/255.0, 10/255.0)  # reserved for enemies
const COLOR_ORANGE := Color(255/255.0, 128/255.0, 0/255.0)
const COLOR_YELLOW := Color(255/255.0, 251/255.0, 0/255.0)
const COLOR_GREEN := Color(101/255.0, 253/255.0, 78/255.0)
const COLOR_BLUE := Color(78/255.0, 123/255.0, 253/255.0)
const COLOR_VIOLET := Color(165/255.0, 78/255.0, 253/255.0)
const COLOR_WHITE := Color(255/255.0, 255/255.0, 255/255.0)

const all_colors_but_red = [
	#COLOR_RED,
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GREEN,
	COLOR_BLUE,
	COLOR_VIOLET,
	COLOR_WHITE,
]

const all_colors = [
	COLOR_RED,
	
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GREEN,
	COLOR_BLUE,
	COLOR_VIOLET,
	COLOR_WHITE,
]

#

var is_class_type_obj_ball : bool = true


var _start_tween_rainbow_at_ready : bool

#

const BASE_PLAY_SOUND_COOLDOWN_DURATION = 0.1
var _play_sound_cooldown_duration : float = BASE_PLAY_SOUND_COOLDOWN_DURATION

const SOUND_VOLUME_RATIO_DECREASE_PER_BALL : float = 0.05
const SOUND_VOLUME_RATIO_PER_BALL_MIN : float = 0.5
var sound_volume_ratio : float = 1.0

#

var player_dmg__enabled : bool
var player_dmg__flat_damage = 0
var player_dmg__give_bonus_dmg_based_on_lin_vel : bool = false


const ANIM_NAME__DEFAULT = "default"
const ANIM_NAME__ENEMY = "enemy"
var anim_name_to_use : String setget set_anim_name_to_use

#

onready var for_sound_area_2d_coll_shape = $ForSoundArea2D/CollisionShape2D

###

func _ready():
	#randomize_color()
	
	if _start_tween_rainbow_at_ready:
		tween_rainbow_color()
	emit_signal("after_ready")
	
	add_monitor_to_collision_shape_for_rewind(for_sound_area_2d_coll_shape)
	
	set_anim_name_to_use(anim_name_to_use)

#

func set_anim_name_to_use(arg_name):
	anim_name_to_use = arg_name
	
	if is_inside_tree():
		anim_sprite.play(arg_name)


##

func randomize_color_modulate__except_red():
	var rng = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)
	var rand_color = StoreOfRNG.randomly_select_one_element(all_colors_but_red, rng)
	
	modulate = rand_color

func tween_rainbow_color():
	randomize_color_modulate__except_red()
	
	if is_inside_tree():
		_tween_rainbow_color__in_tree()
	else:
		_start_tween_rainbow_at_ready = true

func _tween_rainbow_color__in_tree():
	var tweener = create_tween()
	tweener.set_loops()
	for color in all_colors_but_red:
		tweener.tween_property(self, "modulate", color, 1.0)
	

###########

func _process(delta):
	_play_sound_cooldown_duration -= delta

func _on_ForSoundArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if _play_sound_cooldown_duration <= 0:
			_play_sound_cooldown_duration = BASE_PLAY_SOUND_COOLDOWN_DURATION
			
			if body.get("is_class_type_base_tileset"):
				_area_entered_tileset__play_sound(body_rid, body, body_shape_index, local_shape_index)
			elif body.get("is_player"):
				_area_entered_player__play_sound()
			elif body.get("is_class_type_obj_ball"):
				_area_entered_ball__play_sound()
		

func _area_entered_tileset__play_sound(body_rid, body, body_shape_index, local_shape_index):
	var coordinate: Vector2 = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape_index)
	
	var tilemap : TileMap = body.tilemap
	var cell_id = tilemap.get_cellv(coordinate)
	
	var sound_list_to_play = TileConstants.get_tile_id_to_ball_collision_sound_list(cell_id)
	_play_sound_in_sound_list__from_collision(sound_list_to_play)


func _area_entered_player__play_sound():
	_play_sound_in_sound_list__from_collision(StoreOfObjects.get_ball_collision__with_player__sound_list())
	

func _area_entered_ball__play_sound():
	_play_sound_in_sound_list__from_collision(StoreOfObjects.get_ball_collision__with_ball__sound_list())
	

#

func _play_sound_in_sound_list__from_collision(sound_list_to_play : Array):
	if sound_list_to_play.size() != 0:
		var sound_id_to_play = StoreOfRNG.randomly_select_one_element(sound_list_to_play, SingletonsAndConsts.non_essential_rng)
		AudioManager.helper__play_sound_effect__2d__lower_volume_based_on_dist(sound_id_to_play, global_position, sound_volume_ratio, null, AudioManager.MaskLevel.Minor_SoundFX)
		

#


#func calculate_player_damage(arg_player_lin_vel : Vector2):
#	pass
#



