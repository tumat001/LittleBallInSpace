extends Reference

const GSM = preload("res://GameSaveRelated/GameSettingsManager.gd")
const GSM_CAIds = GSM.CustomAudioIds


const CategoryImage_Player = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Player.png")
const CategoryImage_PlayerTileColl = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_PlayerTileColl.png")
const CategoryImage_Ball = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Ball.png")
const CategoryImage_BallTileColl = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_BallTileColl.png")
const CategoryImage_Tiles = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Tiles.png")
const CategoryImage_Enemy = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_CategoryImage_Enemy.png")

#

const TypeImage_GlassTile = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_GlassTile.png")
const TypeImage_MetalTile = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_MetalTile.png")
const TypeImage_ToggleableTile = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_ToggleableTile.png")

const TypeImage_GlassTilebreak = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_GlassTileBreak.png")
const TypeImage_PlayerRotate = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_PlayerRotate.png")
const TypeImage_CaptureArea = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_CaptureArea.png")

const TypeImage_EnemyDamaged = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_EnemyDamaged.png")
const TypeImage_EnemyDestroyed = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_TypeImage_EnemyDestroyed.png")

########
const CAIdDETAILS__DIC_KEY__CATEGORY_ID = "CategoryId"
enum CAId_CategoryId {
	PLAYER = 0,
	PLAYER_TO_TILES = 1,
	
	BALL = 10,
	BALL_TO_TILES = 11,
	
	TILES = 20,
	
	ENEMY = 30,
}

const CAIdDETAILS__DIC_KEY__DESCRIPTIONS = "Descriptions"
const CAIdDETAILS__DIC_KEY__FOLDER_NAME = "FolderName"

const CAIdDETAILS__DIC_KEY__DET_IMAGE = "Image"

#

const CAIdCATEGORY__DETAILS_KEY__IMAGE = "CatImage"
const CAIdCATEGORY__DETAILS_KEY__TEXT = "CatText"


#########

const custom_audio_id_to_desc_details_map_map : Dictionary = {
	GSM_CAIds.PLAYER__COMMON_METAL__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Metallic tile hit sound with player."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_METAL__NORMAL_HIT,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_MetalTile,
		
	},
	GSM_CAIds.PLAYER__COMMON_METAL__LOUD_BANG_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Metallic tile fast hit sound with player."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_METAL__LOUD_HIT,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_MetalTile,
		
	},
	GSM_CAIds.PLAYER__TOGGLEABLE_METAL__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Toggleable tile hit sound with player."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__TOGGLEABLE_METAL__NORMAL_HIT,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_ToggleableTile,
		
	},
	GSM_CAIds.PLAYER__COMMON_GLASS__NORMAL_HIT : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER_TO_TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Glass tile hit sound with player."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_GLASS__NORMAL_HIT,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_GlassTile,
		
	},
	
	
	GSM_CAIds.PLAYER__COMMON_GLASS__BREAK : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.TILES,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Glass break sound."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__COMMON_GLASS__BREAK,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_GlassTilebreak,
		
	},
	GSM_CAIds.PLAYER__ROTATE : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Rotate sound."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__ROTATE,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_PlayerRotate,
		
	},
	GSM_CAIds.PLAYER__CAPTURE_AREA__CAPTURED : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.PLAYER,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Area captured sound."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__PLAYER__CAPTURE_AREA__CAPTURED,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_CaptureArea,
		
	},
	
	
	GSM_CAIds.ENEMY__COMBAT__TAKE_DAMAGE : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.ENEMY,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Enemy take damage sound."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__ENEMY__COMBAT__TAKE_DAMAGE,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_EnemyDamaged,
		
	},
	GSM_CAIds.ENEMY__COMBAT__DESTROYED : {
		CAIdDETAILS__DIC_KEY__CATEGORY_ID : CAId_CategoryId.ENEMY,
		CAIdDETAILS__DIC_KEY__DESCRIPTIONS : [
			"Enemy destroyed sound."
		],
		CAIdDETAILS__DIC_KEY__FOLDER_NAME : GSM.CUSTOM_AUDIO_CONFIG__DIR_NAME__ENEMY__COMBAT__DESTROYED,
		CAIdDETAILS__DIC_KEY__DET_IMAGE : TypeImage_EnemyDestroyed,
		
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
			_set_category_label_text__of_map(map, "Player\nTile Collisions")
			
		CAId_CategoryId.BALL:
			_set_category_image__of_map(map, CategoryImage_Ball)
			_set_category_label_text__of_map(map, "Ball")
			
		CAId_CategoryId.BALL_TO_TILES:
			_set_category_image__of_map(map, CategoryImage_BallTileColl)
			_set_category_label_text__of_map(map, "Ball\nTile Collisions")
			
		CAId_CategoryId.TILES:
			_set_category_image__of_map(map, CategoryImage_Tiles)
			_set_category_label_text__of_map(map, "Tiles")
			
		CAId_CategoryId.ENEMY:
			_set_category_image__of_map(map, CategoryImage_Enemy)
			_set_category_label_text__of_map(map, "Enemy")
			
	
	return map


static func _set_category_image__of_map(arg_map : Dictionary, arg_texture : Texture):
	arg_map[CAIdCATEGORY__DETAILS_KEY__IMAGE] = arg_texture

static func _set_category_label_text__of_map(arg_map : Dictionary, arg_label_text : String):
	arg_map[CAIdCATEGORY__DETAILS_KEY__TEXT] = arg_label_text



