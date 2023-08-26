extends "res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Scenes/ES_BaseScene.gd"

#

const Animal_Dog_01 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Dog/EndingSummaryWSP_Dog_0000.png")
const Animal_Dog_02 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Dog/EndingSummaryWSP_Dog_0001.png")
const Animal_Dog_03 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Dog/EndingSummaryWSP_Dog_0002.png")
const Animal_Dog_04 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Dog/EndingSummaryWSP_Dog_0003.png")

const Animal_Cat_01 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Cat/EndingSummaryWSP_Cat_0000.png")
const Animal_Cat_02 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Cat/EndingSummaryWSP_Cat_0001.png")
const Animal_Cat_03 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Cat/EndingSummaryWSP_Cat_0002.png")
const Animal_Cat_04 = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/EndingSummaryWSP/Assets/Cat/EndingSummaryWSP_Cat_0003.png")

#

var first_line__as_true_win = [
	["Victory!", []]
]

var first_line__as_false_win = [
	["Victory?", []]
]



var status_line__as_true_win = [
	[""]
]
var status_line__as_false_win

#

var is_true_victory : bool

#

onready var ftq_label_victory = $FTQ_Label_Victory

onready var player_texture_rect = $PlayerTextureRect
onready var animal_texture_rect = $AnimalTextureRect

onready var ftq_label_status = $FTQ_Label_Status

#

var _animal_animation_tweener : SceneTreeTween

var _animal_frame_idx : int = 0
var _animal_frame_idx_to_texture_map : Dictionary


#

func _ready():
	player_texture_rect.visible = false
	animal_texture_rect.visible = false
	#ftq_label_status.visible = false
	#ftq_label_victory.visible = false
	
	_init_animal_frame_idx_to_texture_map()
	

func start_display():
	.start_display()
	
	if is_true_victory:
		_display_ftq_label_victory__as_true_win()
	else:
		_init_status_line__as_false_win()
		_initialize_texture_rect_saturation_shader(animal_texture_rect)
		_display_ftq_label_victory__as_false_win()
	
	ftq_label_victory.set_anchors_preset(Control.PRESET_CENTER_TOP, true)
	ftq_label_status.set_anchors_preset(Control.PRESET_CENTER_BOTTOM, true)


#########
# FOR TRUE VICTORY
#########

func _display_ftq_label_victory__as_true_win():
	ftq_label_victory.set_desc__and_hide_tooltip(first_line__as_true_win)
	
	ftq_label_victory.start_display_of_descs__all_chars()
	ftq_label_victory.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__first_line__true_vic", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__first_line__true_vic(custom_char_count_to_show_upto, arg_metadata):
	pass
	


#########
# FOR FALSE VIC
##############

func _init_status_line__as_false_win():
	var level_details = StoreOfLevels.generate_or_get_level_details_of_id(GameSaveManager.level_id_died_in)
	
	status_line__as_false_win = [
		["R.I.P. %s" % GameSaveManager.player_name, []],
	]
	if level_details != null:
		var line = ["Died at %s" % [level_details.level_full_name], []]
		status_line__as_false_win.append(line)
	
	
	ftq_label_status.set_desc__and_hide_tooltip(status_line__as_false_win)


#

func _display_ftq_label_victory__as_false_win():
	ftq_label_victory.set_desc__and_hide_tooltip(first_line__as_false_win)
	
	ftq_label_victory.start_display_of_descs(1.75, 0.75, null, 0, 7)
	ftq_label_victory.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__first_line__false_vic_01", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__first_line__false_vic_01(custom_char_count_to_show_upto, arg_metadata):
	ftq_label_victory.start_display_of_descs(0.1, 0.65, null, 7, 8)
	ftq_label_victory.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__first_line__false_vic_02", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__first_line__false_vic_02():
	_tween_display_player_texture_rect("_on_displayed_player_texture_rect__false_vic", 0.35)
	

func _on_displayed_player_texture_rect__false_vic():
	_tween_display_animal_texture_rect("_on_displayed_animal_texutre_rect__false_vic", 0.35)
	

func _on_displayed_animal_texutre_rect__false_vic():
	_set_pre_init_texutre_rect_to_desaturate_using_shaders(animal_texture_rect, "_on_desaturated_animal_texture_rect", 0.5)
	

