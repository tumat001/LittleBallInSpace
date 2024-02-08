extends Node2D

#const LineDrawNode = preload("res://MiscRelated/DrawRelated/LineDrawNode/LineDrawNode.gd")

signal draw_phase_01_standard_finished()
signal draw_phase_02_standard_finished()

#####################
# DRAW FX PHASE
# 1) star edge beams (starting bot left then clockwise)
# 2) small line-only circle (ease out)
# 3) medium line-only circle (ease out)
# 4) big filling circle (linear)

const SHINE_DELAY_PER_STAR_BEAM : float = 0.4
const SHINE_BEAM_EXTEND_DURATION : float = 0.2

const SHINE_DELAY_BEFORE_START_OF_SPIN : float = 0.7
const SHINE_MAX_ROT_PER_SEC : float = PI * 0.6
const SHINE_DURATION_TO_REACH_MAX_ROT : float = 1.5
const SHINE_SPIN_DURATION_BEFORE_NEXT_PHASE : float = 4.0

const SHINE_ALL_BEAM_ANGLES : Array = [
	-PI,
	-PI/2,
	0,
	PI/4,
	PI/2 + PI/4,
]


const CIRCLE_SMALL__LIFETIME = 1.75
const CIRCLE_SMALL__DURATION_TO_REACH_MAX = 1.5
const CIRCLE_SMALL__LIFETIME_FOR_TRANSPARENCY = 1.25
const CIRCLE_SMALL__MAX_RADIUS = 100.0
const CIRCLE_SMALL__DELAY_BEFORE_NEXT_PHASE : float = 1.25


const CIRCLE_MED__LIFETIME = 2.5
const CIRCLE_MED__DURATION_TO_REACH_MAX = 1.75
const CIRCLE_MED__LIFETIME_FOR_TRANSPARENCY = 1.5
const CIRCLE_MED__MAX_RADIUS = 140.0
const CIRCLE_MED__DELAY_BEFORE_NEXT_PHASE : float = 1.75


const CIRCLE_LARGE__LIFETIME = 3.5
const CIRCLE_LARGE__DURATION_TO_REACH_MAX = 1.75
const CIRCLE_LARGE__LIFETIME_FOR_TRANSPARENCY = 2.0
const CIRCLE_LARGE__MAX_RADIUS = 200.0
const CIRCLE_LARGE__DELAY_BEFORE_NEXT_PHASE : float = 2.5


const CIRCLE_END__LIFETIME = 900.0
const CIRCLE_END__DURATION_TO_REACH_MAX = 4.0
const CIRCLE_END__LIFETIME_FOR_TRANSPARENCY = 900.0
const CIRCLE_END__MAX_RADIUS = 800.0
const CIRCLE_END__DELAY_BEFORE_NEXT_PHASE : float = 5.0
const CIRCLE_END__MODULATE = Color("#FEEDBA")


#const SHRINK_CIRCLE_END__FINAL_RADIUS = 6.0 
#const SHRINK_CIRCLE_END__DURATION_FOR_SHRINK = 3.0
#const SHRINK_CIRCLE_END__DELAY_BEFORE_NEXT_PHASE = 2.0

const SHRINK_RECT_END__INITIAL_SIZE = Vector2(1300, 1300)
const SHRINK_RECT_END__FINAL_SIZE = Vector2(10, 10)
const SHRINK_RECT_END__DURATION_FOR_SHRINK = 4.0
const SHRINK_RECT_END__DELAY_BEFORE_NEXT_PHASE = 2.0

#

var center_pos_basis : Vector2

var _curr_shine_rot_per_sec : float = 0.0

#var _ending_circle_draw_param
var _ending_rect_draw_param

#

onready var star_line_draw_node = $LineDrawNode
onready var circle_draw_node = $CircleDrawNode
onready var rect_draw_node = $RectDrawNode

####

func _ready():
	set_process(false)

#

func start_draw_phase_01_standard():
	_start_phase__draw_star_beams()


func _start_phase__draw_star_beams():
	var tween = create_tween()
	_start_draw_star_beams__using_tween(tween)
	tween.tween_interval(SHINE_DELAY_BEFORE_START_OF_SPIN)
	tween.tween_callback(self, "_start_phase__rotate_star_beams")

func _start_draw_star_beams__using_tween(tween):
	#var tween = create_tween()
	for i in 5:
		var draw_param = star_line_draw_node.DrawParams.new()
		
		#var rad_angle = SHINE_ALL_BEAM_ANGLES[i]#i * (2*PI / 5)
		var rad_angle = i * (2*PI / 5) + PI/2
		tween.tween_callback(self, "_add_star_line_draw_param__with_angle", [rad_angle, tween, draw_param])
		tween.tween_method(self, "_tween_length_star_line_draw_param", 0.0, 700.0, SHINE_BEAM_EXTEND_DURATION, [draw_param])
		tween.tween_interval(SHINE_DELAY_PER_STAR_BEAM)
	

