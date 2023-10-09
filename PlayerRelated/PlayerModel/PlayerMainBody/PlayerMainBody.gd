extends Node2D


var body_texture setget set_body_texture ,get_body_texture

#

const SHADER_PARAM_NAME__SATURATION = "saturation"

#

#var material_saturation_tweener : SceneTreeTween
var modulate_tweener : SceneTreeTween

onready var body_sprite = $BodySprite

#

func set_body_texture(arg_val):
	body_sprite.texture = arg_val

func get_body_texture():
	return body_sprite.texture

#

func _ready():
	#_initialize_saturation_shader()
	
	GameSettingsManager.connect("player_aesth_config__body_texture_id__changed", self, "_on_player_aesth_config__body_texture_id__changed")
	GameSettingsManager.connect("player_aesth_config__saved_modulate_for_body_texture_id__changed", self, "_on_player_aesth_config__saved_modulate_for_body_texture_id__changed")
	_update_body_texture__based_on_GSettingsM()
	


#func _initialize_saturation_shader():
#	var shader_mat = ShaderMaterial.new()
#	shader_mat.shader = preload("res://MiscRelated/ShadersRelated/Shader_Saturation.tres")
#
#	shader_mat.set_shader_param(SHADER_PARAM_NAME__SATURATION, 1.0)
#	material = shader_mat


#

func _on_player_aesth_config__body_texture_id__changed(arg_id):
	_update_body_texture__based_on_GSettingsM()

func _update_body_texture__based_on_GSettingsM():
	var texture_to_use = GameSettingsManager.player_aesth__get_texture_of_body_texture_id(GameSettingsManager.player_aesth_config__body_texture_id)
	body_sprite.texture = texture_to_use
	
	_update_body_modulate__based_on_GSettingsM()

func _update_body_modulate__based_on_GSettingsM():
	var modulate_to_use = GameSettingsManager.player_aesth_config__body_texture_id_to_saved_modulate_map[GameSettingsManager.player_aesth_config__body_texture_id]
	body_sprite.modulate = modulate_to_use
	

func _on_player_aesth_config__saved_modulate_for_body_texture_id__changed(arg_modulate, arg_id):
	_update_body_modulate__based_on_GSettingsM()

#

## for energy use
func tween_modulate_of_basis(arg_target_modulate : Color, arg_duration):
	if modulate_tweener != null and modulate_tweener.is_valid():
		modulate_tweener.kill()
	
	modulate_tweener = create_tween()
	modulate_tweener.tween_property(self, "modulate", arg_target_modulate, arg_duration)


## for energy usage
#func tween_saturation_of_material(arg_target_saturation : float, arg_duration : float):
#	if material_saturation_tweener != null and material_saturation_tweener.is_valid():
#		material_saturation_tweener.kill()
#
#	var curr_sat : float = material.get_shader_param(SHADER_PARAM_NAME__SATURATION)
#
#	material_saturation_tweener = create_tween()
#	material_saturation_tweener.tween_method(self, "_tween_material_saturation", curr_sat, arg_target_saturation, arg_duration)
#
#func _tween_material_saturation(arg_saturation : float):
#	material.set_shader_param(SHADER_PARAM_NAME__SATURATION, arg_saturation)
#
#	print(arg_saturation)