func _on_desaturated_animal_texture_rect():
	_display_ftq_label_status__as_false_win()
	


func _display_ftq_label_status__as_false_win():
	ftq_label_status.start_display_of_descs(1.0, 0.5, null, 0, 7)
	ftq_label_status.connect("display_of_desc_finished", self, "_display_ftq_label_status__as_false_win_finished__01", [], CONNECT_ONESHOT)

func _display_ftq_label_status__as_false_win_finished__01(custom_char_count_to_show_upto, arg_metadata):
	ftq_label_status.start_display_of_descs(1.0, 0.5, null, 7, ftq_label_status.get_total_char_count_of_desc())
	ftq_label_status.connect("display_of_desc_finished", self, "_display_ftq_label_status__as_false_win_finished__02", [], CONNECT_ONESHOT)


func _display_ftq_label_status__as_false_win_finished__02():
	_start_fade_out()
	


############
# FOR ANY / HELPERS
###########

func _init_animal_frame_idx_to_texture_map():
	if GameSaveManager.animal_choice_id == GameSaveManager.AnimalChoiceId.CAT:
		_animal_frame_idx_to_texture_map[0] = Animal_Cat_01
		_animal_frame_idx_to_texture_map[1] = Animal_Cat_02
		_animal_frame_idx_to_texture_map[2] = Animal_Cat_03
		_animal_frame_idx_to_texture_map[3] = Animal_Cat_04
		
	elif GameSaveManager.animal_choice_id == GameSaveManager.AnimalChoiceId.DOG:
		_animal_frame_idx_to_texture_map[0] = Animal_Dog_01
		_animal_frame_idx_to_texture_map[1] = Animal_Dog_02
		_animal_frame_idx_to_texture_map[2] = Animal_Dog_03
		_animal_frame_idx_to_texture_map[3] = Animal_Dog_04
	

#


func _tween_display_player_texture_rect(arg_func_name_to_call, arg_delay):
	player_texture_rect.modulate.a = 0
	player_texture_rect.visible = true
	
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(player_texture_rect, "modulate:a", 1.0, 1.0)
	tweener.tween_callback(self, arg_func_name_to_call).set_delay(arg_delay)


func _tween_display_animal_texture_rect(arg_func_name_to_call, arg_delay):
	_iterate_over_animal_texture_index()
	
	animal_texture_rect.modulate.a = 0
	animal_texture_rect.visible = true
	
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(animal_texture_rect, "modulate:a", 1.0, 1.0)
	tweener.tween_callback(self, arg_func_name_to_call).set_delay(arg_delay)

	

func _start_animal_texture_rect_animation():
	_animal_animation_tweener = create_tween()
	_animal_animation_tweener.set_loops()
	_animal_animation_tweener.set_parallel(false)
	_animal_animation_tweener.tween_callback(self, "_iterate_over_animal_texture_index").set_delay(0.3)


func _iterate_over_animal_texture_index():
	_animal_frame_idx += 1
	if _animal_frame_idx_to_texture_map.size() <= _animal_frame_idx:
		_animal_frame_idx = 0
	
	animal_texture_rect.texture = _animal_frame_idx_to_texture_map[_animal_frame_idx]



func _initialize_texture_rect_saturation_shader(arg_texture_rect : TextureRect):
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = preload("res://MiscRelated/ShadersRelated/Shader_Saturation.tres")
	
	shader_mat.set_shader_param("saturation", 1.0)
	arg_texture_rect.material = shader_mat

func _set_pre_init_texutre_rect_to_desaturate_using_shaders(arg_texture_rect : TextureRect, arg_func_name_to_call, arg_delay):
	var duration = 1.5
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_method(self, "_on_desaturate_texture_rect", 1.0, 0.0, duration, [arg_texture_rect])
	tweener.tween_callback(self, arg_func_name_to_call).set_delay(arg_delay)

func _on_desaturate_texture_rect(arg_val, arg_texture_rect : TextureRect):
	arg_texture_rect.material.set_shader_param("saturation", arg_val)



#

func _start_fade_out():
	pass
	



