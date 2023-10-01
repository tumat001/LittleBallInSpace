extends MarginContainer

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")


signal display_of_desc_finished(custom_char_count_to_show_upto, arg_metadata)


export(int) var default_font_size : int = 30 setget set_default_font_size

onready var tooltip_body = $TooltipBody

#

export(bool) var cutscene_initially_visible : bool = false

#

var is_class_type_ftq_custom_label : bool = true

#

func _ready():
	grow_horizontal = GROW_DIRECTION_BOTH
	grow_vertical = GROW_DIRECTION_BOTH
	
	tooltip_body.bbcode_align_mode = tooltip_body.BBCodeAlignMode.CENTER
	tooltip_body.default_font_size = default_font_size
	tooltip_body.font_id_to_use = StoreOfFonts.FontTypes.ATARI_CLASSIC_SMOOTH
	
	tooltip_body.grow_horizontal = GROW_DIRECTION_BOTH
	tooltip_body.grow_vertical = GROW_DIRECTION_BOTH
	
	tooltip_body.text_blip_sound_id_to_play = StoreOfAudio.AudioIds.SFX_GUI_CharacterBlip_FTQ

func set_default_font_size(arg_size):
	default_font_size = arg_size
	
	if is_inside_tree():
		tooltip_body.default_font_size = default_font_size

#

func set_desc__and_hide_tooltip(arg_desc):
	tooltip_body.descriptions = arg_desc
	tooltip_body.update_display()
	
	tooltip_body.visible = false
	visible = false

func get_total_char_count_of_desc():
	return tooltip_body.get_total_character_count()

func get_curr_vis_char_count_of_desc():
	return tooltip_body.get_percent_visible_character_count() * tooltip_body.get_total_character_count()



func start_display_of_descs__all_chars(arg_duration, arg_additional_delay_for_finish, arg_metadata):
	start_display_of_descs(arg_duration, arg_additional_delay_for_finish, arg_metadata, 0, tooltip_body.get_total_character_count())

func start_display_of_descs(arg_duration, arg_additional_delay_for_finish,
		arg_metadata, initial_vis_char_count, custom_char_count_to_show_upto):
	
	tooltip_body.start_tween_display_of_text__custom_char_count(arg_duration, initial_vis_char_count, custom_char_count_to_show_upto, self, "_on_tooltip_body_started_displaying_text__tween", [arg_duration, arg_additional_delay_for_finish, custom_char_count_to_show_upto, arg_metadata])
	tooltip_body.visible = true
	visible = true


func _on_tooltip_body_started_displaying_text__tween(details, arg_params):
	var arg_duration = arg_params[0]
	var arg_additional_delay_for_finish = arg_params[1]
	var custom_char_count_to_show_upto = arg_params[2]
	var arg_metadata = arg_params[3]
	
	# tweener if from tooltip body
	var tweener : SceneTreeTween = details[0]
	tweener.tween_callback(self, "_on_tweener_finished_displaying_descs", [custom_char_count_to_show_upto, arg_metadata]).set_delay(arg_duration + arg_additional_delay_for_finish)


func _on_tweener_finished_displaying_descs(custom_char_count_to_show_upto, arg_metadata):
	emit_signal("display_of_desc_finished", custom_char_count_to_show_upto, arg_metadata)
	


##

func finish_display_now():
	tooltip_body.finish_display_now()
	

func custom_step_display_tweener(arg_step : float):
	tooltip_body.custom_step_current_tweener(arg_step)

