extends Reference

const GSM = preload("res://GameSaveRelated/GameSettingsManager.gd")
const GSM_CAIds = GSM.CustomAudioIds


const CategoryImage_Player = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Player.png")
const CategoryImage_PlayerTileColl = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_PlayerTileColl.png")
const CategoryImage_Ball = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Ball.png")
const CategoryImage_BallTileColl = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_BallTileColl.png")


########
const CAIdDETAILS__DIC_KEY__CATEGORY_ID = "CategoryId"
enum CAId_CategoryId {
	PLAYER = 0,
	PLAYER_TO_TILES = 1,
	
	BALL = 10,
	BALL_TO_TILES = 11,
}

const CAIdDETAILS__DIC_KEY__DESCRIPTIONS = "Descriptions"
const CAIdDETAILS__DIC_KEY__FOLDER_NAME = "FolderName"

#

const CAIdCATEGORY__DETAILS_KEY__IMAGE = "CatImage"
const CAIdCATEGORY__DETAILS_KEY__TEXT = "CatText"


#########

const custom_audio_id_to_desc_details_map_map : Dictionary = {
	GSM_CAIds.PLAYER__COMMON_METAL__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Sound when hitting metallic tiles."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_METAL__NORMAL_HIT,
		
	},
	
	GSM_CAIds.PLAYER__COMMON_METAL__LOUD_BANG_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Sound when hitting metallic tiles while going fast."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_METAL__LOUD_HIT,
		
	},
	
	GSM_CAIds.PLAYER__TOGGLEABLE_METAL__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Sound when hitting toggleable tiles."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__TOGGLEABLE_METAL__NORMAL_HIT,
		
	},
	
	GSM_CAIds.PLAYER__COMMON_GLASS__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Sound when hitting glass tiles while."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_GLASS__NORMAL_HIT,
		
	},
	
}

########################

static func get_map_details_for_category_id(category_id):
	var map = {}
	match category_id:
		CAId_CategoryId.PLAYER:
			_set_category_image__of_map(map, CategoryImage_Player)
			_set_category_label_text__of_map(map, "Player")
			
		CAId_CategoryId.PLAYER_TO_TILES:
			_set_category_image__of_map(map, CategoryImage_PlayerTileColl)
			_set_category_label_text__of_map(map, "Player Tile Collisions")
			
		CAId_CategoryId.BALL:
			_set_category_image__of_map(map, CategoryImage_Ball)
			_set_category_label_text__of_map(map, "Ball")
			
		CAId_CategoryId.BALL_TO_TILES:
			_set_category_image__of_map(map, CategoryImage_BallTileColl)
			_set_category_label_text__of_map(map, "Ball Tile Collisions")
			
	
	return map


static func _set_category_image__of_map(arg_map : Dictionary, arg_texture : Texture):
	arg_map[CAIdCATEGORY__DETAILS_KEY__IMAGE] = arg_texture

static func _set_category_label_text__of_map(arg_map : Dictionary, arg_label_text : String):
	arg_map[CAIdCATEGORY__DETAILS_KEY__TEXT] = arg_label_text



