extends ColorRect



var node_to_follow__screen_based : Node2D

var center_pos

onready var animal_anim_sprite = $AnimalAnimSprite


##

func _ready():
	animal_anim_sprite.connect("sprite_frames_changed", self, "_on_animal_anim_sprite_frames_changed")
	_update_based_on_animal_anim_sprite()
	
	center_pos = rect_size / 2.0
	
	set_process(false)

func _on_animal_anim_sprite_frames_changed(arg_sframes):
	_update_based_on_animal_anim_sprite()
	


func _update_based_on_animal_anim_sprite():
	_make_center_animal_anim_sprite()

func _make_center_animal_anim_sprite():
	animal_anim_sprite.position = center_pos


#

func follow_node_pos__on_screen__centered(arg_node):
	node_to_follow__screen_based = arg_node
	set_process(true)


func _process(delta):
	_update_pos()

func _update_pos():
	if is_instance_valid(node_to_follow__screen_based):
		rect_position = node_to_follow__screen_based.get_viewport_transform().get_origin()


