extends Node


enum PlayerModiIds {
	LAUNCH_BALL = 0
	ENERGY = 1
}



func load_modi(arg_id):
	var modi_file
	var modi
	
	if arg_id == PlayerModiIds.LAUNCH_BALL:
		modi_file = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall.gd")
	elif arg_id == PlayerModiIds.ENERGY:
		modi_file = preload("res://PlayerRelated/PlayerModi/Imps/EnergyRelated/PlayerModi_Energy.gd")
		
	
	modi = modi_file.new()
	
	return modi
