extends Reference

enum CutsceneId {
	
	LSpecial01_Lvl01 = 0,
	LSpecial01_Lvl02 = 1,
	LSpecial01_Lvl03 = 2,
	
}


static func generate_cutscene_from_id(arg_id):
	
	var scene_pack
	if arg_id == CutsceneId.LSpecial01_Lvl01:
		scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl01/LSpecial01_Cutscene_Lvl01.tscn")
	elif arg_id == CutsceneId.LSpecial01_Lvl02:
		scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl02/LSpecial01_Cutscene_Lvl02.tscn")
	elif arg_id == CutsceneId.LSpecial01_Lvl03:
		scene_pack = load("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/LSpecial01/Lvl03/LSpecial01_Cutscene_Lvl03.tscn")
	
	
	return scene_pack.instance()



