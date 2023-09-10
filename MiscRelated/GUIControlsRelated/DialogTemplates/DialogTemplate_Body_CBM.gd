tool
extends MarginContainer


export(Texture) var corner_piece_texture__top_left : Texture setget set_corner_piece_texture__top_left

export(Texture) var border_piece_texture__top : Texture setget set_border_piece_texture__top
export(Texture) var border_piece_texture__left : Texture setget set_border_piece_texture__left

export(Texture) var mid_fill_texture : Texture setget set_mid_fill_texture

#

onready var corner_p_top_left = $GridContainer/CornerP_TopLeft
onready var corner_p_top_right = $GridContainer/CornerP_TopRight
onready var corner_p_bot_left = $GridContainer/CornerP_BotLeft
onready var corner_p_bot_right = $GridContainer/CornerP_BotRight
var all_corner_pieces : Array

onready var border_top = $GridContainer/Border_Top
onready var border_bot = $GridContainer/Border_Bot
onready var border_left = $GridContainer/Border_Left
onready var border_right = $GridContainer/Border_Right
var all_border_verticals : Array
var all_border_horiz : Array

onready var mid_fill = $GridContainer/MidContainer/MidFill

#

func _ready():
	all_corner_pieces.append(corner_p_bot_left)
	all_corner_pieces.append(corner_p_bot_right)
	all_corner_pieces.append(corner_p_top_left)
	all_corner_pieces.append(corner_p_top_right)
	set_corner_piece_texture__top_left(corner_piece_texture__top_left)
	
	all_border_verticals.append(border_bot)
	all_border_verticals.append(border_top)
	set_border_piece_texture__top(border_piece_texture__top)
	
	all_border_horiz.append(border_left)
	all_border_horiz.append(border_right)
	set_border_piece_texture__left(border_piece_texture__left)

#

func set_corner_piece_texture__top_left(arg_texture : Texture):
	corner_piece_texture__top_left = arg_texture
	
	if is_inside_tree() or Engine.editor_hint:
		for corner_piece in all_corner_pieces:
			corner_piece.texture = arg_texture


func set_border_piece_texture__top(arg_texture : Texture):
	border_piece_texture__top = arg_texture
	
	if is_inside_tree() or Engine.editor_hint:
		for border_piece in all_border_verticals:
			border_piece.texture = arg_texture

func set_border_piece_texture__left(arg_texture : Texture):
	border_piece_texture__left = arg_texture
	
	if is_inside_tree() or Engine.editor_hint:
		for border_piece in all_border_horiz:
			border_piece.texture = arg_texture



func set_mid_fill_texture(arg_texture : Texture):
	mid_fill_texture = arg_texture
	
	if is_inside_tree() or Engine.editor_hint:
		mid_fill.texture = arg_texture
	

