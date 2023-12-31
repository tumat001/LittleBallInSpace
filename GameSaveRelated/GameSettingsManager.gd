######################
# NOTE:
# WHEN ADDING ASSIST MODES or ids, check: AssistModeDetailsHelper Class
extends Node

#

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")
const AssistModeDetailsHelper = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Data/AssistModeDetailsHelper.gd")
const PlayerMainBody = preload("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerMainBody.tscn")

#

signal settings_manager_initialized()



signal shared_commons__all_color_presets__changed(arg_presets)

signal game_control_is_hidden_changed(arg_game_control_name, arg_is_hidden)
signal secondary_game_control_is_unlocked_changed(arg_secondaty_game_control_id, arg_is_unlocked)

signal game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey)
signal conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts)


signal any_game_modifying_assist_mode_settings_changed()
# use this to display "need restart" label
signal last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed(arg_is_changed)

signal is_assist_mode_first_time_open_changed(arg_val)
signal is_assist_mode_active_changed(arg_val)
signal assist_mode_unlocked_ids_changed(arg_ids)
signal assist_mode_id_unlock_status_changed(arg_id, arg_val)

signal assist_mode_toggle_active_mode_changed(arg_val)
# make these x_mode_changed signals have consistent argument/param count
signal assist_mode__additional_energy_mode_changed(arg_val)
signal assist_mode__energy_reduction_mode_changed(arg_val)
signal assist_mode__additional_launch_ball_mode_changed(arg_val)
signal assist_mode__pause_at_esc_mode_changed(arg_val)


signal settings_config__is_full_screen_changed(arg_val)
signal settings_config__cam_rotation_duration_changed(arg_val)


signal tile_color_config__tile_modulate__normal_changed(arg_val)
signal tile_color_config__tile_modulate__energized_changed(arg_val)
signal tile_color_config__tile_modulate__grounded_changed(arg_val)
signal tile_color_config__tile_modulate__x_changed(arg_tile_energy_type, arg_val)

#signal tile_color_config__tile_presets__normal_changed(arg_presets)
#signal tile_color_config__tile_presets__energized_changed(arg_presets)
#signal tile_color_config__tile_presets__grounded_changed(arg_presets)

signal tile_color_config__tile_presets__for_all_types_changed(arg_presets)



#signal player_aesth_config__body_modulate__changed(arg_modulate)
signal player_aesth_config__body_texture_id__changed(arg_id)
signal player_aesth_config__saved_modulate_for_body_texture_id__changed(arg_modulate, arg_id)

signal player_aesth_config__face_screen_texture_id__changed(arg_id)
signal player_aesth_config__BTId_to_saved_modulate_for_face_screen_texture_id__changed(arg_modulate, arg_id)

signal player_aesth_config__BTId_to_saved_modulate_for_face_expression_texture_id__changed(arg_modulate, arg_id)

#signal player_body_aesth_config_changed(arg_body_modulate, arg_body_pattern_style_id)
#signal player_face_aesth_config_changed(arg_body_modulate, arg_body_pattern_style_id)


##########

const game_control_settings_file_path = "user://game_control_settings.save"


const GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER = "GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER"

var _game_control_name_string_to_is_hidden_map : Dictionary
const GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME : String = "?????"

const GAME_CONTROLS_TO_NAME_MAP = {
	"game_left" : "Move Left",
	"game_right" : "Move Right",
	"game_down" : "Slow to Stop",
	"game_zoom_out" : "Toggle Zoom",
	"rewind" : "Rewind",
	"game_launch_ball" : "Launch Ball",
}
const GAME_CONTROLS_TO_NOT_BE_HIDDEN_BY_DEFAULT = [
	"game_left",
	"game_right"
]
const KEY_PRESS_ACTION_BAN_FOR_GAME_CONTROLS = [
	"Escape",
	"Enter"
]

const MISC_CONTROLS_TO_NAME_MAP = {
	"toggle_hide_hud" : "Toggle Hide/Show HUD",
	"printscreen" : "Screen Shot",
}

#

const GAME_CONTROLS_TO_ALLOW_HOTKEY_SHARING_WITH_NO_WARNING = [
	#[
	#	"game_launch_ball",
	#	"game_fire_hook",
	#]
]

##

const SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER = "SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER"
enum SecondaryControlId {
	MOUSE_SCROLL__LAUNCH_BALL = 0,
}

var _secondary_game_control_id_to_is_unlocked_map : Dictionary

var last_calc__unlocked_status__mouse_scroll_launch_ball

##########################
## general settings

const general_game_settings_file_path = "user://general_game_settings.save"

const SHARED_COMMONS__CATEGORY__DIC_IDENTIFIER = "SHARED_COMMONS__CATEGORY__DIC_IDENTIFIER"
const CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER = "CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER"
const ASSIST_MODE__CATEGORY__DIC_IDENTIFIER = "ASSIST_MODE_CATEGORY__DIC_IDENTFIER"
const SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER = "SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER"
const TILE_COLOR_CONFIG__CATEGORY__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__CATEGORY__DIC_IDENTIFIER"
const PLAYER_AESTH_CONFIG__CATEGORY__DIC_IDENTIFIER = "PLAYER_AESTH_CONFIG__CATEGORY__DIC_IDENTIFIER"

######### SHARED commons
const SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER = "SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER"
var shared_commnons__all_color_presets : Array setget set_shared_commnons__all_color_presets

const shared_commnons__all_color_presets__var_name : String = "shared_commnons__all_color_presets"
const set_shared_commnons__all_color_presets__func_name : String = "set_shared_commnons__all_color_presets"
const shared_commons__all_color_presets__changed__signal_name : String = "shared_commons__all_color_presets__changed"

### Hotkey
var game_control_to_default_event : Dictionary

var _game_control_to_current_event : Dictionary   # used to compare and store pre computeds (last calc)
var _last_calc_game_controls_in_conflicts : Dictionary   # dict of arrs (string -> arr)


### Assist mode
const ASSIST_MODE__TEXT_MODULATE__LIGHT = Color("#44B8FD")
const ASSIST_MODE__TEXT_MODULATE__DARK = Color("#01456D")


const ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER = "ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER"
var is_assist_mode_first_time_open : bool setget set_is_assist_mode_first_time_open


const ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER = "ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER"
var is_assist_mode_active : bool setget set_is_assist_mode_active

const ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_ToggleActiveModeId {
	FOR_THIS_LEVEL_ONLY = 0,
	FOR_ALL_LEVELS = 1,
}
const assist_mode_toggle_active_mode_id__default : int = AssistMode_ToggleActiveModeId.FOR_ALL_LEVELS
var assist_mode_toggle_active_mode_id : int setget set_assist_mode_toggle_active_mode_id


const ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER = "ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER"
enum AssistModeId {
	ADDITIONAL_ENERGY_MODE = 0,
	ENERGY_REDUC_MODE = 1,
	ADDITIONAL_LAUNCH_BALL_MODE = 2,
	PAUSE_AT_ESC_MODE = 3,
}
var _assist_mode__unlocked_ids : Array
const assist_mode__unlocked_ids__default : Array = [
	#AssistModeId.ADDITIONAL_ENERGY_MODE,
	#AssistModeId.ENERGY_REDUC_MODE,
	#AssistModeId.PAUSE_AT_ESC_MODE,
]



const ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_AdditionalEnergyModeId {
	NO_BONUS = 0,
	SMALL_BONUS = 1,
	MEDIUM_BONUS = 2,
	LARGE_BONUS = 3,
	VERY_LARGE_BONUS = 4,
}
const assist_mode__additional_energy_mode_id__details_map : Dictionary = {
	AssistMode_AdditionalEnergyModeId.NO_BONUS : 0,
	AssistMode_AdditionalEnergyModeId.SMALL_BONUS : 5,
	AssistMode_AdditionalEnergyModeId.MEDIUM_BONUS : 15,
	AssistMode_AdditionalEnergyModeId.LARGE_BONUS : 35,
	AssistMode_AdditionalEnergyModeId.VERY_LARGE_BONUS : 485,
	
}
const assist_mode__additional_energy_mode_id__default : int = AssistMode_AdditionalEnergyModeId.MEDIUM_BONUS
const assist_mode__additional_energy_mode_id__no_effect : int = AssistMode_AdditionalEnergyModeId.NO_BONUS
var assist_mode__additional_energy_mode_id : int setget set_assist_mode__additional_energy_mode_id


const ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_EnergyReductionModeId {
	REDUCABLE__NORMAL = 0,
	INFINITE = 1,
}
const assist_mode__energy_reduction_mode_id__default : int = AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL
const assist_mode__energy_reduction_mode_id__no_effect : int = AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL
var assist_mode__energy_reduction_mode_id : int setget set_assist_mode__energy_reduction_mode_id


const ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_AdditionalLaunchBallModeId {
	NO_BALL = 0,
	ONE_BALL = 1,
	TWO_BALL = 2,
	THREE_BALL = 3,
	FOUR_BALL = 4,
	#INFINITE = 5,
}
const assist_mode__additional_launch_ball_mode_id__details_map : Dictionary = {
	AssistMode_AdditionalLaunchBallModeId.NO_BALL : [0, false],
	AssistMode_AdditionalLaunchBallModeId.ONE_BALL : [1, false],
	AssistMode_AdditionalLaunchBallModeId.TWO_BALL : [2, false],
	AssistMode_AdditionalLaunchBallModeId.THREE_BALL : [3, false],
	AssistMode_AdditionalLaunchBallModeId.FOUR_BALL : [4, false],
	#AssistMode_AdditionalLaunchBallModeId.INFINITE : [4, true],
}
const assist_mode__additional_launch_ball_mode_id__default : int = AssistMode_AdditionalLaunchBallModeId.ONE_BALL
const assist_mode__additional_launch_ball_mode_id__no_effect : int = AssistMode_AdditionalLaunchBallModeId.NO_BALL
var assist_mode__additional_launch_ball_mode_id : int setget set_assist_mode__additional_launch_ball_mode_id


const ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER = "ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER"
enum AssistMode_PauseAtESCModeId {
	NO_PAUSE = 0,
	PAUSE = 1,
}
const assist_mode__pause_at_esc_id__default : int = AssistMode_PauseAtESCModeId.NO_PAUSE
const assist_mode__pause_at_esc_id__no_effect : int = AssistMode_PauseAtESCModeId.NO_PAUSE
var assist_mode__pause_at_esc_id : int setget set_assist_mode__pause_at_esc_id



var assist_mode_details_helper : AssistModeDetailsHelper
var _current_assist_mode_id_to_vals_map_at_current_game_elements : Dictionary
var current_assist_mode_is_active_at_current_game_elements : bool
var current_assist_mode_is_active_at_current_game_elements__but_no_effect : bool
var assist_mode_id_to_var_name_map : Dictionary
var assist_mode_id_to_setter_method_name_map : Dictionary
var assist_mode_id_to_val_changed_signal_name_map : Dictionary
var assist_mode_id_to_no_effect_var_name_map : Dictionary

var last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config : bool


###########
#Settings Config

const SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER = "SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER"
var settings_config__is_full_screen : bool setget set_settings_config__is_full_screen
const settings_config__is_full_screen__default : bool = false

const SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER = "SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER"
var settings_config__cam_rotation_duration : float setget set_settings_config__cam_rotation_duration
const settings_config__cam_rotation_duration__default = 0.5


#########
# Tile Color

const TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER"
var tile_color_config__tile_modulate__normal : Color setget set_tile_color_config__tile_modulate__normal
const tile_color_config__tile_modulate__normal__default : Color = Color(1, 1, 1, 1)

#const TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL_PRESETS_DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL_PRESETS_DIC_IDENTIFIER"
#var tile_color_config__tile_modulate__normal_presets : Array setget set_tile_color_config__tile_modulate__normal_preset

#

const TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER"
var tile_color_config__tile_modulate__energized : Color setget set_tile_color_config__tile_modulate__energized
const tile_color_config__tile_modulate__energized__default : Color = Color(217/255.0, 164/255.0, 2/255.0)

#const TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED_PRESETS_DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED_PRESETS_DIC_IDENTIFIER"
#var tile_color_config__tile_modulate__energized_presets : Array setget set_tile_color_config__tile_modulate__energized_preset

#

const TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER"
var tile_color_config__tile_modulate__grounded : Color setget set_tile_color_config__tile_modulate__grounded
const tile_color_config__tile_modulate__grounded__default : Color = Color(172/255.0, 68/255.0, 2/255.0)

#const TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED_PRESETS_DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED_PRESETS_DIC_IDENTIFIER"
#var tile_color_config__tile_modulate__grounded_presets : Array setget set_tile_color_config__tile_modulate__grounded_preset


#const TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER"
#var tile_color_config__tile_modulate__for_all_types_presets : Array setget set_tile_color_config__tile_modulate__for_all_types_preset


##########
#PLAYER AESTH

#const PLAYER_AESTH_CONFIG__BODY_MODULATE__DIC_IDENTIFIER := "PLAYER_AESTH_CONFIG__BODY_MODULATE__DIC_IDENTIFIER"
#var player_aesth_config__body_modulate : Color setget set_player_aesth_config__body_modulate
#var player_aesth_config__body_modulate__default : Color

enum PlayerAesthConfig_BodyTextureId {
	NORMAL = 0,
	
	FLAG__AUSTRALIA = 100,
	FLAG__BRAZIL = 101,
	FLAG__CANADA = 102,
	FLAG__CHINA = 103,
	FLAG__FRANCE = 104,
	FLAG__GERMANY = 105,
	FLAG__INDIA = 106,
	FLAG__ITALY = 107,
	FLAG__JAPAN = 108,
	FLAG__NETHERLANDS = 109,
	FLAG__PHILIPPINES = 110,
	FLAG__RUSSIA = 111,
	FLAG__SPAIN = 112,
	FLAG__UK = 113,
	FLAG__USA = 114,
	FLAG__SOUTH_KOREA = 115,
	
}

const PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID__DIC_IDENTIFIER := "PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID__DIC_IDENTIFIER"
var player_aesth_config__body_texture_id : int setget set_player_aesth_config__body_texture_id
const player_aesth_config__body_texture_id__default : int = PlayerAesthConfig_BodyTextureId.NORMAL

const PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID_TO_SAVED_MODULATE_MAP__DIC_IDENTIFIER = "PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID_TO_SAVED_MODULATE_MAP__DIC_IDENTIFIER"
var player_aesth_config__body_texture_id_to_saved_modulate_map : Dictionary
var player_aesth_config__body_texture_id_to_saved_modulate_for_map__default_for_empty_field := Color("#ffffff")
const _player_aesth_config__body_texture_id_to_saved_modulate_map__default : Dictionary = {
	PlayerAesthConfig_BodyTextureId.NORMAL : Color("#E2FD21"),
	
	# all undefineds are COLOR("ffffff")
}

const PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID = "name"
const PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID = "icon"
const PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID = "bodyCrackModulate"
const player_aesth_config__body_texture_id_to_details_map : Dictionary = {
	PlayerAesthConfig_BodyTextureId.NORMAL : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Plain",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#858585"),
	},
	
	
	PlayerAesthConfig_BodyTextureId.FLAG__AUSTRALIA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Australia",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#000127"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__BRAZIL : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Brazil",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#004C1D"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__CANADA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Canada",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#630310"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__CHINA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: China",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#6E080D"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__FRANCE : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: France",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#5C5C5C"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__GERMANY : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Germany",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#660000"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__INDIA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: India",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__ITALY : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Italy",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__JAPAN : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Japan",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__NETHERLANDS : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Netherlands",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__PHILIPPINES : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Philippines",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__RUSSIA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Russia",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__SOUTH_KOREA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: South Korea",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__SPAIN : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: Spain",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#40080A"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__UK : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: United Kingdom",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#500713"),
	},
	PlayerAesthConfig_BodyTextureId.FLAG__USA : {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID : "Flag: USA",
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID : null,
		PLAYER_AESTH_CONFIG__BODY_CRACK_MODULATE__DIC_ID : Color("#575757"),
	},
	
	
}

