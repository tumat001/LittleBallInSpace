extends MarginContainer

const RewindPanel_MarkerStrip_Pic = preload("res://GameFrontHUDRelated/Subs/RewindPanel/Assets/RewindPanel_MarkerStrip.png")

const TextureRectComponentPool = preload("res://MiscRelated/PoolRelated/Imps/TextureRectComponentPool.gd")

#

const GRADIENT_FILL__TWEEN_DURATION : float = 0.4

const GRADIENT_FILL__TOP_LEFT__STAR := Color("#5500a9")
const GRADIENT_FILL__TOP_RIGHT__STAR := Color("#000000")
const GRADIENT_FILL__BOT_LEFT__STAR := Color("#000000")
const GRADIENT_FILL__BOT_RIGHT__STAR := Color("#131e95")

const GRADIENT_FILL__TOP_LEFT__NORMAL := Color("#322601")
const GRADIENT_FILL__TOP_RIGHT__NORMAL := Color("#000000")
const GRADIENT_FILL__BOT_LEFT__NORMAL := Color("#000000")
const GRADIENT_FILL__BOT_RIGHT__NORMAL := Color("#0f0b00")


const GRADIENT_FILL__TOP_LEFT__PARAM_NAME = "topleft"
const GRADIENT_FILL__TOP_RIGHT__PARAM_NAME = "topright"
const GRADIENT_FILL__BOT_LEFT__PARAM_NAME = "bottomleft"
const GRADIENT_FILL__BOT_RIGHT__PARAM_NAME = "bottomright"


#

const POINTER_Y_POS = 23.0
const POINTER_X_STARTING_POS = 311
const POINTER_X_ENDING_POS = 11

const MARKER_Y_POS = 4
const MARKER_X_STARTING_POS = 307
const MARKER_X_ENDING_POS = 7


const MARKER_PERCENT_MARGIN_FOR_REGISTER : float = 2.0

const TIME_LABEL_TEXT_FORMAT = "%4.2f"

#

var marker_img_texture_rect_compo_pool : TextureRectComponentPool

var _rewind_manager

#

#class DisplayParams:
#	var rewindable_marker_datas : Array # not modified so no need to duplicate

var _datas_size : float

#

var _curr_gradient_fill_shader_tweener : SceneTreeTween

#

onready var marker_container = $VBoxContainer/MarginContainer/Control/MarkerContainer
onready var strip_container = $VBoxContainer/MarginContainer/Control/StripContainer

onready var marker_pointer = $VBoxContainer/MarginContainer/Control/MarkerPointer

onready var time_label = $VBoxContainer/MarginContainer2/MarginContainer/TimeLabel


onready var gradient_fill = $VBoxContainer/MarginContainer/GradientFill
onready var gradient_fill_shader_mat : ShaderMaterial = gradient_fill.material

#######

func _create_texture_rect__for_any_pool():
	var tex_rect = TextureRect.new()
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	return tex_rect

#

func _ready():
	marker_img_texture_rect_compo_pool = TextureRectComponentPool.new()
	marker_img_texture_rect_compo_pool.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	marker_img_texture_rect_compo_pool.node_to_parent = marker_container
	marker_img_texture_rect_compo_pool.source_of_create_resource = self
	marker_img_texture_rect_compo_pool.func_name_for_create_resource = "_create_texture_rect__for_any_pool"
	
	#
	
	_rewind_manager = SingletonsAndConsts.current_rewind_manager
	_rewind_manager.connect("rewindable_datas_pop_back", self, "_on_rewindable_datas_pop_back", [], CONNECT_PERSIST)
	
	visible = false
	
	#
	
	call_deferred("_deferred_ready")

func _deferred_ready():
	_connect_to_source__is_star_collected()
	_update_panel_display_based_on_is_all_stars_collected()


##

func end_show():
	if visible:
		var tweener = create_tween()
		tweener.tween_property(self, "modulate:a", 0.0, 0.3)
		tweener.tween_callback(self, "_on_end_show_mod_a_reached_zero")

func _on_end_show_mod_a_reached_zero():
	visible = false
	
