extends MarginContainer

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")


signal display_of_desc_finished(custom_char_count_to_show_upto, arg_metadata)


export(int) var default_font_size : int = 30 setget set_default_font_size

onready var tooltip_body = $TooltipBody

#

func _ready():
	tooltip_body.bbcode_align_mode = tooltip_body.BBCodeAlignMode.CENTER
	tooltip_body.default_font_size = default_font_size
	tooltip_body.font_id_to_use = StoreOfFonts.FontTypes.CAROLYN_HANDWRITTEN
	

func set_default_font_size(arg_size):
	default_font_size = arg_size
	
	if is_inside_tree():
		tooltip_body.default_font_size = default_font_size

#

func set_desc__and_hide_tooltip(arg_desc):
	tooltip_body.descriptions = arg_desc
	tooltip_body.update_display()
	
	tooltip_body.visible = false

func get_total_char_count_of_desc():
	return tooltip_body.get_total_character_count()

func get_curr_vis_char_count_of_desc():
	return tooltip_body.get_percent_visible_character_count() * tooltip_body.get_total_character_count()



func start_display_of_descs__all_chars(arg_duration, arg_additional_delay_for_finish, arg_metadata):
	start_display_of_descs(arg_duration, arg_additional_delay_for_finish, arg_metadata, 0, tooltip_body.get_total_character_count())

func start_display_of_descs(arg_duration, arg_additional_delay_for_finish,
		arg_metadata, initial_vis_char_count, custom_char_count_to_show_upto):
	
	tooltip_body.start_tween_display_of_text__custom_char_count(arg_duration, self, initial_vis_char_count, custom_char_count_to_show_upto, "_on_tooltip_body_started_displaying_text__tween", [arg_duration, arg_additional_delay_for_finish, custom_char_count_to_show_upto, arg_metadata])
	tooltip_body.visible = true


func _on_tooltip_body_started_displaying_text__tween(details, arg_params):
	var arg_duration = arg_params[0]
	var arg_additional_delay_for_finish = arg_params[1]
	var custom_char_count_to_show_upto = arg_params[2]
	var arg_metadata = arg_params[3]
	
	var tweener : SceneTreeTween = details[0]
	tweener.tween_callback(self, "_on_tweener_finished_displaying_descs", [arg_metadata]).set_delay(arg_duration + arg_additional_delay_for_finish)


func _on_tweener_finished_displaying_descs(custom_char_count_to_show_upto, arg_metadata):
	emit_signal("display_of_desc_finished", custom_char_count_to_show_upto, arg_metadata)
	