const OPTION_BUTTON__LINE_SEPA = -1
const player_aesth_config__body_texture_ids_with_sepa_arr__as_displayed_in_ui : Array = [
	PlayerAesthConfig_BodyTextureId.NORMAL,
	OPTION_BUTTON__LINE_SEPA,
	
	PlayerAesthConfig_BodyTextureId.FLAG__AUSTRALIA,
	PlayerAesthConfig_BodyTextureId.FLAG__BRAZIL,
	PlayerAesthConfig_BodyTextureId.FLAG__CANADA,
	PlayerAesthConfig_BodyTextureId.FLAG__CHINA,
	PlayerAesthConfig_BodyTextureId.FLAG__FRANCE,
	PlayerAesthConfig_BodyTextureId.FLAG__GERMANY,
	PlayerAesthConfig_BodyTextureId.FLAG__INDIA,
	PlayerAesthConfig_BodyTextureId.FLAG__ITALY,
	PlayerAesthConfig_BodyTextureId.FLAG__JAPAN,
	PlayerAesthConfig_BodyTextureId.FLAG__NETHERLANDS,
	PlayerAesthConfig_BodyTextureId.FLAG__PHILIPPINES,
	PlayerAesthConfig_BodyTextureId.FLAG__RUSSIA,
	PlayerAesthConfig_BodyTextureId.FLAG__SOUTH_KOREA,
	PlayerAesthConfig_BodyTextureId.FLAG__SPAIN,
	PlayerAesthConfig_BodyTextureId.FLAG__UK,
	PlayerAesthConfig_BodyTextureId.FLAG__USA,
]


#

enum PlayerAesthConfig_FaceScreenTextureId {
	NORMAL = 0,
	
}

const PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_ID__DIC_IDENTIFIER := "PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_ID__DIC_IDENTIFIER"
var player_aesth_config__face_screen_texture_id : int setget set_player_aesth_config__face_screen_texture_id
const player_aesth_config__face_screen_texture_id__default : int = PlayerAesthConfig_FaceScreenTextureId.NORMAL


const PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_SCREEN_MODULATE_MAP__DIC_IDENTIFIER = "PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_SCREEN_MODULATE_MAP__DIC_IDENTIFIER"
var player_aesth_config__BTId_to_saved_face_screen_modulate_map : Dictionary = {}
const player_aesth_config__BTId_to_saved_face_screen_modulate_map__default_for_empty_field : Color = Color("#88000000")
const _player_aesth_config__BTId_to_saved_face_screen_modulate_map__default : Dictionary = {
	PlayerAesthConfig_BodyTextureId.NORMAL : Color("#2104EC"),
	
}


const PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__NAME__DIC_ID = "name"
const PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__ICON__DIC_ID = "icon"
const player_aesth_config__face_screen_texture_id_to_details_map : Dictionary = {
	PlayerAesthConfig_FaceScreenTextureId.NORMAL : {
		PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__NAME__DIC_ID : "Plain",
		PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__ICON__DIC_ID : null,
	},
}

const player_aesth_config__face_screen_texture_ids_with_sepa_arr__as_displayed_in_ui : Array = [
	PlayerAesthConfig_FaceScreenTextureId.NORMAL,
	
]

#

const PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_EXPRESSION_MODULATE_MAP__DIC_IDENTIFIER = "PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_EXPRESSION_MODULATE_MAP__DIC_IDENTIFIER"
var player_aesth_config__BTId_to_saved_face_expression_modulate_map : Dictionary = {}
const player_aesth_config__BTId_to_saved_face_expression_modulate_map__default_for_empty_field : Color = Color("#90D6FE")
const _player_aesth_config__BTId_to_saved_face_expression_modulate_map__default : Dictionary = {
	PlayerAesthConfig_BodyTextureId.NORMAL : Color("#90D6FE"),
}


####

const COMBAT__DEFAULT_MAX_PLAYER_HEALTH : float = 100.0
var combat__current_max_player_health = COMBAT__DEFAULT_MAX_PLAYER_HEALTH
const COMBAT__DEFAULT_MAX_ENEMY_HEALTH : float = 100.0
var combat__current_max_enemy_health = COMBAT__DEFAULT_MAX_ENEMY_HEALTH

####

var _is_manager_initialized : bool


##############################
#### base methods
#############################

func _save_using_dict(arg_dict, arg_file_path, arg_print_err_msg):
	var save_dict = arg_dict
	var save_file = File.new()
	
	var err_stat = save_file.open(arg_file_path, File.WRITE)
	
	if err_stat != OK:
		print(arg_print_err_msg)
		return
	
	save_file.store_line(to_json(save_dict))
	
	save_file.close()

func _save_using_arr(arg_arr, arg_file_path, arg_print_err_msg):
	var save_arr = arg_arr
	var save_file = File.new()
	
	var err_stat = save_file.open(arg_file_path, File.WRITE)
	
	if err_stat != OK:
		print(arg_print_err_msg)
		return
	
	#for ele in save_arr:
	#	save_file.store_line(to_json(ele))
	save_file.store_line(to_json(arg_arr))
	
	save_file.close()



################################

func load_all__from_ready_of_save_manager():
	_attempt_load_game_controls_related_data()
	_attempt_load_general_game_settings()
	
	
	assist_mode_details_helper = AssistModeDetailsHelper.new()
	
	_is_manager_initialized = true
	emit_signal("settings_manager_initialized")

#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		_save_game_control_related_data()
#		_save_general_game_settings_related_data()

func save_all_related_datas():
	_save_game_control_related_data()
	_save_general_game_settings_related_data()

#################
## CONTROLS RELATED
###################

func _save_game_control_related_data():
	var save_dict = {
		GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER : _game_control_name_string_to_is_hidden_map,
		SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER : _secondary_game_control_id_to_is_unlocked_map
	}
	
	_save_using_dict(save_dict, game_control_settings_file_path, "SAVE ERROR: Control settings")



