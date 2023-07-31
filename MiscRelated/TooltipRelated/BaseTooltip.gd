extends MarginContainer

var tooltip_owner : Control setget set_tooltip_owner

func set_tooltip_owner(arg_owner : Control):
	if is_instance_valid(tooltip_owner):
		if tooltip_owner.is_connected("visibility_changed", self, "_tooltip_owner_visibility_changed"):
			tooltip_owner.disconnect("visibility_changed", self, "_tooltip_owner_visibility_changed")
			tooltip_owner.disconnect("mouse_exited", self, "_tooltip_owner_mouse_exited")
			tooltip_owner.disconnect("tree_exiting", self, "_tooltip_owner_in_destruction")
	
	tooltip_owner = arg_owner
	
	if is_instance_valid(tooltip_owner):
		if !tooltip_owner.is_connected("visibility_changed", self, "_tooltip_owner_visibility_changed"):
			tooltip_owner.connect("visibility_changed", self, "_tooltip_owner_visibility_changed")
			tooltip_owner.connect("mouse_exited", self, "_tooltip_owner_mouse_exited", [], CONNECT_ONESHOT)
			tooltip_owner.connect("tree_exiting", self, "_tooltip_owner_in_destruction", [], CONNECT_ONESHOT)


func _tooltip_owner_visibility_changed():
	#if tooltip_owner.visible == false:
	tooltip_owner = null
	queue_free()

func _tooltip_owner_mouse_exited():
	tooltip_owner = null
	queue_free()

func _tooltip_owner_in_destruction():
	tooltip_owner = null
	queue_free()


# process

func _process(delta):
	rect_min_size.y = 0
	rect_size.y = 0
	
	var new_position : Vector2 = get_global_mouse_position()
	new_position.x += 20
	
	var tooltip_height : float = rect_size.y
	if new_position.y + tooltip_height + 20 > get_viewport().get_visible_rect().size.y:
		var new_y_pos = new_position.y - tooltip_height
		
		if new_y_pos < 0:
			new_y_pos = new_position.y
			
			# if newly adjusted position makes tooltip dip below
			if new_y_pos + tooltip_height + 20 > get_viewport().get_visible_rect().size.y:
				new_y_pos = 10 #20
		
		new_position.y = new_y_pos
	
	var tooltip_width : float = rect_size.x
	if new_position.x + tooltip_width + 20 > get_viewport().get_visible_rect().size.x:
		new_position.x -= tooltip_width + 20
	
	set_position(new_position, true)
