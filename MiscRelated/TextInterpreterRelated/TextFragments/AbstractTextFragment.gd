extends Reference


enum DESCRIPTION_TYPE {
	
	MOVING = 0,
	MOVING_LEFT = 1,
	MOVING_RIGHT = 2,
	SPEED = 3,
	ROTATING = 4,
	
	
	ENERGY = 100,
	LAUNCH_BALL = 101,
	
	NORMAL_TILES = 200,
	BREAKABLE_TILES = 201,
	ENERGIZED_TILES = 202,
	INSTANT_GROUNDED_TILES = 203,
	
	
	BUTTON = 300,
	CAPTURE_AREA = 301,
	LAUNCH_BALL_AMMO__INFINITE = 302,
	
}

# dark colored text
const type_to_for_light_color_map : Dictionary = {
	-1 : "#4F4F4F",
	
	DESCRIPTION_TYPE.MOVING: "#0B5101",
	DESCRIPTION_TYPE.MOVING_LEFT: "#0B5101",
	DESCRIPTION_TYPE.MOVING_RIGHT: "#0B5101",
	DESCRIPTION_TYPE.SPEED: "#0B5101",
	DESCRIPTION_TYPE.ROTATING: "#36016D",
	
	DESCRIPTION_TYPE.ENERGY: "#A67100",
	DESCRIPTION_TYPE.LAUNCH_BALL: "#AA4000",
	
	DESCRIPTION_TYPE.NORMAL_TILES : "#4F4F4F",
	DESCRIPTION_TYPE.BREAKABLE_TILES: "#507997",
	DESCRIPTION_TYPE.ENERGIZED_TILES: "#A67100",
	DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES: "#9C2400",
	
	DESCRIPTION_TYPE.BUTTON : "#0E016D",
	DESCRIPTION_TYPE.CAPTURE_AREA : "#284F01",
	DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE : "#5C2E00",
	
}

# light colored text
const type_to_for_dark_color_map : Dictionary = {
	-1 : "#B8B8B8",
	
	DESCRIPTION_TYPE.MOVING: "#3FFC24",
	DESCRIPTION_TYPE.MOVING_LEFT: "#3FFC24",
	DESCRIPTION_TYPE.MOVING_RIGHT: "#3FFC24",
	DESCRIPTION_TYPE.SPEED: "#3FFC24",
	DESCRIPTION_TYPE.ROTATING: "#B45EFE",
	
	DESCRIPTION_TYPE.ENERGY: "#EAB513",
	DESCRIPTION_TYPE.LAUNCH_BALL: "#FFA222",
	
	DESCRIPTION_TYPE.NORMAL_TILES : "#B8B8B8",
	DESCRIPTION_TYPE.BREAKABLE_TILES: "#93BCCB",
	DESCRIPTION_TYPE.ENERGIZED_TILES: "#EAB513",
	DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES: "#CE6624",
	
	DESCRIPTION_TYPE.BUTTON : "#BBB3FF",
	DESCRIPTION_TYPE.CAPTURE_AREA : "#7BFD68",
	DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE : "#FFC285",
	
}


const type_to_name_map : Dictionary = {
	
	DESCRIPTION_TYPE.MOVING: "moving",
	DESCRIPTION_TYPE.MOVING_LEFT: "moving left",
	DESCRIPTION_TYPE.MOVING_RIGHT: "moving right",
	DESCRIPTION_TYPE.SPEED: "speed",
	DESCRIPTION_TYPE.ROTATING: "rotating",
	
	DESCRIPTION_TYPE.ENERGY: "Energy",
	DESCRIPTION_TYPE.LAUNCH_BALL: "Launch Ball",
	
	DESCRIPTION_TYPE.NORMAL_TILES: "Normal Tiles",
	DESCRIPTION_TYPE.BREAKABLE_TILES: "Breakable Tiles",
	DESCRIPTION_TYPE.ENERGIZED_TILES: "Energized Tiles",
	DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES: "Grounded Tiles",
	
	DESCRIPTION_TYPE.BUTTON : "Button",
	DESCRIPTION_TYPE.CAPTURE_AREA : "Capture Area",
	DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE : "Launch Ball Ammo",
	
}

const type_to_img_map__for_dark : Dictionary = {
	
	DESCRIPTION_TYPE.SPEED : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Speed_Right_ForDark.png",
	
	DESCRIPTION_TYPE.LAUNCH_BALL : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_LaunchBall.png",
	
	DESCRIPTION_TYPE.NORMAL_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_NormalTiles_ForDark.png",
	DESCRIPTION_TYPE.BREAKABLE_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_BreakableTiles_ForDark.png",
	DESCRIPTION_TYPE.ENERGIZED_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_EnergizedTiles_ForDark.png",
	DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_GroundTiles_ForDark.png",
	
	DESCRIPTION_TYPE.BUTTON : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Button_ForDark.png",
	DESCRIPTION_TYPE.CAPTURE_AREA : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_CapturePoint_ForDark.png",
	DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_LaunchBallAmmo_Inf_ForDark.png",
	
}

const type_to_img_map__for_light : Dictionary  = {
	
	DESCRIPTION_TYPE.SPEED : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Speed_Right_ForLight.png",
	
	DESCRIPTION_TYPE.LAUNCH_BALL : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_LaunchBall.png",
	
	DESCRIPTION_TYPE.NORMAL_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_NormalTiles_ForLight.png",
	DESCRIPTION_TYPE.BREAKABLE_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_BreakableTiles_ForLight.png",
	DESCRIPTION_TYPE.ENERGIZED_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_EnergizedTiles_ForLight.png",
	DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_GroundTiles_ForLight.png",
	
	DESCRIPTION_TYPE.BUTTON : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Button_ForLight.png",
	DESCRIPTION_TYPE.CAPTURE_AREA : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_CapturePoint_ForLight.png",
	DESCRIPTION_TYPE.LAUNCH_BALL_AMMO__INFINITE : "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_LaunchBallAmmo_Inf_ForLight.png",
	
	
}


#

enum ColorMode {
	FOR_LIGHT_BACKGROUND = 0,
	FOR_DARK_BACKGROUND = 1
}

#



const width_img_val_placeholder : String = "|imgWidth|"




var has_numerical_value : bool
var color_mode : int = ColorMode.FOR_LIGHT_BACKGROUND

#

func _init(arg_has_numerical_value : bool):
	has_numerical_value = arg_has_numerical_value


func _get_as_numerical_value() -> float:
	return 0.0

func _get_as_text() -> String:
	return "";

#

func _get_blank_color_to_use():
	if color_mode == ColorMode.FOR_DARK_BACKGROUND:
		return "#DDDDDD"
	else:
		return "#222222"

func _get_type_color_map_to_use(arg_stat_type) -> Dictionary:
	if color_mode == ColorMode.FOR_DARK_BACKGROUND:
		return type_to_for_dark_color_map[arg_stat_type]
	else:
		return type_to_for_light_color_map[arg_stat_type]
	


func _get_img_path_for_type(arg_type) -> String:
	if color_mode == ColorMode.FOR_DARK_BACKGROUND:
		if type_to_img_map__for_dark.has(arg_type):
			return type_to_img_map__for_dark[arg_type]
		else:
			return "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Placeholder.png"
		
	else:
		if type_to_img_map__for_light.has(arg_type):
			return type_to_img_map__for_light[arg_type]
		else:
			return "res://MiscRelated/TextInterpreterRelated/IconAssets/Icon_Placeholder.png"
		

#

func _configure_copy_to_match_self(arg_copy):
	arg_copy.has_numerical_value = has_numerical_value
	arg_copy.color_mode = color_mode


