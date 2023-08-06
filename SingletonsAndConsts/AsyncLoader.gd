extends Node

#

const TIME_MAX = 0.1

#

class LoaderQueue:
	
	const GameElements_Scene_Path = "res://GameElements/GameElements.tscn"
	
	#
	
	# expects 3 params: the loaded obj, params, and the loader queue
	var func_source__on_load : Object
	var func_name__on_load : String
	var func_params__on_load
	
	var load_path : String
	
	#
	
	func _call_func_source_and_name__with_loaded(arg_loaded):
		func_source__on_load.call(func_name__on_load, arg_loaded, func_params__on_load, self)
	


#

var _loader_queues : Array = []
var _is_loading : bool
var _current_loader_queue : LoaderQueue

var loader

##

func _ready():
	set_process(false)

#

func queue_load(arg_loader_queue : LoaderQueue):
	_loader_queues.append(arg_loader_queue)
	_attempt_start_queue()

func _attempt_start_queue():
	if !_is_loading and _loader_queues.size() != 0:
		var loader_queue : LoaderQueue = _loader_queues[0]
		
		loader = ResourceLoader.load_interactive(loader_queue.load_path)
		if loader == null:
			print("AsyncLoader -- error at load interactive")
		else:
			_is_loading = true
			_current_loader_queue = _loader_queues.pop_front()
			set_process(true)
	


func _process(delta):
	if loader == null:
		_is_loading = false
		_current_loader_queue = null
		set_process(false)
		
		#_attempt_start_queue()
		call("_attempt_start_queue")
	
	var t = OS.get_ticks_msec()
	while (OS.get_ticks_msec < t + TIME_MAX):
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			_current_loader_queue._call_func_source_and_name__with_loaded(resource)
			
			#set_new_scene(resource)
			break
		elif err == OK:
			#update_progress()
			pass
			
		else: # Error during loading.
			print("AsyncLoader - Error during load")
			loader = null
			break

