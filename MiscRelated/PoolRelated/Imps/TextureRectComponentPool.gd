extends "res://MiscRelated/PoolRelated/GenericPool.gd"



func _init():
	connect("resource_created", self, "_on_component_created", [], CONNECT_PERSIST)

func _on_component_created(arg_component):
	arg_component.connect("visibility_changed", self, "_on_compo_visibility_changed", [arg_component], CONNECT_PERSIST)


func _on_compo_visibility_changed(arg_component):
	if !arg_component.visible:
		declare_resource_as_available(arg_component)
		
