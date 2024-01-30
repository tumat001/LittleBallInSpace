extends Area2D

const Player = preload("res://PlayerRelated/Player.gd")

#

const ALPHA_BORDER_MARGIN : int = 3

onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D

#

func _ready():
	if !Engine.editor_hint:
		SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	


func _get_adjusted_sprite_size__remove_alpha_borders():
	var texture_size : Vector2 = sprite.texture.get_size()
	texture_size.x = texture_size.x - (ALPHA_BORDER_MARGIN * 2)
	texture_size.y = texture_size.y - (ALPHA_BORDER_MARGIN * 2)
	
	return texture_size

func _set_coll_shape_to_match_sprite__rect():
	var tex_size = _get_adjusted_sprite_size__remove_alpha_borders()
	var extents_to_use = tex_size / 2
	
	if collision_shape.shape != null:
		collision_shape.shape.set_deferred("extents", extents_to_use)
		
	else:
		var shape = RectangleShape2D.new()
		shape.extents = extents_to_use
		collision_shape.set_deferred("shape", shape)


#

func _on_BasePickupables_body_entered(body):
	if body is Player:
		_on_player_entered_self(body)
	


func _on_player_entered_self(arg_player):
	pass


func _destroy_self__on_consume_by_player():
	collision_shape.set_deferred("disabled", true)
	queue_free()
	

#

func set_collidable_with_player(arg_val):
	set_collision_mask_bit(0, arg_val)
	


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		if !SingletonsAndConsts.current_rewind_manager.is_connected("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables"):
			SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		collision_shape.set_deferred("disabled", true)
		visible = false
		is_dead_but_reserved_for_rewind = true
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()


func get_rewind_save_state():
	return {
		"transform" : transform
	}
	

func load_into_rewind_save_state(arg_state):
	transform = arg_state["transform"]
	


func destroy_from_rewind_save_state():
	.queue_free()
	

func restore_from_destroyed_from_rewind():
	#collision_shape.set_deferred("disabled", false)
	visible = true
	is_dead_but_reserved_for_rewind = false

func started_rewind():
	collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	if !is_dead_but_reserved_for_rewind:
		collision_shape.set_deferred("disabled", false)
	

