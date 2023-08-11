extends Reference

const AttackSprite = preload("res://MiscRelated/AttackSpriteRelated/AttackSprite.gd")


var node_to_parent_attack_sprites : Node
var node_to_listen_for_queue_free : Node setget set_node_to_listen_for_queue_free  # if this node queue frees, so must this (all the attack sprites)

var _attack_sprite_pool_to_available_state : Dictionary = {}

var source_for_funcs_for_attk_sprite setget set_source_for_funcs_for_attk_sprite, get_source_for_funcs_for_attk_sprite
var func_name_for_creating_attack_sprite : String

# a one time thing
var func_name_for_setting_attks_sprite_properties_before_add_child : String

# a many time thing
var func_name_for_setting_attks_sprite_properties_when_get_from_pool_after_add_child : String
var func_name_for_setting_attks_sprite_properties_when_get_from_pool_before_add_child : String

var set__attack_sprite_queue_free_if_over__to_false : bool = true


func get_or_create_attack_sprite_from_pool():
	var attk_sprite : AttackSprite = _get_available_attack_sprite_in_pool()
	var is_from_creation : bool = false
	
	if attk_sprite == null or !is_instance_valid(attk_sprite):
		attk_sprite = _create_attack_sprite()
		is_from_creation = true
	
	attk_sprite.visible = true
	
	if is_from_creation and func_name_for_setting_attks_sprite_properties_before_add_child.length() > 0:
		_set_attk_sprite_properties_before_add_child(attk_sprite)
	
	
	if func_name_for_setting_attks_sprite_properties_when_get_from_pool_before_add_child.length() > 0:
		_set_attk_sprite_properties_when_get_from_pool_before_add_child(attk_sprite)
	
	if is_instance_valid(node_to_parent_attack_sprites) and !is_instance_valid(attk_sprite.get_parent()):
		node_to_parent_attack_sprites.add_child(attk_sprite)
	
	if func_name_for_setting_attks_sprite_properties_when_get_from_pool_after_add_child.length() > 0:
		_set_attk_sprite_properties_when_get_from_pool_after_add_child(attk_sprite)
	
	
	_attack_sprite_pool_to_available_state[attk_sprite] = false
	
	return attk_sprite



func if_available_attack_sprite_in_pool():
	return _get_available_attack_sprite_in_pool() != null

func _get_available_attack_sprite_in_pool():
	for attack_sprite in _attack_sprite_pool_to_available_state.keys():
		if _attack_sprite_pool_to_available_state[attack_sprite] == true:
			return attack_sprite
	
	return null


func _create_attack_sprite() -> AttackSprite:
	var attack_sprite : AttackSprite = get_source_for_funcs_for_attk_sprite().call(func_name_for_creating_attack_sprite)
	
	if set__attack_sprite_queue_free_if_over__to_false:
		attack_sprite.queue_free_at_end_of_lifetime = false
		attack_sprite.turn_invisible_at_end_of_lifetime = true
	
	_attack_sprite_pool_to_available_state[attack_sprite] = false
	
	attack_sprite.connect("turned_invisible_from_lifetime_end", self, "_on_attack_sprite_turned_invisible_at_end_of_lifetime", [attack_sprite])
	
	return attack_sprite

func _set_attk_sprite_properties_before_add_child(arg_attk_sprite):
	get_source_for_funcs_for_attk_sprite().call(func_name_for_setting_attks_sprite_properties_before_add_child, arg_attk_sprite)

func _set_attk_sprite_properties_when_get_from_pool_before_add_child(arg_attk_sprite):
	get_source_for_funcs_for_attk_sprite().call(func_name_for_setting_attks_sprite_properties_when_get_from_pool_before_add_child, arg_attk_sprite)

func _set_attk_sprite_properties_when_get_from_pool_after_add_child(arg_attk_sprite):
	get_source_for_funcs_for_attk_sprite().call(func_name_for_setting_attks_sprite_properties_when_get_from_pool_after_add_child, arg_attk_sprite)


func _on_attack_sprite_turned_invisible_at_end_of_lifetime(arg_attk_sprite : AttackSprite):
	if _attack_sprite_pool_to_available_state.has(arg_attk_sprite):
		_attack_sprite_pool_to_available_state[arg_attk_sprite] = true


#

func set_node_to_listen_for_queue_free(arg_node):
	if is_instance_valid(node_to_listen_for_queue_free):
		node_to_listen_for_queue_free.disconnect("tree_exiting", self, "_on_node_to_listen_for_queue_free__tree_exited")
	
	node_to_listen_for_queue_free = arg_node
	
	if is_instance_valid(node_to_listen_for_queue_free):
		node_to_listen_for_queue_free.connect("tree_exiting", self, "_on_node_to_listen_for_queue_free__tree_exited", [], CONNECT_PERSIST)


func _on_node_to_listen_for_queue_free__tree_exited():
	clear_all_attack_sprites_from_pool()


func clear_all_attack_sprites_from_pool():
	for attk_sprite in _attack_sprite_pool_to_available_state:
		if is_instance_valid(attk_sprite) and !attk_sprite.is_queued_for_deletion():
			attk_sprite.queue_free()
	
	_attack_sprite_pool_to_available_state.clear()

#

func set_source_for_funcs_for_attk_sprite(arg_source):
	if arg_source is WeakRef:
		source_for_funcs_for_attk_sprite = arg_source
	else:
		source_for_funcs_for_attk_sprite = weakref(arg_source)

func get_source_for_funcs_for_attk_sprite():
	if source_for_funcs_for_attk_sprite == null:
		return null
	else:
		return source_for_funcs_for_attk_sprite.get_ref()

#####

func clear_pool():
	for attack_sprite in _attack_sprite_pool_to_available_state.keys():
		attack_sprite.queue_free()
	
	_attack_sprite_pool_to_available_state.clear()
	
