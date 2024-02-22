extends Reference

enum CutsceneId {
	
	LSpecial01_Lvl01 = 0,
	LSpecial01_Lvl02 = 1,
	LSpecial01_Lvl03 = 2,
	LSpecial01_Lvl04 = 3,
	
	MOD_X_INFO__STATS = 100,
	MOD_X_INFO__TILE_COLORS = 101,
	MOD_X_INFO__PLAYER_AESTH = 102,
	MOD_X_INFO__CUSTOM_AUDIO = 103,
	
}


static func generate_cutscene_from_id(arg_id):
	
	var scene_pack
	match arg_id:
		CutsceneId.LSpecial01_Lvl01:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl01/LSpecial01_Cutscene_Lvl01.tscn")
		CutsceneId.LSpecial01_Lvl02:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl02/LSpecial01_Cutscene_Lvl02.tscn")
		CutsceneId.LSpecial01_Lvl03:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl03/LSpecial01_Cutscene_Lvl03.tscn")
		CutsceneId.LSpecial01_Lvl04:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl04/LSpecial01_Cutscene_Lvl04.tscn")
			
		CutsceneId.MOD_X_INFO__STATS:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/ModX/ModX_Cutscene_Stats.tscn")
		CutsceneId.MOD_X_INFO__PLAYER_AESTH:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/ModX/ModX_Cutscene_PlayerAesth.tscn")
		CutsceneId.MOD_X_INFO__TILE_COLORS:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/ModX/ModX_Cutscene_TileColors.tscn")
		CutsceneId.MOD_X_INFO__CUSTOM_AUDIO:
			scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/ModX/ModX_Cutscene_CustomAudio.tscn")
		
	
	return scene_pack.instance()



