extends Node


enum PlayerModiIds {
	LAUNCH_BALL = 0
}



func load_modi(arg_id):
	var modi_file
	var modi
	
	if arg_id == PlayerModiIds.LAUNCH_BALL:
		modi_file = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall.gd")
	
	
	modi = modi_file.new()
	
	return modi
