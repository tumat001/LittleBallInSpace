extends MarginContainer

const TooltipPlainTextDescription = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipPlainTextDescription.gd")
const TooltipPlainTextDescriptionScene = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipPlainTextDescription.tscn")
#const TooltipWithTextIndicatorDescription = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipWithTextIndicatorDescription.gd")
#const TooltipWithTextIndicatorDescriptionScene = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipWithTextIndicatorDescription.tscn")
#const TooltipWithImageIndicatorDescription = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipWithImageIndicatorDescription.gd")
#const TooltipWithImageIndicatorDescriptionScene = preload("res://MiscRelated/TooltipRelated/TooltipBodyConstructors/TooltipWithImageIndicatorDescription.tscn")

#

var descriptions : Array = []

var specific_font_colors : Array = []
export(Color) var default_font_color : Color
export(bool)var override_color_of_descs : bool = true

export(int) var default_font_size : int = 20
export(bool) var uses_bbcode : bool = true

var use_custom_size_flags_for_descs : bool = false
var custom_horizontal_size_flags_for_descs : int = SIZE_FILL


var font_id_to_use : int = -1



export(String, MULTILINE) var descriptions__from_export : String

#

enum BBCodeAlignMode {
	LEFT = 0,
	CENTER = 1,
	RIGHT = 2,
}
export(BBCodeAlignMode) var bbcode_align_mode : int

const _bbcode_align_mode_string__left = "%s"
const _bbcode_align_mode_string__center = "[center]%s[/center]"
const _bbcode_align_mode_string__right = "[right]%s[/right]"

#

var text_blip_sound_id_to_play : int = -1

#

onready var row_container = $RowContainer

var tower_for_text_fragment_interpreter
var tower_info_for_text_fragment_interpreter

var use_color_for_dark_background : bool = true

#

var _current_tweener : SceneTreeTween

#

var _count__from_text_blip : int = -1

#

func _ready():
	_set_descriptions__from_export()
	
	update_display()


func _set_descriptions__from_export():
	if descriptions__from_export.length() != 0:
		var descs = descriptions__from_export.rsplit("\n", true)
		#var descs = descriptions__from_export
		for desc_line in descs:
			descriptions.append([desc_line, []])
		
	


#

func update_display():
	rect_min_size.y = 0
	rect_size.y = 0
	
	_kill_all_desc()
	var index = 0
	
	for desc in descriptions:
		var desc_instance
		
		if desc is String:
			desc_instance = TooltipPlainTextDescriptionScene.instance()
			desc_instance.description = desc
#		elif desc is TooltipPlainTextDescription:
#			desc_instance = TooltipPlainTextDescriptionScene.instance()
#		elif desc is TooltipWithTextIndicatorDescription:
#			desc_instance = TooltipWithTextIndicatorDescriptionScene.instance()
#		elif desc is TooltipWithImageIndicatorDescription:
#			desc_instance = TooltipWithImageIndicatorDescriptionScene.instance()
#	
#		if !(desc is String):
#			desc_instance.get_info_from_self_class(desc)
#		
		elif desc is Array: # Arr with [<string>, [TextFragmentInterpreters]]
			var desc_to_use_for_instance = desc[0]
			if uses_bbcode:
				if bbcode_align_mode == BBCodeAlignMode.LEFT:
					desc_to_use_for_instance = _bbcode_align_mode_string__left % desc_to_use_for_instance
				elif bbcode_align_mode == BBCodeAlignMode.CENTER:
					desc_to_use_for_instance = _bbcode_align_mode_string__center % desc_to_use_for_instance
				elif bbcode_align_mode == BBCodeAlignMode.RIGHT:
					desc_to_use_for_instance = _bbcode_align_mode_string__right % desc_to_use_for_instance
				
			
			desc_instance = TooltipPlainTextDescriptionScene.instance()
			desc_instance.description = desc_to_use_for_instance
			desc_instance._text_fragment_interpreters = desc[1]
			desc_instance._use_color_for_dark_background = use_color_for_dark_background
			
		else:
			desc_instance = desc
		
		
		if override_color_of_descs:
			if specific_font_colors.size() > index:
				if specific_font_colors[index] != null:
					desc_instance.color = specific_font_colors[index]
				else:
					desc_instance.color = default_font_color
			else:
				desc_instance.color = default_font_color
		
		if desc_instance.get("font_size"):
			desc_instance.font_size = default_font_size
		
		if font_id_to_use != -1:
			desc_instance.font_id_to_use = font_id_to_use
		
		if use_custom_size_flags_for_descs:
			desc_instance.size_flags_horizontal = custom_horizontal_size_flags_for_descs
			
		
		desc_instance.uses_bbcode = uses_bbcode
		
		if !is_instance_valid(desc_instance._tower):
			desc_instance._tower = tower_for_text_fragment_interpreter
		
		if desc_instance._tower_info == null:
			desc_instance._tower_info = tower_info_for_text_fragment_interpreter
		
		desc_instance.mouse_filter = MOUSE_FILTER_IGNORE
		
		row_container.add_child(desc_instance)
		index += 1
	

