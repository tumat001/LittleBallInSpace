extends "res://MiscRelated/PoolRelated/GenericPool.gd"




func _init():
	connect("resource_created", self, "_on_component_created", [], CONNECT_PERSIST)
	connect("before_resource_is_taken_from_pool", self, "_on_before_resource_is_taken_from_pool")

func _on_component_created(arg_component : Sprite):
	arg_component.connect("visibility_changed", self, "_on_compo_visibility_changed", [arg_component], CONNECT_PERSIST)
	

########
func _on_compo_visibility_changed(arg_component):
	if !arg_component.visible:
		declare_resource_as_available(arg_component)
	

#########

func _on_before_resource_is_taken_from_pool(arg_component):
	_reset_component_for_another_use(arg_component)
	

func _reset_component_for_another_use(arg_component : Sprite):
	arg_component.visible = true
	arg_component.modulate.a = 1.0

##

func make_sprite_invis_using_tweener__then_declare_available(arg_sprite : Sprite, arg_duration_of_invis : float, arg_delay_before_duration : float):
	var tweener = arg_sprite.create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(arg_sprite, "modulate:a", 0.0, arg_duration_of_invis).set_delay(arg_delay_before_duration)
	tweener.tween_callback(self, "_on_tweener_finished", [arg_sprite])

func _on_tweener_finished(arg_sprite):
	arg_sprite.visible = false
	