func _add_star_line_draw_param__with_angle(arg_angle, arg_tween, draw_param):
	draw_param.angle = arg_angle
	draw_param.center_pos = center_pos_basis
	draw_param.length = 0
	draw_param.color = Color("#DAA402")
	draw_param.width = 4
	
	star_line_draw_node.add_draw_param(draw_param)

func _tween_length_star_line_draw_param(arg_length, arg_draw_param):
	arg_draw_param.length = arg_length
	

##

func _start_phase__rotate_star_beams():
	set_process(true)
	
	var rotate = create_tween()
	_start_rotate_star_beams__using_tween(rotate)
	
	var delay_tween = create_tween()
	delay_tween.tween_interval(SHINE_SPIN_DURATION_BEFORE_NEXT_PHASE)
	delay_tween.tween_callback(self, "_start_phase__small_circle")
	

func _start_rotate_star_beams__using_tween(arg_tween : SceneTreeTween):
	arg_tween.tween_property(self, "_curr_shine_rot_per_sec", SHINE_MAX_ROT_PER_SEC, SHINE_DURATION_TO_REACH_MAX_ROT)

##

func _start_phase__small_circle():
	var draw_param = _add_star_circle_draw_param__small_circle_type()
	var circle_tween = create_tween()
	circle_tween.tween_property(draw_param, "current_radius", CIRCLE_SMALL__MAX_RADIUS, CIRCLE_SMALL__DURATION_TO_REACH_MAX).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var delay_tween = create_tween()
	delay_tween.tween_interval(CIRCLE_SMALL__DELAY_BEFORE_NEXT_PHASE)
	delay_tween.tween_callback(self, "_start_phase__medium_circle")

func _add_star_circle_draw_param__small_circle_type():
	var draw_param = circle_draw_node.DrawParams.new()
	draw_param.center_pos = center_pos_basis
	draw_param.current_radius = 0
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color("#6D5201")
	draw_param.outline_width = 3
	draw_param.lifetime_of_draw = CIRCLE_SMALL__LIFETIME
	draw_param.lifetime_to_start_transparency = CIRCLE_SMALL__LIFETIME_FOR_TRANSPARENCY
	
	circle_draw_node.add_draw_param(draw_param)
	
	return draw_param


func _start_phase__medium_circle():
	var draw_param = _add_star_circle_draw_param__medium_circle_type()
	var circle_tween = create_tween()
	circle_tween.tween_property(draw_param, "current_radius", CIRCLE_MED__MAX_RADIUS, CIRCLE_MED__DURATION_TO_REACH_MAX).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var delay_tween = create_tween()
	delay_tween.tween_interval(CIRCLE_MED__DELAY_BEFORE_NEXT_PHASE)
	delay_tween.tween_callback(self, "_start_phase__large_circle")


func _add_star_circle_draw_param__medium_circle_type():
	var draw_param = circle_draw_node.DrawParams.new()
	draw_param.center_pos = center_pos_basis
	draw_param.current_radius = 0
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color("#B18502")
	draw_param.outline_width = 4
	draw_param.lifetime_of_draw = CIRCLE_MED__LIFETIME
	draw_param.lifetime_to_start_transparency = CIRCLE_MED__LIFETIME_FOR_TRANSPARENCY
	
	circle_draw_node.add_draw_param(draw_param)
	
	return draw_param


#

func _start_phase__large_circle():
	var draw_param = _add_star_circle_draw_param__large_circle_type()
	var circle_tween = create_tween()
	circle_tween.tween_property(draw_param, "current_radius", CIRCLE_LARGE__MAX_RADIUS, CIRCLE_LARGE__DURATION_TO_REACH_MAX).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var delay_tween = create_tween()
	delay_tween.tween_interval(CIRCLE_LARGE__DELAY_BEFORE_NEXT_PHASE)
	delay_tween.tween_callback(self, "_start_phase__end_circle")
	

func _add_star_circle_draw_param__large_circle_type():
	var draw_param = circle_draw_node.DrawParams.new()
	draw_param.center_pos = center_pos_basis
	draw_param.current_radius = 0
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color("#33FDC621")
	#draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color("#FDC621")
	draw_param.outline_width = 4
	draw_param.lifetime_of_draw = CIRCLE_LARGE__LIFETIME
	draw_param.lifetime_to_start_transparency = CIRCLE_LARGE__LIFETIME_FOR_TRANSPARENCY
	
	circle_draw_node.add_draw_param(draw_param)
	
	return draw_param



func _start_phase__end_circle():
	var draw_param = _add_star_circle_draw_param__end_circle_type()
	var circle_tween = create_tween()
	circle_tween.tween_property(draw_param, "current_radius", CIRCLE_END__MAX_RADIUS, CIRCLE_END__DURATION_TO_REACH_MAX).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var delay_tween = create_tween()
	delay_tween.tween_interval(CIRCLE_END__DELAY_BEFORE_NEXT_PHASE)
	delay_tween.tween_callback(self, "_on_end_of_draw_phase_01_standard")
	

