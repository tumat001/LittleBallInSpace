extends Node2D



var color_edge_to_use : Color
var color_fill_to_use : Color

var ratio_filled : float = 0 setget set_ratio_filled
var _arc_covered : float

var is_enabled : bool = false setget set_is_enabled

#

func _ready():
	visible = false
	
	set_is_enabled(is_enabled)
	set_ratio_filled(ratio_filled)

#

func set_is_enabled(arg_val):
	is_enabled = arg_val
	set_process(arg_val)
	
	if !arg_val:
		update()

func set_ratio_filled(arg_val):
	ratio_filled = arg_val
	_arc_covered = floor(ratio_filled * 360)


func _process(delta):
	update()
	

#

func _draw():
	# edge
	draw_circle_arc(Vector2.ZERO, 29, 0, _arc_covered - 0, color_fill_to_use, 6)
	# inner fill facing player
	draw_circle_arc(Vector2.ZERO, 32, 0, _arc_covered - 0, color_edge_to_use, 2)
	


func draw_circle_arc(center, radius, angle_from, angle_to, color, line_thickness):
	var nb_points = 54 #32
	var points_arc = PoolVector2Array()
	
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
		#points_arc.append(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, line_thickness)