func _attempt_load_game_controls_related_data():
	var load_file = File.new()
	
	if load_file.file_exists(game_control_settings_file_path):
		var err_stat = load_file.open(game_control_settings_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- Game control settings data")
			return false
		
		_load_main_and_secondary_game_controls_related_data(load_file)
		
		load_file.close()
		return true
		
	else:
		_load_main_and_secondary_game_controls_related_data(null)
		return false

func _load_main_and_secondary_game_controls_related_data(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	###
	
	if data.has(GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER):
		_game_control_name_string_to_is_hidden_map = data[GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER]
	else:
		_initialize_game_control_name_string_map__from_nothing()
	
	##
	
	if data.has(SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER):
		#_secondary_game_control_id_to_is_unlocked_map = data[SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER]
		_initialize_secondary_game_control_name_string_map__from_save_dict(data[SECONDARY_GAME_CONTROLS_ID_TO_IS_UNLOCKED_MAP__DIC_IDENTIFIER])
	else:
		_initialize_secondary_game_control_name_string_map__from_nothing()
		
	


func _initialize_game_control_name_string_map__from_nothing():
	for control_name in GAME_CONTROLS_TO_NAME_MAP.keys():
		if GAME_CONTROLS_TO_NOT_BE_HIDDEN_BY_DEFAULT.has(control_name):
			_game_control_name_string_to_is_hidden_map[control_name] = false
		else:
			_game_control_name_string_to_is_hidden_map[control_name] = true
		


func is_string_game_control_name(arg_text : String):
	return GAME_CONTROLS_TO_NAME_MAP.keys().has(arg_text)

#

func set_game_control_name_string__is_hidden(arg_game_control_name : String, arg_is_hidden : bool):
	_game_control_name_string_to_is_hidden_map[arg_game_control_name] = arg_is_hidden
	
	emit_signal("game_control_is_hidden_changed", arg_game_control_name, arg_is_hidden)

func get_game_control_name__is_hidden(arg_game_control_name : String):
	return _game_control_name_string_to_is_hidden_map[arg_game_control_name]

func get_game_control_name_string_to_is_hidden_map__not_copy():
	return _game_control_name_string_to_is_hidden_map


func is_any_game_control_name_hidden() -> bool:
	for is_hidden in _game_control_name_string_to_is_hidden_map.values():
		if is_hidden:
			return true
	
	return false


## secondary

func _initialize_secondary_game_control_name_string_map__from_save_dict(arg_dict : Dictionary):
	for control_id in arg_dict.keys():
		set_secondary_game_control_id__unlocked_status(int(control_id), arg_dict[control_id])
	
	for control_id in SecondaryControlId.values():
		if !_secondary_game_control_id_to_is_unlocked_map.has(control_id):
			set_secondary_game_control_id__unlocked_status(control_id, false)


func _initialize_secondary_game_control_name_string_map__from_nothing():
	for control_id in SecondaryControlId.values():
		#_secondary_game_control_id_to_is_unlocked_map[control_id] = false
		set_secondary_game_control_id__unlocked_status(control_id, false)


func set_secondary_game_control_id__unlocked_status(arg_control_id, arg_is_unlocked : bool):
	_secondary_game_control_id_to_is_unlocked_map[arg_control_id] = arg_is_unlocked
	
	if arg_control_id == SecondaryControlId.MOUSE_SCROLL__LAUNCH_BALL:
		last_calc__unlocked_status__mouse_scroll_launch_ball = arg_is_unlocked
	
	emit_signal("secondary_game_control_is_unlocked_changed", arg_control_id, arg_is_unlocked)

func get_secondary_game_control_id__unlocked_status(arg_control_id):
	return _secondary_game_control_id_to_is_unlocked_map[arg_control_id]


func get_last_calc__unlocked_status__mouse_scroll_launch_ball():
	return last_calc__unlocked_status__mouse_scroll_launch_ball


####################################
## GENERAL SETTINGS
#####################################

func _save_general_game_settings_related_data():
	var shared_commons_save_dict = _get_shared_commons_as_save_dict()
	var assist_mode_save_dict = _generate_save_dict__for_assist_mode()
	var hotkey_save_dict = _get_game_controls_as_dict()
	var settings_save_dict = _get_settings_as_save_dict()
	var tile_color_save_dict = _get_tile_color_config_as_save_dict()
	var player_aesth_save_dict = _get_player_aesth_config_as_save_dict()
	
	#
	
	var general_game_settings_save_dict = {
		SHARED_COMMONS__CATEGORY__DIC_IDENTIFIER : shared_commons_save_dict,
		ASSIST_MODE__CATEGORY__DIC_IDENTIFIER : assist_mode_save_dict,
		CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER : hotkey_save_dict,
		SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER : settings_save_dict,
		TILE_COLOR_CONFIG__CATEGORY__DIC_IDENTIFIER : tile_color_save_dict,
		PLAYER_AESTH_CONFIG__CATEGORY__DIC_IDENTIFIER : player_aesth_save_dict,
	}
	
	_save_using_dict(general_game_settings_save_dict, general_game_settings_file_path, "SAVE ERROR: general game settings")

func _attempt_load_general_game_settings():
	var load_file = File.new()
	
	if load_file.file_exists(general_game_settings_file_path):
		var err_stat = load_file.open(general_game_settings_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- General game settings")
			return false
		
		_load_general_game_settings_using_file(load_file)
		
		load_file.close()
		return true
		
	else:
		
		_load_general_game_settings_using_file(null)
		return false

func _load_general_game_settings_using_file(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	###
	
	
	if data.has(SHARED_COMMONS__CATEGORY__DIC_IDENTIFIER):
		_load_shared_commons_using_dic(data[SHARED_COMMONS__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_shared_commons_using_dic({})
	
	#
	
	_update_game_control_to_default_event_map()
	if data.has(CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER):
		_load_game_hotkey_using_dic(data[CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER])
	else:
		pass
		#_load_game_hotkey_using_dic()
	_update_states_based_on_game_control_hotkeys__from_ready()
	
	
	#
	
	_init_assist_mode_id_to_x_name_map()
	_init_assist_mode_rel_signals()
	if data.has(ASSIST_MODE__CATEGORY__DIC_IDENTIFIER):
		_load_assist_mode_settings_using_dic(data[ASSIST_MODE__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_assist_mode_settings_using_dic({})
		
	
	#
	
	if data.has(SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER):
		_load_settings_config_using_dic(data[SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_settings_config_using_dic({})
	
	#
	
	if data.has(TILE_COLOR_CONFIG__CATEGORY__DIC_IDENTIFIER):
		_load_tile_color_config_using_dic(data[TILE_COLOR_CONFIG__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_tile_color_config_using_dic({})
	
	#
	
	if data.has(PLAYER_AESTH_CONFIG__CATEGORY__DIC_IDENTIFIER):
		_load_player_aesth_config_using_dic(data[PLAYER_AESTH_CONFIG__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_player_aesth_config_using_dic({})
	
	
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE, true)
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE, true)
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE, true)

############
## SHARED COMMONS


func _load_shared_commons_using_dic(data : Dictionary):
	# COLOR PRESETS
	if data.has(SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER):
		var presets = _convert_color_html_string_arr__into_color_arr(data[SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER])
		set_shared_commnons__all_color_presets(presets)
	else:
		pass
	
	

func set_shared_commnons__all_color_presets(arg_presets):
	shared_commnons__all_color_presets = arg_presets
	
	if _is_manager_initialized:
		emit_signal("shared_commons__all_color_presets__changed", arg_presets)


func _get_shared_commons_as_save_dict():
	return {
		#PLAYER_AESTH_CONFIG__BODY_MODULATE__DIC_IDENTIFIER : player_aesth_config__body_modulate.to_html(true),
		SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER : _convert_color_arr_to_color_html_string_arr(shared_commnons__all_color_presets)
	}

#####################
## HOTKEY

#func reset_all_controls_to_defaults():
#	InputMap.load_from_globals()
#	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
#


func _update_game_control_to_default_event_map():
	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
		game_control_to_default_event[game_control] = get_game_control_input_key_event(game_control)
	


func set_game_control_new_hotkey__using_captured_event(arg_control_action_name : String, arg_captured_event : InputEventKey):
	var old_key_char = get_game_control_hotkey__as_string(arg_control_action_name)
	var new_key_char = arg_captured_event.as_text()
	
	if old_key_char != new_key_char:
		InputMap.action_erase_events(arg_control_action_name)
		InputMap.action_add_event(arg_control_action_name, arg_captured_event)
		
		_update_states_based_on_changed_game_control_hotkeys(arg_control_action_name, arg_captured_event)
		emit_signal("game_control_hotkey_changed", arg_control_action_name, old_key_char, new_key_char)

func _update_states_based_on_changed_game_control_hotkeys(arg_control_action_name, arg_captured_event):
	_game_control_to_current_event[arg_control_action_name] = arg_captured_event
	
	_update_control_conflict_based_on_game_control_hotkeys(_is_manager_initialized)
	

func _update_states_based_on_game_control_hotkeys__from_ready():
	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
		_game_control_to_current_event[game_control] = get_game_control_input_key_event(game_control)
	
	_update_control_conflict_based_on_game_control_hotkeys(true)
	

func _update_control_conflict_based_on_game_control_hotkeys(arg_emit_signal : bool):
	var new_vals = {}
	for game_control_name in _game_control_to_current_event.keys():
		var curr_event : InputEventKey = _game_control_to_current_event[game_control_name]
		var conflicts = calculate_game_control_name_conflicts_when_assigned_to_hotkey(game_control_name, curr_event)
		if conflicts.size() > 0:
			new_vals[game_control_name] = conflicts
	
	
	###
	
	## probably safe to assume it will be in order
	if !deep_equal(new_vals, _last_calc_game_controls_in_conflicts):
		_last_calc_game_controls_in_conflicts = new_vals
		
		if arg_emit_signal:
			emit_signal("conflicting_game_controls_hotkey_changed", _last_calc_game_controls_in_conflicts)


func can_game_control_name_share_input_action_with_game_control_name(arg_name_01, arg_name_02):
	for arr in GAME_CONTROLS_TO_ALLOW_HOTKEY_SHARING_WITH_NO_WARNING:
		if arr.has(arg_name_01) and arr.has(arg_name_02):
			return true
	
	return false

func calculate_game_control_name_conflicts_when_assigned_to_hotkey(arg_control_action_name : String, arg_captured_event : InputEventKey) -> Array:
	var conflicts = []
	
	var curr_event : InputEventKey = arg_captured_event #_game_control_to_current_event[arg_control_action_name]
	for game_control_name__j in _game_control_to_current_event.keys():
		if arg_control_action_name != game_control_name__j:
			var curr_event__j : InputEventKey = _game_control_to_current_event[game_control_name__j]
			if curr_event.as_text() == curr_event__j.as_text():
				if !can_game_control_name_share_input_action_with_game_control_name(arg_control_action_name, game_control_name__j):
					conflicts.append(game_control_name__j)
	
	return conflicts

func calculate_game_control_name_conflicts_when_assigned_to_hotkey__as_control_names(arg_control_action_name : String, arg_captured_event : InputEventKey) -> Array:
	var conflicts_game_control_action_name = calculate_game_control_name_conflicts_when_assigned_to_hotkey(arg_control_action_name, arg_captured_event)
	return convert_game_control_actions_into_names(conflicts_game_control_action_name)

func convert_game_control_actions_into_names(arg_actions : Array) -> Array:
	var bucket = []
	
	for game_control in arg_actions:
		if GAME_CONTROLS_TO_NAME_MAP.has(game_control):
			bucket.append(GAME_CONTROLS_TO_NAME_MAP[game_control])
		else:
			bucket.append(game_control)
	
	return bucket


#

func get_game_control_hotkey__as_string(arg_control_action_name : String):
	var input_events = InputMap.get_action_list(arg_control_action_name)
	
	var key_char : String = ""
	if input_events.size() > 0:
		key_char = input_events[0].as_text()
	
	return key_char

func get_game_control_input_key_event(arg_control_action_name : String):
	var input_events = InputMap.get_action_list(arg_control_action_name)
	if input_events.size() > 0:
		return input_events[0]
	
	return null

func allow_hotkey_to_be_assigned_to_game_control__ignoring_conflicts(arg_captured_event : InputEventKey, arg_control_action_name : String):
	var new_key_char = arg_captured_event.as_text()
	if KEY_PRESS_ACTION_BAN_FOR_GAME_CONTROLS.has(new_key_char):
		return false
		
	else:
		return true



func reset_game_control_hotkey_to_default(arg_control_action_name : String):
	if if_game_control_has_default(arg_control_action_name):
		set_game_control_new_hotkey__using_captured_event(arg_control_action_name, game_control_to_default_event[arg_control_action_name])

func is_game_control_hotkey_default_for_action(arg_control_action_name : String, arg_captured_event : InputEventKey) -> bool:
	if arg_captured_event == null:
		return false
	
	if if_game_control_has_default(arg_control_action_name):
		return arg_captured_event.as_text() == game_control_to_default_event[arg_control_action_name].as_text()
	else:
		return false

func if_game_control_has_default(arg_control_action_name : String) -> bool:
	return game_control_to_default_event.has(arg_control_action_name)

func get_game_control_default(arg_control_action_name : String) -> InputEventKey:
	return game_control_to_default_event[arg_control_action_name]




func get_last_calc_game_control_conflicting_inputs_with_other_controls(arg_control_action_name : String) -> Array:
	if if_last_calc_game_control_has_conflicts(arg_control_action_name):
		return _last_calc_game_controls_in_conflicts[arg_control_action_name]
	else:
		return []

func if_last_calc_game_control_has_conflicts(arg_control_action_name : String):
	return _last_calc_game_controls_in_conflicts.has(arg_control_action_name)

##

func _get_game_controls_as_dict():
	#var all_actions = InputMap.get_actions()
	var dict = {}
	for action_name in GAME_CONTROLS_TO_NAME_MAP.keys():
		var input_events = InputMap.get_action_list(action_name)
		dict[action_name] = _convert_input_events_to_basic_prop_arr(input_events)
	
	return dict

func _convert_input_events_to_basic_prop_arr(arg_input_events : Array):
	var bucket = []
	for event in arg_input_events:
		# Order matters, since this is accessed by _load_game_hotkey_using_file
		bucket.append([event.echo, event.pressed, event.scancode])
	
	return bucket



func _load_game_hotkey_using_dic(data : Dictionary):
	#var data = parse_json(arg_file.get_line())
	if data != null:
		for action_name in data.keys():
			var event_data : Array = data[action_name]
			InputMap.action_erase_events(action_name)
			
			for i in event_data.size():
				var key_event : InputEventKey = InputEventKey.new()
				var key_data = event_data[i]
				key_event.echo = key_data[0]
				key_event.pressed = key_data[1]
				key_event.scancode = key_data[2]
				
				InputMap.action_add_event(action_name, key_event)



######################
## ASSIST MODE

func _init_assist_mode_id_to_x_name_map():
	assist_mode_id_to_var_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_id"
	
	assist_mode_id_to_setter_method_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "set_assist_mode__additional_energy_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.ENERGY_REDUC_MODE] = "set_assist_mode__energy_reduction_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "set_assist_mode__additional_launch_ball_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "set_assist_mode__pause_at_esc_id"
	
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_mode_changed"
	
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_id__no_effect"
	


func _init_assist_mode_rel_signals():
	connect("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed__for_GE")
	
	if is_instance_valid(SingletonsAndConsts.current_master):
		_connect_signals_with_master()
	else:
		SingletonsAndConsts.connect("current_master_setted", self, "_on_current_master_setted", [], CONNECT_ONESHOT)


func _load_assist_mode_settings_using_dic(data : Dictionary):
	if data.has(ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER):
		set_is_assist_mode_first_time_open(data[ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER])
	else:
		set_is_assist_mode_first_time_open(false)
	
	if data.has(ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER):
		set_is_assist_mode_active(data[ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER])
	else:
		set_is_assist_mode_active(false)
	
	if data.has(ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER):
		var arr_with_str = data[ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER]
		set_assist_mode_ids_unlocked_status__using_array(_convert_arr_of_string_to_arr_of_int(arr_with_str))
	else:
		set_assist_mode_ids_unlocked_status__using_array(assist_mode__unlocked_ids__default)
	
	
	
	if data.has(ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode_toggle_active_mode_id(int(id_as_str))
	else:
		set_assist_mode_toggle_active_mode_id(assist_mode_toggle_active_mode_id__default)
	
	if data.has(ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__additional_energy_mode_id(int(id_as_str))
	else:
		set_assist_mode__additional_energy_mode_id(assist_mode__additional_energy_mode_id__default)
	
	if data.has(ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__energy_reduction_mode_id(int(id_as_str))
	else:
		set_assist_mode__energy_reduction_mode_id(assist_mode__energy_reduction_mode_id__default)
	
	if data.has(ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__additional_launch_ball_mode_id(int(id_as_str))
	else:
		set_assist_mode__additional_launch_ball_mode_id(assist_mode__additional_launch_ball_mode_id__default)
	
	if data.has(ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER]
		set_assist_mode__pause_at_esc_id(int(id_as_str))
	else:
		set_assist_mode__pause_at_esc_id(assist_mode__pause_at_esc_id__default)
	


func _convert_arr_of_string_to_arr_of_int(arg_arr : Array):
	var bucket = []
	for num_as_str in arg_arr:
		bucket.append(int(num_as_str))
	return bucket



func _generate_save_dict__for_assist_mode():
	return {
		ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER : is_assist_mode_first_time_open,
		ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER : is_assist_mode_active,
		ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER : _assist_mode__unlocked_ids,
		ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER : assist_mode_toggle_active_mode_id,
		
		ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER : assist_mode__additional_energy_mode_id,
		ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER : assist_mode__energy_reduction_mode_id,
		ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER : assist_mode__additional_launch_ball_mode_id,
		ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER : assist_mode__pause_at_esc_id,
		
	}


func is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals():
	if is_current_assist_mode__additional_energy__has_effect():
		return true
	
	if is_current_assist_mode__energy_reduction__has_effect():
		return true
	
	if is_current_assist_mode__additional_launch_ball__has_effect():
		return true
	
	if is_current_assist_mode__pause_at_esc__has_effect():
		return true
	
	###
	
	return false

#

func set_is_assist_mode_first_time_open(arg_val):
	var old_val = is_assist_mode_first_time_open
	is_assist_mode_first_time_open = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("is_assist_mode_first_time_open_changed", arg_val)


func _any_game_modifying_assist_mode_config_changed():
	emit_signal("any_game_modifying_assist_mode_settings_changed")

func set_is_assist_mode_active(arg_val):
	var old_val = is_assist_mode_active
	is_assist_mode_active = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("is_assist_mode_active_changed", arg_val)
			if is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals():
				_any_game_modifying_assist_mode_config_changed()

func set_assist_mode_toggle_active_mode_id(arg_val):
	var old_val = assist_mode_toggle_active_mode_id
	assist_mode_toggle_active_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode_toggle_active_mode_changed", arg_val)
			#_any_game_modifying_assist_mode_config_changed()


func set_assist_mode_id_unlocked_status(arg_id, arg_is_unlocked_val):
	if arg_is_unlocked_val:
		if !_assist_mode__unlocked_ids.has(arg_id):
			_assist_mode__unlocked_ids.append(arg_id)
			
			if _is_manager_initialized:
				emit_signal("assist_mode_id_unlock_status_changed", arg_id, arg_is_unlocked_val)
				emit_signal("assist_mode_unlocked_ids_changed", _assist_mode__unlocked_ids)
	else:
		if _assist_mode__unlocked_ids.has(arg_id):
			_assist_mode__unlocked_ids.erase(arg_id)
			
			if _is_manager_initialized:
				emit_signal("assist_mode_id_unlock_status_changed", arg_id, arg_is_unlocked_val)
				emit_signal("assist_mode_unlocked_ids_changed", _assist_mode__unlocked_ids)
	
	#print("%s, %s, %s" % [arg_id, arg_is_unlocked_val, _assist_mode__unlocked_ids])

# all other ids not found here will be locked
func set_assist_mode_ids_unlocked_status__using_array(arg_ids_to_set_as_unlocked):
	for id in AssistModeId.values():
		if arg_ids_to_set_as_unlocked.has(id):
			set_assist_mode_id_unlocked_status(id, true)
		else:
			set_assist_mode_id_unlocked_status(id, false)

func is_assist_mode_id_unlocked(arg_id):
	return _assist_mode__unlocked_ids.has(arg_id)

func is_all_assist_mode_ids_unlocked():
	return _assist_mode__unlocked_ids.size() == AssistModeId.size()

func is_any_assist_mode_id_unlocked():
	return _assist_mode__unlocked_ids.size() != 0

####

func set_assist_mode__additional_energy_mode_id(arg_val):
	var old_val = assist_mode__additional_energy_mode_id
	assist_mode__additional_energy_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__additional_energy_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func get_assist_mode__additional_energy_amount_from_current_id():
	return assist_mode__additional_energy_mode_id__details_map[assist_mode__additional_energy_mode_id]

func get_assist_mode__additional_energy_amount_from_id(arg_id):
	return assist_mode__additional_energy_mode_id__details_map[arg_id]

func is_current_assist_mode__additional_energy__has_effect():
	return assist_mode__additional_energy_mode_id != assist_mode__additional_energy_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ADDITIONAL_ENERGY_MODE)

#

func set_assist_mode__energy_reduction_mode_id(arg_val):
	var old_val = assist_mode__energy_reduction_mode_id
	assist_mode__energy_reduction_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__energy_reduction_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__energy_reduction__has_effect():
	return assist_mode__energy_reduction_mode_id != assist_mode__energy_reduction_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ENERGY_REDUC_MODE)


#

func set_assist_mode__additional_launch_ball_mode_id(arg_val):
	var old_val = assist_mode__additional_launch_ball_mode_id
	assist_mode__additional_launch_ball_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__additional_launch_ball_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__additional_launch_ball__has_effect():
	return assist_mode__additional_launch_ball_mode_id != assist_mode__additional_launch_ball_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE)

func get_assist_mode__additional_launch_ball_details_from_current_id():
	return assist_mode__additional_launch_ball_mode_id__details_map[assist_mode__additional_launch_ball_mode_id]

#

func set_assist_mode__pause_at_esc_id(arg_val):
	var old_val = assist_mode__pause_at_esc_id
	assist_mode__pause_at_esc_id = arg_val
	
	#print("setted pause at esc %s" % arg_val)
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__pause_at_esc_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__pause_at_esc__has_effect():
	return assist_mode__pause_at_esc_id != assist_mode__pause_at_esc_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.PAUSE_AT_ESC_MODE)


#### ASSIST MODE GAME MODI
func attempt_make_game_modifications__based_on_curr_assist_mode_config__before_all():
	_before_game__register_current_assist_mode_id_vals()
	_before_game__setup_assist_mode__pause_on_esc_changes()
	

func attempt_make_game_modifications__based_on_curr_assist_mode_config():
	if is_assist_mode_active and !SingletonsAndConsts.current_level_details.ignore_assist_mode_modifications:
		_before_game__setup_modifications__based_on_curr_assist_mode_config()
		

func _before_game__setup_modifications__based_on_curr_assist_mode_config():
	_before_game__setup_assist_mode__player_modi__changes()
	

# Player modi related assist modif
func _before_game__setup_assist_mode__player_modi__changes():
	SingletonsAndConsts.current_game_elements.player_modi_manager.connect("before_modi_is_configured", self, "_on_before_modi_is_configured__for_assist_mode")
	

func _on_before_modi_is_configured__for_assist_mode(arg_modi):
	if arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.ENERGY:
		if is_current_assist_mode__additional_energy__has_effect():
			arg_modi.make_assist_mode_modification__additional_energy()
		
		if is_current_assist_mode__energy_reduction__has_effect():
			arg_modi.make_assist_mode_modification__energy_reduction_mode()
		
	elif arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL:
		if is_current_assist_mode__additional_launch_ball__has_effect():
			arg_modi.make_assist_mode_modification__additional_launch_ball()
	

func _before_game__setup_assist_mode__pause_on_esc_changes():
	if is_assist_mode_active:
		if is_current_assist_mode__pause_at_esc__has_effect():
			if assist_mode__pause_at_esc_id == AssistMode_PauseAtESCModeId.PAUSE:
				SingletonsAndConsts.current_game_elements.pause_game_at_startup = true
			elif assist_mode__pause_at_esc_id == AssistMode_PauseAtESCModeId.NO_PAUSE:
				SingletonsAndConsts.current_game_elements.pause_game_at_startup = false



func _before_game__register_current_assist_mode_id_vals():
	for id in AssistModeId.values():
		var curr_val = get(assist_mode_id_to_var_name_map[id])
		_current_assist_mode_id_to_vals_map_at_current_game_elements[id] = curr_val
	
	current_assist_mode_is_active_at_current_game_elements = is_assist_mode_active
	current_assist_mode_is_active_at_current_game_elements__but_no_effect = !is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals()
	
	last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = false

func _on_any_game_modifying_assist_mode_settings_changed__for_GE():
	if is_instance_valid(SingletonsAndConsts.current_game_elements):
		var old_val = last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config
		
		if _is_any_change_difference_from_assist_mode_config_to_current_GE_assist_mode_config():
			last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = true
		else:
			last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = false
		
		if old_val != last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config:
			emit_signal("last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed", last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config)


func _is_any_change_difference_from_assist_mode_config_to_current_GE_assist_mode_config() -> bool:
	if current_assist_mode_is_active_at_current_game_elements != is_assist_mode_active:
		return true
	
	for id in AssistModeId.values():
		var config_val = get(assist_mode_id_to_var_name_map[id])
		var curr_val = _current_assist_mode_id_to_vals_map_at_current_game_elements[id]
		if config_val != curr_val:
			return true
	
	return false

func get_curr_val_of_assist_mode_id(arg_assist_mode_id):
	return get(assist_mode_id_to_var_name_map[arg_assist_mode_id])

func set_curr_val_of_assist_mode_id(arg_assist_mode_id, arg_val):
	var setter_method_name = assist_mode_id_to_setter_method_name_map[arg_assist_mode_id]
	call(setter_method_name, arg_val)

func get_val_changed_signal_name_of_assist_mode_id(arg_assist_mode_id):
	return assist_mode_id_to_val_changed_signal_name_map[arg_assist_mode_id]

func get_no_effect_val_of_assist_mode_id(arg_assist_mode_id):
	return get(assist_mode_id_to_no_effect_var_name_map[arg_assist_mode_id])



##

func _on_current_master_setted(arg_master):
	_connect_signals_with_master()

func _connect_signals_with_master():
	SingletonsAndConsts.current_master.connect("switching_from_game_elements__non_restart__transition_ended", self, "_on_switching_from_game_elements__non_restart__transition_ended")

func _on_switching_from_game_elements__non_restart__transition_ended():
	if assist_mode_toggle_active_mode_id == AssistMode_ToggleActiveModeId.FOR_THIS_LEVEL_ONLY:
		set_is_assist_mode_active(false)



####################

func set_settings_config__is_full_screen(arg_val):
	var old_val = settings_config__is_full_screen
	settings_config__is_full_screen = arg_val
	
	OS.window_fullscreen = arg_val
	
	if _is_manager_initialized:
		emit_signal("settings_config__is_full_screen_changed", arg_val)

#func _get_settings_config__is_full_screen__from_proj_settings():
#	return ProjectSettings.get_setting("display/window/size/fullscreen")


func set_settings_config__cam_rotation_duration(arg_val):
	var old_val = settings_config__cam_rotation_duration
	settings_config__cam_rotation_duration = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("settings_config__cam_rotation_duration_changed", arg_val)
		



func _load_settings_config_using_dic(data : Dictionary):
	if data.has(SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER):
		set_settings_config__is_full_screen(data[SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER])
	else:
		set_settings_config__is_full_screen(settings_config__is_full_screen__default) #_get_settings_config__is_full_screen__from_proj_settings())
	
	if data.has(SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER):
		set_settings_config__cam_rotation_duration(data[SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER])
	else:
		set_settings_config__cam_rotation_duration(settings_config__cam_rotation_duration__default)


#

func _get_settings_as_save_dict():
	return {
		SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER : settings_config__is_full_screen,
		SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER : settings_config__cam_rotation_duration,
		
	}


#########################################
# TILE COLORS

func _load_tile_color_config_using_dic(data : Dictionary):
	## NORMAL
	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER):
		var color = _convert_color_html_string__into_color(data[TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER])
		set_tile_color_config__tile_modulate__normal(color)
	else:
		set_tile_color_config__tile_modulate__normal(tile_color_config__tile_modulate__normal__default)
	
#	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL_PRESETS_DIC_IDENTIFIER):
#		set_tile_color_config__tile_modulate__normal_preset(data[TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL_PRESETS_DIC_IDENTIFIER])
#	else:
#		pass
	
	
	## ENERGIZED
	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER):
		var color = _convert_color_html_string__into_color(data[TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER])
		set_tile_color_config__tile_modulate__energized(color)
	else:
		set_tile_color_config__tile_modulate__energized(tile_color_config__tile_modulate__energized__default)
	
#	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED_PRESETS_DIC_IDENTIFIER):
#		set_tile_color_config__tile_modulate__energized_preset(data[TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED_PRESETS_DIC_IDENTIFIER])
#	else:
#		pass
	
	
	## GROUNDED
	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER):
		var color = _convert_color_html_string__into_color(data[TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER])
		set_tile_color_config__tile_modulate__grounded(color)
	else:
		set_tile_color_config__tile_modulate__grounded(tile_color_config__tile_modulate__grounded__default)
	
#	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED_PRESETS_DIC_IDENTIFIER):
#		set_tile_color_config__tile_modulate__grounded_preset(data[TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED_PRESETS_DIC_IDENTIFIER])
#	else:
#		pass
	
#	if data.has(TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER):
#		var colors = _convert_color_html_string_arr__into_color_arr(data[TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER])
#		set_tile_color_config__tile_modulate__for_all_types_preset(colors)
#	else:
#		pass

#

func _convert_color_html_string__into_color(arg_color_string : String):
	return Color(arg_color_string)
	

func _convert_color_html_string_arr__into_color_arr(arg_arr):
	var bucket = []
	for color_html_string in arg_arr:
		bucket.append(Color(color_html_string))
	
	return bucket


#

func set_tile_color_config__tile_modulate__normal(arg_color : Color):
	var old_val = tile_color_config__tile_modulate__normal
	tile_color_config__tile_modulate__normal = arg_color
	
	if old_val != arg_color:
		if _is_manager_initialized:
			emit_signal("tile_color_config__tile_modulate__normal_changed", arg_color)
			emit_signal("tile_color_config__tile_modulate__x_changed", BaseTileSet.EnergyMode.NORMAL, arg_color)

#func set_tile_color_config__tile_modulate__normal_preset(arg_presets : Array):
#	tile_color_config__tile_modulate__normal_presets = arg_presets
#
#	emit_signal("tile_color_config__tile_presets__for_all_types_changed", arg_presets)


func set_tile_color_config__tile_modulate__energized(arg_color : Color):
	var old_val = tile_color_config__tile_modulate__energized
	tile_color_config__tile_modulate__energized = arg_color
	
	if old_val != arg_color:
		if _is_manager_initialized:
			emit_signal("tile_color_config__tile_modulate__energized_changed", arg_color)
			emit_signal("tile_color_config__tile_modulate__x_changed", BaseTileSet.EnergyMode.ENERGIZED, arg_color)

#func set_tile_color_config__tile_modulate__energized_preset(arg_presets : Array):
#	tile_color_config__tile_modulate__energized_presets = arg_presets
#
#	emit_signal("tile_color_config__tile_presets__for_all_types_changed", arg_presets)


func set_tile_color_config__tile_modulate__grounded(arg_color : Color):
	var old_val = tile_color_config__tile_modulate__grounded
	tile_color_config__tile_modulate__grounded = arg_color
	
	if old_val != arg_color:
		if _is_manager_initialized:
			emit_signal("tile_color_config__tile_modulate__grounded_changed", arg_color)
			emit_signal("tile_color_config__tile_modulate__x_changed", BaseTileSet.EnergyMode.INSTANT_GROUND, arg_color)

#func set_tile_color_config__tile_modulate__grounded_preset(arg_presets : Array):
#	tile_color_config__tile_modulate__grounded_presets = arg_presets
#
#	emit_signal("tile_color_config__tile_presets__for_all_types_changed", arg_presets)

#func set_tile_color_config__tile_modulate__for_all_types_preset(arg_presets : Array):
#	if tile_color_config__tile_modulate__for_all_types_presets != arg_presets:
#		tile_color_config__tile_modulate__for_all_types_presets = arg_presets
#
#		#print("presets: %s" % [tile_color_config__tile_modulate__for_all_types_presets])
#
#		emit_signal("tile_color_config__tile_presets__for_all_types_changed", arg_presets)


func _get_tile_color_config_as_save_dict():
	return {
		TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER : tile_color_config__tile_modulate__normal.to_html(true),
		TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER : tile_color_config__tile_modulate__energized.to_html(true),
		TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER : tile_color_config__tile_modulate__grounded.to_html(true),
		
		#TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER : _convert_color_arr_to_color_html_string_arr(tile_color_config__tile_modulate__for_all_types_presets),
	}

func _convert_color_arr_to_color_html_string_arr(arg_arr : Array):
	var bucket = []
	for color in arg_arr:
		bucket.append(color.to_html(true))
		
	
	return bucket


####################################
## PLAYER AESTH

func player_aesth__get_texture_of_body_texture_id(arg_id):
	if arg_id == PlayerAesthConfig_BodyTextureId.NORMAL:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody.png")
		#return preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_MainBody.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__AUSTRALIA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Australia.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__BRAZIL:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Brazil.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__CANADA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Canada.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__CHINA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_China.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__FRANCE:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_France.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__GERMANY:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Germany.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__INDIA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_India.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__ITALY:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Italy.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__JAPAN:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Japan.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__NETHERLANDS:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Netherlands.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__PHILIPPINES:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Philippines.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__RUSSIA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Russia.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__SPAIN:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_Spain.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__UK:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_UK.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__USA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_USA.png")
	elif arg_id == PlayerAesthConfig_BodyTextureId.FLAG__SOUTH_KOREA:
		return load("res://PlayerRelated/PlayerModel/PlayerMainBody/PlayerModel_MainBody__Flag_SKorea.png")
	
	return null

func player_aesth__get_texture_of_face_screen_texture_id(arg_id):
	if arg_id == PlayerAesthConfig_FaceScreenTextureId.NORMAL:
		return load("res://PlayerRelated/PlayerModel/PlayerFace/FaceScreenAssets/PlayerFaceScreen_Normal.png")
		#return preload("res://PlayerRelated/PlayerModel/Assets/PlayerModel_MainBody.png")
	
	return null



func _load_player_aesth_config_using_dic(data : Dictionary):
	## BODY
	if data.has(PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID_TO_SAVED_MODULATE_MAP__DIC_IDENTIFIER):
		player_aesth_config__body_texture_id_to_saved_modulate_map = _convert_color_html_string_dict_to_color_dict(data[PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID_TO_SAVED_MODULATE_MAP__DIC_IDENTIFIER])
	else:
		player_aesth_config__body_texture_id_to_saved_modulate_map = _player_aesth_config__body_texture_id_to_saved_modulate_map__default.duplicate(true)
	_fill_missing_player_aesth_config__body_texture_id_to_saved_modulate_map()
	
	if data.has(PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID__DIC_IDENTIFIER):
		var id_as_str = data[PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID__DIC_IDENTIFIER]
		set_player_aesth_config__body_texture_id(int(id_as_str))
	else:
		set_player_aesth_config__body_texture_id(player_aesth_config__body_texture_id__default)
	
	
	## FACE SCREEN
	if data.has(PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_SCREEN_MODULATE_MAP__DIC_IDENTIFIER):
		player_aesth_config__BTId_to_saved_face_screen_modulate_map = _convert_color_html_string_dict_to_color_dict(data[PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_SCREEN_MODULATE_MAP__DIC_IDENTIFIER])
	else:
		player_aesth_config__BTId_to_saved_face_screen_modulate_map = _player_aesth_config__BTId_to_saved_face_screen_modulate_map__default.duplicate(true)
	_fill_missing_player_aesth_config__BTId_to_saved_face_screen_modulate_map()
	
	if data.has(PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_ID__DIC_IDENTIFIER):
		var id_as_str = data[PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_ID__DIC_IDENTIFIER]
		set_player_aesth_config__face_screen_texture_id(int(id_as_str))
	else:
		set_player_aesth_config__face_screen_texture_id(player_aesth_config__face_screen_texture_id__default)
	
	
	## FACE EXPRESSION
	if data.has(PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_EXPRESSION_MODULATE_MAP__DIC_IDENTIFIER):
		player_aesth_config__BTId_to_saved_face_expression_modulate_map = _convert_color_html_string_dict_to_color_dict(data[PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_EXPRESSION_MODULATE_MAP__DIC_IDENTIFIER])
	else:
		player_aesth_config__BTId_to_saved_face_expression_modulate_map = _player_aesth_config__BTId_to_saved_face_expression_modulate_map__default.duplicate(true)
	_fill_missing_player_aesth_config__BTId_to_saved_face_expression_modulate_map()
	


func set_player_aesth_config__body_texture_id(arg_id):
	var old_val = player_aesth_config__body_texture_id
	player_aesth_config__body_texture_id = arg_id
	
	if old_val != arg_id:
		if _is_manager_initialized:
			emit_signal("player_aesth_config__body_texture_id__changed", arg_id)

func set_player_aesth_config__modulate_for_body_texture_id(arg_modulate, arg_id):
	player_aesth_config__body_texture_id_to_saved_modulate_map[arg_id] = arg_modulate
	
	if _is_manager_initialized:
		emit_signal("player_aesth_config__saved_modulate_for_body_texture_id__changed", arg_modulate, arg_id)

func _fill_missing_player_aesth_config__body_texture_id_to_saved_modulate_map():
	for id in PlayerAesthConfig_BodyTextureId.values():
		if !player_aesth_config__body_texture_id_to_saved_modulate_map.has(id):
			var default_val = get_player_aesth_config__body_texture_id_to_saved_modulate_map__default(id)
			
			player_aesth_config__body_texture_id_to_saved_modulate_map[id] = default_val

func get_player_aesth_config__body_texture_id_to_saved_modulate_map__default(id):
	var default_val = player_aesth_config__body_texture_id_to_saved_modulate_for_map__default_for_empty_field#Color("#ffffff")
	if _player_aesth_config__body_texture_id_to_saved_modulate_map__default.has(id):
		default_val = _player_aesth_config__body_texture_id_to_saved_modulate_map__default[id]
	
	return default_val

#

func set_player_aesth_config__face_screen_texture_id(arg_id):
	var old_val = player_aesth_config__face_screen_texture_id
	player_aesth_config__face_screen_texture_id = arg_id
	
	if old_val != arg_id:
		if _is_manager_initialized:
			emit_signal("player_aesth_config__face_screen_texture_id__changed", arg_id)


##

func set_player_aesth_config__modulate_for_BTId_saved_face_screen(arg_modulate, arg_id):
	player_aesth_config__BTId_to_saved_face_screen_modulate_map[arg_id] = arg_modulate
	
	if _is_manager_initialized:
		emit_signal("player_aesth_config__BTId_to_saved_modulate_for_face_screen_texture_id__changed", arg_modulate, arg_id)

func _fill_missing_player_aesth_config__BTId_to_saved_face_screen_modulate_map():
	for id in PlayerAesthConfig_BodyTextureId.values():
		if !player_aesth_config__BTId_to_saved_face_screen_modulate_map.has(id):
			var default_val = get_player_aesth_config__BTId_to_saved_face_screen_modulate_map__default(id)
			
			player_aesth_config__BTId_to_saved_face_screen_modulate_map[id] = default_val

func get_player_aesth_config__BTId_to_saved_face_screen_modulate_map__default(id):
	var default_val = player_aesth_config__BTId_to_saved_face_screen_modulate_map__default_for_empty_field
	if _player_aesth_config__BTId_to_saved_face_screen_modulate_map__default.has(id):
		default_val = _player_aesth_config__BTId_to_saved_face_screen_modulate_map__default[id]
	
	return default_val

#

func set_player_aesth_config__modulate_for_BTId_saved_face_expression(arg_modulate, arg_id):
	player_aesth_config__BTId_to_saved_face_expression_modulate_map[arg_id] = arg_modulate
	
	if _is_manager_initialized:
		emit_signal("player_aesth_config__BTId_to_saved_modulate_for_face_expression_texture_id__changed", arg_modulate, arg_id)


func _fill_missing_player_aesth_config__BTId_to_saved_face_expression_modulate_map():
	for id in PlayerAesthConfig_BodyTextureId.values():
		if !player_aesth_config__BTId_to_saved_face_expression_modulate_map.has(id):
			var default_val = get_player_aesth_config__BTId_to_saved_face_expression_modulate_map__default(id)
			
			player_aesth_config__BTId_to_saved_face_expression_modulate_map[id] = default_val

func get_player_aesth_config__BTId_to_saved_face_expression_modulate_map__default(id):
	var default_val = player_aesth_config__BTId_to_saved_face_expression_modulate_map__default_for_empty_field
	if _player_aesth_config__BTId_to_saved_face_expression_modulate_map__default.has(id):
		default_val = _player_aesth_config__BTId_to_saved_face_expression_modulate_map__default[id]
	
	return default_val

#

func _get_player_aesth_config_as_save_dict():
	return {
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID_TO_SAVED_MODULATE_MAP__DIC_IDENTIFIER : _convert_color_dict_to_color_html_string_dict(player_aesth_config__body_texture_id_to_saved_modulate_map),
		PLAYER_AESTH_CONFIG__BODY_TEXTURE_ID__DIC_IDENTIFIER : player_aesth_config__body_texture_id,
		
		PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_SCREEN_MODULATE_MAP__DIC_IDENTIFIER : _convert_color_dict_to_color_html_string_dict(player_aesth_config__BTId_to_saved_face_screen_modulate_map),
		PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_ID__DIC_IDENTIFIER : player_aesth_config__face_screen_texture_id,
		
		PLAYER_AESTH_CONFIG__BTId_TO_SAVED_FACE_EXPRESSION_MODULATE_MAP__DIC_IDENTIFIER : _convert_color_dict_to_color_html_string_dict(player_aesth_config__BTId_to_saved_face_expression_modulate_map),
		
	}



func _convert_color_html_string_dict_to_color_dict(arg_dict : Dictionary):
	var bucket = {}
	for id_as_str in arg_dict.keys():
		var id = int(id_as_str)
		bucket[id] = _convert_color_html_string__into_color(arg_dict[id_as_str])
	
	return bucket

func _convert_color_dict_to_color_html_string_dict(arg_dict : Dictionary):
	var bucket = {}
	for id in arg_dict.keys():
		bucket[id] = arg_dict[id].to_html(true)
	
	return bucket



