extends Node2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const INITIAL_ZONE : String = "res://Scenes/Demo_Level.tscn"

enum WORLD {Real=0, Alt=1}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : Node2D = null
var _camera : Camera2D = null

var _real_world : Node2D = null
var _alt_world : Node2D = null

var _last_world : int = WORLD.Real

var _input_dir = [0,0,0,0]

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var real_viewport_node : Viewport = get_node("Real_World_View")
onready var alt_viewport_node : Viewport = get_node("Alt_World_View")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	# NOTE: This call won't actually load a resource file as one will not automatically
	# exist. This is here just for test purposes at the moment.
	System.load_or_create_db("game_state", "user://game_state.tres")
	
	_PrepareWorld()
	
	# Kick the pig!
	_LoadZone(INITIAL_ZONE)


func _unhandled_input(event) -> void:
	if _player == null or not _player.is_inside_tree():
		return
	
	if event is InputEventKey:
		if event.is_action_pressed("move_left"):
			_input_dir[0] = -1
		elif event.is_action_released("move_left"):
			_input_dir[0] = 0
		
		if event.is_action_pressed("move_right"):
			_input_dir[1] = 1
		elif event.is_action_released("move_right"):
			_input_dir[1] = 0
		
		if event.is_action_pressed("move_up"):
			_input_dir[2] = -1
		elif event.is_action_released("move_up"):
			_input_dir[2] = 0
		
		if event.is_action_pressed("move_down"):
			_input_dir[3] = 1
		elif event.is_action_released("move_down"):
			_input_dir[3] = 0
		
		if event.is_action_pressed("run_toggle"):
			_player.set_running(true)
		elif event.is_action_released("run_toggle"):
			_player.set_running(false)
		
		if event.is_action_pressed("interact"):
			_player.interact()
		
		_player.move(
			Vector2(
				_input_dir[0] + _input_dir[1],
				_input_dir[2] + _input_dir[3]
			).normalized()
		)
	elif event is InputEventJoypadMotion:
		pass


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _PrepareWorld() -> void:
	var pnode = get_tree().get_nodes_in_group("Player")
	if pnode.size() > 0:
		if pnode.size() > 1:
			printerr("WARNING: More than one 'player' node found. Using first found.")
		_player = pnode[0]
		_player.connect("collision", self, "on_player_collision")
	else:
		printerr("WARNING: No 'Player' nodes found!!")
	
	var cnode = get_tree().get_nodes_in_group("ShakeCamera")
	if cnode.size() >0:
		for cam in cnode:
			if cam.current:
				_camera = cam
		if _camera == null:
			print("WARNING: No current camera's found. Setting first camera to current.")
			_camera = cnode[0]
			_camera.current
	else:
		printerr("WARNING: No camera found!!")


func _LoadZone(scene_path : String, start_door : String = "") -> void:
	var zone_inst = load(scene_path)
	if zone_inst:
		var zone = zone_inst.instance()
		if zone:
			_player.hide_viz(true)
			if real_viewport_node.has_player_and_camera():
				real_viewport_node.release_player_and_camera()
			else:
				alt_viewport_node.release_player_and_camera()
			real_viewport_node.clear_children()
			alt_viewport_node.clear_children()
			
			for child in zone.get_children():
				if child.name == "RealWorld":
					zone.remove_child(child)
					real_viewport_node.add_child(child)
				elif child.name == "AltWorld":
					zone.remove_child(child)
					alt_viewport_node.add_child(child)
			
			if not real_viewport_node.has_world_nodes() and not alt_viewport_node.has_world_nodes():
				real_viewport_node.add_child(zone)
			else:
				zone.queue_free()
			call_deferred("_StartZone", start_door)
	else:
		printerr("ERROR: Failed to find zone '", scene_path, "'!!")


func _StartZone(door_name : String = "") -> void:
	if not (_player and _camera):
		return
	
	var entry_door : Node2D = null
	var doors = get_tree().get_nodes_in_group("Door")
	if doors.size() > 0:
		for door in doors:
			door.connect("request_zone_change", self, "_LoadZone")
			if door.name == door_name:
				entry_door = door
	
	if entry_door:
		if real_viewport_node.is_a_parent_of(entry_door):
			real_viewport_node.add_player_and_camera(_player, _camera)
		else:
			alt_viewport_node.add_player_and_camera(_player, _camera)
			
		_player.global_position = entry_door.global_position + Vector2(0.0, 10.0)
		_camera.snap_to_target()
		entry_door.open_door(true)
		yield(entry_door, "door_opened")
		_player.fade_in()
	else:
		var viewport = real_viewport_node
		var pos = null
		if _last_world == WORLD.Real:
			pos = real_viewport_node.get_player_start()
			if pos != null:
				viewport = real_viewport_node
			else:
				pos = alt_viewport_node.get_player_start()
				if pos != null:
					viewport = alt_viewport_node
				else:
					printerr("WARNING: No viewport with valid player start!")
		elif _last_world == WORLD.Alt:
			pos = alt_viewport_node.get_player_start()
			if pos != null:
				viewport = alt_viewport_node
			else:
				pos = real_viewport_node.get_player_start()
				if pos != null:
					viewport = real_viewport_node
				else:
					printerr("WARNING: No viewport with valid player start!")
		
		viewport.add_player_and_camera(_player, _camera)
		if pos != null:
			_player.global_position = pos
			_camera.global_position = pos
		_player.hide_viz(false)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_player_collision() -> void:
	if _input_dir[2] != 0:
		_player.trigger()

