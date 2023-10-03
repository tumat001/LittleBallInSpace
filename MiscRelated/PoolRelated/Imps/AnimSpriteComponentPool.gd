extends "res://MiscRelated/PoolRelated/GenericPool.gd"



var reclaim_resource_on_anim_finished : bool = true

#

func _init():
	connect("resource_created", self, "_on_component_created", [], CONNECT_PERSIST)
	connect("before_resource_is_taken_from_pool", self, "_on_before_resource_is_taken_from_pool")

func _on_component_created(arg_component : AnimatedSprite):
	arg_component.connect("visibility_changed", self, "_on_compo_visibility_changed", [arg_component], CONNECT_PERSIST)
	
	if reclaim_resource_on_anim_finished:
		arg_component.connect("animation_finished", self, "_on_animation_finished", [arg_component])
	

########

func _on_animation_finished(arg_component):
	arg_component.visible = false

func _on_compo_visibility_changed(arg_component):
	if !arg_component.visible:
		declare_resource_as_available(arg_component)
	

#########

func _on_before_resource_is_taken_from_pool(arg_component):
	_reset_component_for_another_use(arg_component)
	

func _reset_component_for_another_use(arg_component : AnimatedSprite):
	arg_component.frame = 0
	arg_component.visible = true
	


