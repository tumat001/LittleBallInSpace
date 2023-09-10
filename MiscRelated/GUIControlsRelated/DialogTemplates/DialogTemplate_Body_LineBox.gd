tool
extends MarginContainer



export(Texture) var border_texture : Texture setget set_border_texture
export(Color) var border_modulate : Color setget set_border_modulate

#export(int) var content_container_omni_margin : int setget set_content_container_omni_margin
export(int) var content_container_margin_bottom : int setget set_content_container_margin_bottom
export(int) var content_container_margin_left : int setget set_content_container_margin_left
export(int) var content_container_margin_right : int setget set_content_container_margin_right
export(int) var content_container_margin_top : int setget set_content_container_margin_top

#

onready var border_left = $BorderLeft
onready var border_right = $BorderRight
onready var border_up = $BorderUp
onready var border_down = $BorderDown
var all_borders : Array

onready var content_container = $ContentContainer

#

func _ready():
	all_borders.append(border_left)
	all_borders.append(border_right)
	all_borders.append(border_up)
	all_borders.append(border_down)
	
	set_border_texture(border_texture)
	set_border_modulate(border_modulate)
	#set_content_container_omni_margin(content_container_omni_margin)
	
	set_content_container_margin_bottom(content_container_margin_bottom)
	set_content_container_margin_left(content_container_margin_left)
	set_content_container_margin_right(content_container_margin_right)
	set_content_container_margin_top(content_container_margin_top)

###

func _can_make_node_changes():
	return is_inside_tree() or Engine.editor_hint


func set_border_texture(arg_val):
	border_texture = arg_val
	
	if _can_make_node_changes():
		for border in all_borders:
			border.texture = border_texture

func set_border_modulate(arg_val):
	border_modulate = arg_val
	
	if _can_make_node_changes():
		for border in all_borders:
			border.modulate = arg_val


#func set_content_container_omni_margin(arg_val):
#	content_container_omni_margin = arg_val
#
#	if is_inside_tree() or Engine.editor_hint:
#		content_container.margin_bottom += content_container_omni_margin
#		content_container.margin_left += content_container_omni_margin
#		content_container.margin_right += content_container_omni_margin
#		content_container.margin_top += content_container_omni_margin
#

func set_content_container_margin_bottom(arg_val):
	content_container_margin_bottom = arg_val
	
	if _can_make_node_changes():
		content_container.add_constant_override("margin_bottom", arg_val)

func set_content_container_margin_left(arg_val):
	content_container_margin_left = arg_val
	
	if _can_make_node_changes():
		content_container.add_constant_override("margin_left", arg_val)

func set_content_container_margin_right(arg_val):
	content_container_margin_right = arg_val
	
	if _can_make_node_changes():
		content_container.add_constant_override("margin_right", arg_val)

func set_content_container_margin_top(arg_val):
	content_container_margin_top = arg_val
	
	if _can_make_node_changes():
		content_container.add_constant_override("margin_top", arg_val)

