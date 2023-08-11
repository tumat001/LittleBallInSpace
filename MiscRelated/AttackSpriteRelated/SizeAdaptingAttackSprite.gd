extends "res://MiscRelated/AttackSpriteRelated/AttackSprite.gd"


var size_adapting_to : Node2D setget set_size_adapting_to

export(float) var adapt_ratio : float = 1
var keep_aspect : bool = true

# setter

func set_size_adapting_to(arg : Node2D):
	size_adapting_to = arg
	
	#if is_inside_tree():
	#	change_config_based_on_size_adapting_to()


#

func _ready():
	if is_instance_valid(size_adapting_to):
		change_config_based_on_size_adapting_to()

func change_config_based_on_size_adapting_to():
	var curr_ratio = _get_self_anim_size() / _get_adapting_to_anim_size()
	var final_ratio : Vector2
	
	if keep_aspect:
		final_ratio = curr_ratio * _get_adjustment_of_ratio_to_second_ratio(curr_ratio.x, curr_ratio.y)
	else:
		final_ratio = Vector2((1 / adapt_ratio) / curr_ratio.x, (1 / adapt_ratio) / curr_ratio.y)
	
	scale.x = 1 / final_ratio.x
	scale.y = 1 / final_ratio.y
	
	if size_adapting_to.get("tower_base"):
		position += size_adapting_to.tower_base.position


func _get_adjustment_of_ratio_to_second_ratio(ratio_x : float, ratio_y : float) -> Vector2:
	var base_ratio : float
	var adjusting_ratio : float
	
	if ratio_x > ratio_y:
		base_ratio = ratio_x
		adjusting_ratio = ratio_y
	else:
		base_ratio = ratio_y
		adjusting_ratio = ratio_x
	
	var multiplier = (1 / adapt_ratio) / base_ratio
	
	if ratio_x < ratio_y:
		return Vector2(1 / adapt_ratio, adjusting_ratio * multiplier)
	else:
		return Vector2(adjusting_ratio * multiplier, 1 / adapt_ratio)



# 

func _get_self_anim_size() -> Vector2:
	return frames.get_frame(animation, frame).get_size()

func _get_adapting_to_anim_size() -> Vector2:
	return size_adapting_to.get_current_anim_size()