#	for tex_rect in marker_container.get_children():
#		marker_img_texture_rect_compo_pool.declare_resource_as_available(tex_rect)
#		tex_rect.visible = false

######

func start_show(arg_rewindable_marker_datas : Array):
	if !visible:
		modulate.a = 0
		var tweener = create_tween()
		tweener.tween_property(self, "modulate:a", 1.0, 0.3)
		visible = true
	
	_update_display_based_on_datas(arg_rewindable_marker_datas)



func _update_display_based_on_datas(arg_rewindable_marker_datas : Array):
	for tex_rec in marker_container.get_children():
		tex_rec.visible = false
	
	marker_pointer.rect_position.x = POINTER_X_STARTING_POS
	marker_pointer.rect_position.y = POINTER_Y_POS
	
	###########
	
	_datas_size = arg_rewindable_marker_datas.size()
	
	var prog_percentages_taken : Array = []
	
	var total = arg_rewindable_marker_datas.size()
	for i in arg_rewindable_marker_datas.size():
		var mark_type = arg_rewindable_marker_datas[i]
		
		if _rewind_manager.is_mark_type_not_none(mark_type):
			var spot_taken : bool = false
			var prog_percent = 100 - (i / float(total) * 100)
			for taken_percent in prog_percentages_taken:
				if abs(taken_percent - prog_percent) <= MARKER_PERCENT_MARGIN_FOR_REGISTER:
					spot_taken = true
			
			
			if !spot_taken:
				prog_percentages_taken.append(prog_percent)
				
				var img = _rewind_manager.get_texture_for_mark_type(mark_type)
				var tex_rec_for_marker : TextureRect = marker_img_texture_rect_compo_pool.get_or_create_resource_from_pool()
				tex_rec_for_marker.texture = img
				
				var tex_rect_pos_x = _convert_percent_using_num_range(prog_percent, MARKER_X_STARTING_POS, MARKER_X_ENDING_POS)
				
				tex_rec_for_marker.rect_position.y = MARKER_Y_POS
				tex_rec_for_marker.rect_position.x = tex_rect_pos_x
				
				tex_rec_for_marker.visible = true
				
				#print("img: %s, pos: %s, vis: %s, arg_percent: %s, i: %s" % [img, tex_rect_pos_x, tex_rec_for_marker.visible, prog_percent, i])
				

func _convert_percent_using_num_range(arg_percent, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_percent / 100)


func _on_rewindable_datas_pop_back(arg_count):
	var pos_x = _convert_percent_using_num_range(arg_count / _datas_size * 100, POINTER_X_ENDING_POS, POINTER_X_STARTING_POS)
	marker_pointer.rect_position.x = pos_x
	
	time_label.text = TIME_LABEL_TEXT_FORMAT % _rewind_manager.get_current_rewindable_duration_length()


###########


func _connect_to_source__is_star_collected():
	GameSaveManager.connect("tentative_coin_ids_collected_changed__for_curr_level", self, "_on_GSM_tentative_coin_ids_collected_changed__for_curr_level")

func _on_GSM_tentative_coin_ids_collected_changed__for_curr_level(arg_tentative_coin_ids_collected_in_curr_level_id, arg_is_collected, arg_is_all_collected):
	_update_panel_display_based_on_is_all_stars_collected()

func _update_panel_display_based_on_is_all_stars_collected():
	if GameSaveManager.is_all_coins_collected_in_curr_level__tentative():
		# star
		if is_visible_in_tree():
			_tween_set__gradient_fill_color__to_star()
		else:
			_instant_set__gradient_fill_colors__star()
		
	else:
		# normal
		if is_visible_in_tree():
			_tween_set__gradient_fill_color__to_normal()
		else:
			_instant_set__gradient_fill_colors__normal()
	
	
	#print("%s. %s" % [GameSaveManager.is_all_coins_collected_in_curr_level__tentative(), is_visible_in_tree()])



