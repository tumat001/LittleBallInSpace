extends Node2D

#const LineDrawNode = preload("res://MiscRelated/DrawRelated/LineDrawNode/LineDrawNode.gd")

#####################
# DRAW FX PHASE
# 1) star edge beams (starting bot left then clockwise)
# 2) small line-only circle (ease out)
# 3) medium line-only circle (ease out)
# 4) big filling circle (linear)


const SHINE_DELAY_PER_STAR_BEAM : float = 0.5
const SHINE_BEAM_EXTEND_DURATION : float = 0.2

const SHINE_ALL_BEAM_ANGLES : Array = [
	-PI,
	-PI/2,
	0,
	PI/4,
	PI/2 + PI/4,
]

#

var center_pos_of_lines : Vector2

#

onready var star_line_draw_node = $LineDrawNode


####

func start_draw():
	_start_draw_star_beams()
	

func _start_draw_star_beams():
	var tween = create_tween()
	for i in 5:
		var draw_param = star_line_draw_node.DrawParams.new()
		
		var rad_angle = SHINE_ALL_BEAM_ANGLES[i]#i * (2*PI / 5)
		tween.tween_callback(self, "_add_star_line_draw_param__with_angle", [rad_angle, tween, draw_param])
		tween.tween_method(self, "_tween_length_star_line_draw_param", 0.0, 700.0, SHINE_BEAM_EXTEND_DURATION, [draw_param])
		tween.tween_interval(SHINE_DELAY_PER_STAR_BEAM)

func _add_star_line_draw_param__with_angle(arg_angle, arg_tween, draw_param):
	draw_param.angle = arg_angle
	draw_param.center_pos = center_pos_of_lines
	draw_param.length = 0
	draw_param.color = Color("#DAA402")
	draw_param.width = 4
	
	star_line_draw_node.add_draw_param(draw_param)

func _tween_length_star_line_draw_param(arg_length, arg_draw_param):
	arg_draw_param.length = arg_length
	


