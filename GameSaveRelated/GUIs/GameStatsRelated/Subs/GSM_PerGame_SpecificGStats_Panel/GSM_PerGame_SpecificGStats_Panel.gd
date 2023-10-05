extends MarginContainer

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")

#

const LABEL_VAL_DISPLAY__UNSETTED = "N/A"
const LABEL_VAL_DISPLAY__NOT_PRESENT = "N/A"

#

onready var level_name_tooltip_body = $VBoxContainer/LevelDetailsPanel/VBoxContainer/LevelNameTooltipBody

onready var game_time_val_label = $VBoxContainer/StatsVBox/HBox_Time/GameTimeValLabel
onready var rotation_val_label = $VBoxContainer/StatsVBox/HBox_RotationCount/RotationsValLabel
onready var highest_speed_val_label = $VBoxContainer/StatsVBox/HBox_HighestSpeed/HighestSpeedValLabel
onready var time_rewinded_val_label = $VBoxContainer/StatsVBox/HBox_TimeRewinded/TimeRewindedValLabel
onready var ball_shot_val_label = $VBoxContainer/StatsVBox/HBox_BallShotCount/BallsShotValLabel
onready var lowest_energy_val_label = $VBoxContainer/StatsVBox/HBox_LowestEnergy/LowestEnergyValLabel

onready var date_and_time_val_label = $VBoxContainer/HBox_DateTime/DateAndTimeValLabel

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
	level_name_tooltip_body.visible = arg_val

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
	var level_details = StoreOfLevels.generate_or_get_level_details_of_id(arg_level_id)
	if level_details != null:
		level_name_tooltip_body.descriptions = level_details.level_full_name
	else:
		level_name_tooltip_body.descriptions = ["----", []]
		
	
	level_name_tooltip_body.update_display()
	
	#


static func convert_delta_into_time_string(arg_delta):
	var hours = fmod(arg_delta, 3600)
	arg_delta -= hours * 3600
	
	var mins = fmod(arg_delta, 60)
	arg_delta -= mins * 60
	
	var sec = fmod(arg_delta, 1)
	arg_delta -= sec * 1
	
	var msec = arg_delta
	
	#####
	
	if hours != 0:
		return "%02dh, %02dm, %02ds, %04dms" % [hours, mins, sec, msec]
	elif mins != 0:
		return "%02dm, %02ds, %04dms" % [mins, sec, msec]
	else:
		return "%02ds, %04dms" % [sec, msec]
	

static func convert_ISO_datetime_format_info_readable(arg_val : String):
	var year = arg_val.substr(0, 3)
	var month = arg_val.substr(5, 6)
	var day = arg_val.substr(8, 9)
	var hour = arg_val.substr(11, 12)
	var minute = arg_val.substr(14, 15)
	
	return "%02d/%02d/%04d - %02d:%02d" % [day, month, year, hour, minute]


