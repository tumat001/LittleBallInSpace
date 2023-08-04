extends Control


func _ready():
	var rect_of_screen = get_viewport().get_visible_rect()
	rect_size = Vector2(rect_of_screen.size.x, rect_of_screen.size.y)