func _kill_all_desc():
	for ch in row_container.get_children():
		ch.queue_free()




func _queue_free():
	clear_descriptions_in_array()
	
	.queue_free()

func clear_descriptions_in_array():
	for desc in descriptions:
		if !desc is String:
			desc.queue_free()

#

func set_spacing_per_string_line(arg_val):
	row_container.add_constant_override("separation", arg_val)

#

func get_visible_character_count():
	var count = 0
	for ch in row_container.get_children():
		count += ch.get_visible_character_count()
	
	return count

func set_visible_character_count(arg_count):
	var curr_arg_count = arg_count
	
	for ch in row_container.get_children():
		ch.set_visible_character_count(curr_arg_count)
		
		var ch_count : int = ch.get_visible_character_count()
		
		curr_arg_count -= ch_count
		if curr_arg_count < 0:
			curr_arg_count = -1

func set_visible_character_count__with_text_blip(arg_count):
	if _count__from_text_blip != -1:
		var prev_count__from_text_blip = _count__from_text_blip
		
		_count__from_text_blip = arg_count
		if prev_count__from_text_blip != _count__from_text_blip:
			if text_blip_sound_id_to_play != -1:
				AudioManager.helper__play_sound_effect__plain(text_blip_sound_id_to_play, 1.0, null)
		
	else:
		_count__from_text_blip = 0
	
	set_visible_character_count(arg_count)



func get_percent_visible_character_count():
	var percent_total : float = 0
	
	for ch in row_container.get_children():
		percent_total += ch.get_percent_visible_character_count()
	
	return percent_total /  row_container.get_child_count()

func get_total_character_count():
	var count : int = 0
	
	for ch in row_container.get_children():
		count += ch.get_total_char_count()
	
	return count

#####################

func start_tween_display_of_text(arg_duration_to_finish : bool, arg_func_source, arg_func_name, arg_func_params):
	set_visible_character_count(0)
	
	call_deferred("_deferred_start_vis_character_tween_tween", arg_duration_to_finish, arg_func_source, arg_func_name, arg_func_params)

func _deferred_start_vis_character_tween_tween(arg_duration_to_finish, arg_func_source, arg_func_name, arg_func_params):
	_current_tweener = create_tween()
	var method_current_tweener = _current_tweener.tween_method(self, "set_visible_character_count__with_text_blip", 0, get_total_character_count(), arg_duration_to_finish)
	
	arg_func_source.call(arg_func_name, [_current_tweener, method_current_tweener], arg_func_params)


#

func start_tween_display_of_text__custom_char_count(arg_duration_to_finish : bool,
		initial_vis_char_count, arg_char_count_to_show,
		arg_func_source, arg_func_name, arg_func_params):
	
	set_visible_character_count(initial_vis_char_count)
	
	call_deferred("_deferred_start_vis_character_tween_tween__custom_char_count", arg_duration_to_finish, initial_vis_char_count, arg_char_count_to_show, arg_func_source, arg_func_name, arg_func_params)

func _deferred_start_vis_character_tween_tween__custom_char_count(arg_duration_to_finish, initial_vis_char_count, arg_char_count_to_show, arg_func_source, arg_func_name, arg_func_params):
	_current_tweener = create_tween()
	var method_current_tweener = _current_tweener.tween_method(self, "set_visible_character_count__with_text_blip", initial_vis_char_count, arg_char_count_to_show, arg_duration_to_finish)
	
	arg_func_source.call(arg_func_name, [_current_tweener, method_current_tweener], arg_func_params)




func finish_display_now():
	if _current_tweener != null and _current_tweener.is_running():
		_current_tweener.custom_step(99999)
		return true
		
	else:
		return false

func custom_step_current_tweener(arg_step):
	if _current_tweener != null and _current_tweener.is_running():
		return !_current_tweener.custom_step(arg_step)
		
	else:
		return false

