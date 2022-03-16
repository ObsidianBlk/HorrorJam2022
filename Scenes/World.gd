extends Node2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const INITIAL_ZONE : String = "res://Scenes/Demo_Level.tscn"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player_actor : Node2D = null
var _camera : Camera2D = null

var _input_dir = [0,0,0,0]

var _zone_ready : bool = false
var _zone : Node2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var viewport_node : Viewport = get_node("Viewport")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_LoadZone(INITIAL_ZONE)
#	var pnodes = get_tree().get_nodes_in_group("Player")
#	if pnodes.size() > 0:
#		for p in pnodes:
#			if p.has_method("move"):
#				_player_actor = p
#				_player_actor.connect("collision", self, "on_player_collision")
#				break
#
#	var cnodes = get_tree().get_nodes_in_group("ShakeCamera")
#	if cnodes.size() > 0:
#		for c in cnodes:
#			if c.has_method("add_trauma"):
#				_camera = c
#				break

func _unhandled_input(event) -> void:
	if _player_actor == null or not _zone_ready:
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
			_player_actor.set_running(true)
		elif event.is_action_released("run_toggle"):
			_player_actor.set_running(false)
		
		if event.is_action_pressed("interact"):
			_player_actor.interact()
		
		if event.is_action_pressed("test_key") and _camera != null:
			_camera.add_trauma(0.5)
		
		_player_actor.move(
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
func _LoadZone(scene_path : String, start_door : String = "") -> void:
	var zone_inst = load(scene_path)
	if zone_inst:
		if _zone != null:
			_player_actor = null
			_zone.disconnect("request_zone_change", self, "_LoadZone")
			viewport_node.remove_child(_zone)
			_zone.queue_free()
			_zone = null
		
		_zone_ready = false
		_zone = zone_inst.instance()
		if _zone:
			_zone.connect("request_zone_change", self, "_LoadZone")
			viewport_node.add_child(_zone)
			call_deferred("_StartZone", start_door)
	else:
		printerr("ERROR: Failed to find zone '", scene_path, "'!!")

func _StartZone(start_door : String = "") -> void:
	if _zone and not _zone_ready:
		_camera = _zone.get_camera()
		_player_actor = _zone.get_player()
		if _player_actor:
			_zone.start(start_door)
			_zone_ready = true

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_player_collision() -> void:
	if _input_dir[2] != 0:
		_player_actor.trigger()