func _instant_set__gradient_fill_colors__normal():
	_set_gradient_fill_shader_mat_params(
		GRADIENT_FILL__TOP_LEFT__NORMAL,
		GRADIENT_FILL__TOP_RIGHT__NORMAL,
		GRADIENT_FILL__BOT_LEFT__NORMAL,
		GRADIENT_FILL__BOT_RIGHT__NORMAL
	)

func _instant_set__gradient_fill_colors__star():
	_set_gradient_fill_shader_mat_params(
		GRADIENT_FILL__TOP_LEFT__STAR,
		GRADIENT_FILL__TOP_RIGHT__STAR,
		GRADIENT_FILL__BOT_LEFT__STAR,
		GRADIENT_FILL__BOT_RIGHT__STAR
	)
	

func _set_gradient_fill_shader_mat_params(arg_top_left : Color, arg_top_right, arg_bot_left, arg_bot_right):
	gradient_fill_shader_mat.set_shader_param(GRADIENT_FILL__TOP_LEFT__PARAM_NAME, arg_top_left)
	gradient_fill_shader_mat.set_shader_param(GRADIENT_FILL__TOP_RIGHT__PARAM_NAME, arg_top_right)
	gradient_fill_shader_mat.set_shader_param(GRADIENT_FILL__BOT_LEFT__PARAM_NAME, arg_bot_left)
	gradient_fill_shader_mat.set_shader_param(GRADIENT_FILL__BOT_RIGHT__PARAM_NAME, arg_bot_right)



func _tween_set__gradient_fill_color__to_normal():
	_attempt_kill_curr_gradient_fill_shader_tweener()
	
	var top_left = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__TOP_LEFT__PARAM_NAME)
	var top_right = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__TOP_RIGHT__PARAM_NAME)
	var bot_left = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__BOT_LEFT__PARAM_NAME)
	var bot_right = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__BOT_RIGHT__PARAM_NAME)
	
	_curr_gradient_fill_shader_tweener = create_tween()
	_curr_gradient_fill_shader_tweener.set_parallel(true)
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", top_left, GRADIENT_FILL__TOP_LEFT__NORMAL, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__TOP_LEFT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", top_right, GRADIENT_FILL__TOP_RIGHT__NORMAL, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__TOP_RIGHT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", bot_left, GRADIENT_FILL__BOT_LEFT__NORMAL, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__BOT_LEFT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", bot_right, GRADIENT_FILL__BOT_RIGHT__NORMAL, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__BOT_RIGHT__PARAM_NAME])

func _tween_set__gradient_fill_color__to_star():
	_attempt_kill_curr_gradient_fill_shader_tweener()
	
	var top_left = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__TOP_LEFT__PARAM_NAME)
	var top_right = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__TOP_RIGHT__PARAM_NAME)
	var bot_left = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__BOT_LEFT__PARAM_NAME)
	var bot_right = gradient_fill_shader_mat.get_shader_param(GRADIENT_FILL__BOT_RIGHT__PARAM_NAME)
	
	_curr_gradient_fill_shader_tweener = create_tween()
	_curr_gradient_fill_shader_tweener.set_parallel(true)
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", top_left, GRADIENT_FILL__TOP_LEFT__STAR, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__TOP_LEFT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", top_right, GRADIENT_FILL__TOP_RIGHT__STAR, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__TOP_RIGHT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", bot_left, GRADIENT_FILL__BOT_LEFT__STAR, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__BOT_LEFT__PARAM_NAME])
	_curr_gradient_fill_shader_tweener.tween_method(self, "_tween_set__gradient_fill_color_val_and_param_name", bot_right, GRADIENT_FILL__BOT_RIGHT__STAR, GRADIENT_FILL__TWEEN_DURATION, [GRADIENT_FILL__BOT_RIGHT__PARAM_NAME])


func _attempt_kill_curr_gradient_fill_shader_tweener():
	if _curr_gradient_fill_shader_tweener != null and _curr_gradient_fill_shader_tweener.is_valid():
		_curr_gradient_fill_shader_tweener.kill()

func _tween_set__gradient_fill_color_val_and_param_name(arg_val, arg_shader_param_name : String):
	gradient_fill_shader_mat.set_shader_param(arg_shader_param_name, arg_val)