func _add_star_circle_draw_param__end_circle_type():
	var draw_param = circle_draw_node.DrawParams.new()
	draw_param.center_pos = center_pos_basis
	draw_param.current_radius = 0
	draw_param.radius_per_sec = 0
	draw_param.fill_color = CIRCLE_END__MODULATE
	
	draw_param.outline_color = CIRCLE_END__MODULATE
	draw_param.outline_width = 1
	draw_param.lifetime_of_draw = CIRCLE_END__LIFETIME
	draw_param.lifetime_to_start_transparency = CIRCLE_END__LIFETIME_FOR_TRANSPARENCY
	
	circle_draw_node.add_draw_param(draw_param)
	
	#_ending_circle_draw_param = draw_param
	
	return draw_param



#

func _on_end_of_draw_phase_01_standard():
	emit_signal("draw_phase_01_standard_finished")

##

func _process(delta):
	for param in star_line_draw_node.get_all_draw_params():
		param.angle += delta * _curr_shine_rot_per_sec
		
	


####################


func start_draw_phase_02_standard():
	star_line_draw_node.remove_all_draw_params()
	circle_draw_node.remove_all_draw_params()
	
	_ending_rect_draw_param = _draw_encompassing_rect()
	
	var shrinking_waiting_tween = create_tween()
	#_tween_shrink_ending_rect_draw_param(shrinking_tween)
	shrinking_waiting_tween.tween_interval(SHRINK_RECT_END__DELAY_BEFORE_NEXT_PHASE + SHRINK_RECT_END__DURATION_FOR_SHRINK)
	shrinking_waiting_tween.tween_callback(self, "_on_end_of_draw_phase_02_standard")
	
	var shrink_tween = create_tween()
	shrink_tween.set_parallel(true)
	shrink_tween.tween_property(_ending_rect_draw_param, "current_rect:size", SHRINK_RECT_END__FINAL_SIZE, SHRINK_RECT_END__DURATION_FOR_SHRINK)
	shrink_tween.tween_property(_ending_rect_draw_param, "current_rect:position", center_pos_basis, SHRINK_RECT_END__DURATION_FOR_SHRINK)


func _draw_encompassing_rect():
	var draw_param = rect_draw_node.DrawParams.new()
	
	draw_param.fill_color = CIRCLE_END__MODULATE
	
	draw_param.outline_color = CIRCLE_END__MODULATE
	draw_param.outline_width = 1
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = 0
	draw_param.lifetime_of_draw = 1000
	draw_param.has_lifetime = false
	draw_param.pivot_point = Vector2(0, 0)
	
	var half_size = SHRINK_RECT_END__INITIAL_SIZE / 2
	var initial_rect = Rect2(center_pos_basis - half_size, SHRINK_RECT_END__INITIAL_SIZE)
	draw_param.initial_rect = initial_rect
	#draw_param.target_rect = SHRINK_RECT_END__FINAL_SIZE
	
	rect_draw_node.add_draw_param(draw_param)
	
	return draw_param

#func _tween_shrink_ending_rect_draw_param(arg_tween : SceneTreeTween):
#	arg_tween.tween_property(_ending_rect_draw_param, "current_rect:size", SHRINK_RECT_END__FINAL_SIZE, SHRINK_RECT_END__DURATION_FOR_SHRINK)
#	arg_tween.tween-

func _on_end_of_draw_phase_02_standard():
	emit_signal("draw_phase_02_standard_finished")


#OLD -- CIRCLE
#func start_draw_phase_02_standard():
#	star_line_draw_node.remove_all_draw_params()
#	_remove_all_circle_draw_param_except__ending_circle_draw_param()
#
#	var shrinking_tween = create_tween()
#	_tween_shrink_ending_circle_draw_param(shrinking_tween)
#	shrinking_tween.tween_interval(SHRINK_CIRCLE_END__DELAY_BEFORE_NEXT_PHASE)
#	shrinking_tween.tween_callback(self, "_on_end_of_draw_phase_02_standard")
#
#func _remove_all_circle_draw_param_except__ending_circle_draw_param():
#	for param in circle_draw_node.get_all_draw_params():
#		if param != _ending_circle_draw_param:
#			circle_draw_node.remove_draw_param(param)
#
#
#func _tween_shrink_ending_circle_draw_param(arg_tween : SceneTreeTween):
#	arg_tween.tween_property(_ending_circle_draw_param, "current_radius", SHRINK_CIRCLE_END__FINAL_RADIUS, SHRINK_CIRCLE_END__DURATION_FOR_SHRINK)
#
#func _on_end_of_draw_phase_02_standard():
#	emit_signal("draw_phase_02_standard_finished")


##

#func clear_states__and_make_self_invis():
#	circle_draw_node.remove_all_draw_params()
#	visible = false

