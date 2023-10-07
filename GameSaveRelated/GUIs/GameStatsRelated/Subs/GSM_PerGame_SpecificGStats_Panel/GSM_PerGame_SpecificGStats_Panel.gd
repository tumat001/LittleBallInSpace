extends MarginContainer

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")

#

const LABEL_VAL_DISPLAY__UNSETTED = "N/A"
const LABEL_VAL_DISPLAY__NOT_PRESENT = "N/A"

const HBOX_MODULATE__IS_SELECTED_FOR_TYPE = Color("#9AFD8B")
const HBOX_MODULATE__NORMAL = Color(1, 1, 1, 1)


#

onready var level_details_container = $VBoxContainer/LevelDetailsPanel
onready var level_name_tooltip_body = $VBoxContainer/LevelDetailsPanel/VBoxContainer/LevelNameTooltipBody

onready var game_time_val_label = $VBoxContainer/StatsVBox/HBox_Time/GameTimeValLabel
onready var rotation_val_label = $VBoxContainer/StatsVBox/HBox_RotationCount/RotationsValLabel
onready var highest_speed_val_label = $VBoxContainer/StatsVBox/HBox_HighestSpeed/HighestSpeedValLabel
onready var time_rewinded_val_label = $VBoxContainer/StatsVBox/HBox_TimeRewinded/TimeRewindedValLabel
onready var ball_shot_val_label = $VBoxContainer/StatsVBox/HBox_BallShotCount/BallsShotValLabel
onready var lowest_energy_val_label = $VBoxContainer/StatsVBox/HBox_LowestEnergy/LowestEnergyValLabel

onready var date_and_time_val_label = $VBoxContainer/HBox_DateTime/DateAndTimeValLabel


onready var hbox_time = $VBoxContainer/StatsVBox/HBox_Time
onready var hbox_time_rewinded = $VBoxContainer/StatsVBox/HBox_TimeRewinded
onready var hbox_rotation_count = $VBoxContainer/StatsVBox/HBox_RotationCount
onready var hbox_highest_speed = $VBoxContainer/StatsVBox/HBox_HighestSpeed
onready var hbox_ball_shot_count = $VBoxContainer/StatsVBox/HBox_BallShotCount
onready var hbox_lowest_energy = $VBoxContainer/StatsVBox/HBox_LowestEnergy

onready var GAME_STAT_DIC_ID_TO_HBOX_MAP : Dictionary = {
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID : hbox_time,
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID : hbox_time_rewinded,
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID : hbox_rotation_count,
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID : hbox_highest_speed,
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID : hbox_ball_shot_count,
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID : hbox_lowest_energy,
}

#

func _ready():
	level_name_tooltip_body.font_id_to_use = StoreOfFonts.FontTypes.PIXEL_EMULATOR
	level_name_tooltip_body.bbcode_align_mode = level_name_tooltip_body.BBCodeAlignMode.CENTER
	
	

#

#func set_as_empty():
#	game_time_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#	rotation_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#	highest_speed_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#	time_rewinded_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#	ball_shot_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#	lowest_energy_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
#
#	#
#
#	date_and_time_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT


func set_visibility_of_level_name_panel(arg_val):
	level_details_container.visible = arg_val

func set_per_game_details(arg_game_details : Dictionary, arg_level_id):
	# time
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID):
		var time_val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID]
		if time_val != GameStatsManager.current_GE_unsetted__time:
			game_time_val_label.text = convert_delta_into_time_string(time_val)
		else:
			game_time_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		game_time_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# rotation count
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID]
		if val != GameStatsManager.current_GE_unsetted__rotation_count:
			rotation_val_label.text = str(val)
		else:
			rotation_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		rotation_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# highest speed
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID]
		if val != GameStatsManager.current_GE_unsetted__highest_speed:
			highest_speed_val_label.text = str(val)
		else:
			highest_speed_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		highest_speed_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# time rewinded
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID]
		if val != GameStatsManager.current_GE_unsetted__time_spent_in_rewind:
			time_rewinded_val_label.text = str(val)
		else:
			time_rewinded_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		time_rewinded_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# ball shots
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID]
		if val != GameStatsManager.current_GE_unsetted__balls_shot_count:
			ball_shot_val_label.text = str(val)
		else:
			ball_shot_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		ball_shot_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# lowest energy
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID]
		if val != GameStatsManager.current_GE_unsetted__lowest_energy:
			lowest_energy_val_label.text = str(val)
		else:
			lowest_energy_val_label.text = LABEL_VAL_DISPLAY__UNSETTED
	else:
		lowest_energy_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	##############
	# date time
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID]
		date_and_time_val_label.text = convert_ISO_datetime_format_info_readable(val)
		
	else:
		date_and_time_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# level id
	var level_details
	if StoreOfLevels.is_level_id_exists(arg_level_id):
		StoreOfLevels.generate_or_get_level_details_of_id(arg_level_id)
	
	if level_details != null:
		level_name_tooltip_body.descriptions = level_details.level_full_name
	else:
		level_name_tooltip_body.descriptions = [
			["----", []]
		]
		
	
	level_name_tooltip_body.update_display()
	
	#


func set_selected_highlight_hbox_with_stat_type(arg_stat_type):
	for stat_type in GAME_STAT_DIC_ID_TO_HBOX_MAP.keys():
		var hbox = GAME_STAT_DIC_ID_TO_HBOX_MAP[stat_type]
		
		if arg_stat_type == stat_type:
			hbox.modulate = HBOX_MODULATE__IS_SELECTED_FOR_TYPE
		else:
			hbox.modulate = HBOX_MODULATE__NORMAL

func set_selected_highlight_hbox_with_stat_type__none():
	set_selected_highlight_hbox_with_stat_type(-1)



######

static func convert_delta_into_time_string(arg_delta):
	var hours = int(arg_delta) / 3600
	arg_delta -= hours * 3600
	
	var mins = int(arg_delta) / 60
	arg_delta -= mins * 60
	
	var sec = int(arg_delta) / 1
	arg_delta -= sec * 1
	
	var msec = arg_delta * 1000
	
	#####
	
#	if hours != 0:
#		return "%02dh, %02dm, %02ds, %04fms" % [hours, mins, sec, msec]
#	elif mins != 0:
#		return "%02dm, %02ds, %04fms" % [mins, sec, msec]
#	else:
#		return "%02ds, %04fms" % [sec, msec]
	
	if hours != 0:
		return "%02dh, %02d:%02d.%04d" % [hours, mins, sec, msec]
	elif mins != 0:
		return "%02d:%02d.%04d" % [mins, sec, msec]
	else:
		return "%02d.%04d" % [sec, msec]

static func convert_ISO_datetime_format_info_readable(arg_val : String):
	var year = int(arg_val.substr(0, 4))
	var month = int(arg_val.substr(5, 2))
	var day = int(arg_val.substr(8, 2))
	var hour = int(arg_val.substr(11, 2))
	var minute = int(arg_val.substr(14, 2))
	
	return "%02d/%02d/%04d - %02d:%02d" % [day, month, year, hour, minute]


