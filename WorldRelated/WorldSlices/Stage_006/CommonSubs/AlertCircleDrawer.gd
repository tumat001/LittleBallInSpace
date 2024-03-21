extends Node2D


const CircleDrawNode = preload("res://MiscRelated/DrawRelated/CircleDrawNode/CircleDrawNode.gd")

#

const DRAWER_OUTLINE__DEFAULT_MAX_RADIUS = 200
const DRAWER_OUTLINE__DEFAULT_DURATION = 1.50
const DRAWER_OUTLINE__DEFAULT_COLOR = Color("#CCDA0205")
const DRAWER_OUTLINE__DEFAULT_THICKNESS = 8.0

const DRAWER_FILL__DEFAULT_MAX_RADIUS = 40
const DRAWER_FILL__DEFAULT_DURATION = 1.10
const DRAWER_FILL__DEFAULT_COLOR = Color("#33FD4D4F")

#

export(float) var outline_max_radius : float = DRAWER_OUTLINE__DEFAULT_MAX_RADIUS
export(float) var outline_duration : float = DRAWER_OUTLINE__DEFAULT_DURATION
export(Color) var outline_color : Color = DRAWER_OUTLINE__DEFAULT_COLOR
export(float) var outline_thickness : float = DRAWER_OUTLINE__DEFAULT_THICKNESS

export(float) var fill_max_radius : float = DRAWER_FILL__DEFAULT_MAX_RADIUS
export(float) var fill_duration : float = DRAWER_FILL__DEFAULT_DURATION
export(Color) var fill_color : Color = DRAWER_FILL__DEFAULT_COLOR

#

onready var outline_circ_draw_node = $OutlineCircDrawNode
onready var fill_circ_draw_node = $FillCircDrawNode

##

func _ready() -> void:
	pass
	


##

func do_alert():
	_draw_edge()
	_draw_fill()
	_play_alert_sound()

func _draw_edge():
	var draw_param = CircleDrawNode.DrawParams.new()
	
	draw_param.center_pos = global_position
	draw_param.current_radius = 0
	draw_param.max_radius = outline_max_radius
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color("#00000000")
	
	draw_param.outline_color = outline_color
	draw_param.outline_width = outline_thickness
	
	draw_param.lifetime_of_draw = outline_duration
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = 2 * outline_duration / 3
	
	outline_circ_draw_node.add_draw_param(draw_param)
	
	##
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", draw_param.max_radius, outline_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _draw_fill():
	var draw_param = CircleDrawNode.DrawParams.new()
	
	draw_param.center_pos = global_position
	draw_param.current_radius = 0
	draw_param.max_radius = fill_max_radius
	draw_param.radius_per_sec = 0
	draw_param.fill_color = fill_color
	
	draw_param.outline_color = fill_color
	draw_param.outline_width = 0
	
	draw_param.lifetime_of_draw = fill_duration
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = 2 * fill_duration / 3
	
	outline_circ_draw_node.add_draw_param(draw_param)
	
	##
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", draw_param.max_radius, fill_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _play_alert_sound():
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_LevelSpecific_AlertWarning01, global_position, 1.0)
	


