extends Node2D

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal request_zone_change(scene_path, door_name)

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : Node2D = null
var _camera : Camera2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
func _ready() -> void:
	var pnodes = get_tree().get_nodes_in_group("Player")
	if pnodes.size() > 0:
		if pnodes.size() > 1:
			printerr("WARNING: More then one player node in loaded zone.")
		_player = pnodes[0]
		_player.hide_viz(true)
	else:
		printerr("WARNING: No player nodes found in loaded zone.")
	
	if _player != null:
		var cnodes = get_tree().get_nodes_in_group("ShakeCamera")
		if cnodes.size() > 0:
			for cnode in cnodes:
				if cnode.current:
					_camera = cnode
					break
			if _camera == null:
				printerr("WARNING: No current ShakeCamera nodes in loaded zone. Activating first detected.")
				_camera = cnodes[0]
				_camera.current = true
			_camera.target_node_path = _camera.get_path_to(_player)
		else:
			printerr("WARNING: No ShakeCamera nodes detected in loaded zone.")


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func get_player() -> Node2D:
	return _player

func get_camera() -> Camera2D:
	return _camera

func start(door_name : String = "") -> void:
	if _player == null or _camera == null:
		return
	
	var entry_door : Node2D = null
	var doors = get_tree().get_nodes_in_group("Door")
	if doors.size() > 0:
		for door in doors:
			door.connect("request_zone_change", self, "on_request_zone_change")
			if door.name == door_name:
				_player.global_position = door.global_position + Vector2(0.0, 10.0)
				entry_door = door
	
	if entry_door:
		_camera.snap_to_target()
		entry_door.open_door(true)
		yield(entry_door, "door_opened")
		_player.fade_in()
	else:
		_player.hide_viz(false)


#func get_packed_scene() -> PackedScene:
#	for child in get_children():
#		child
#	return null

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_request_zone_change(scene_path : String, door_name : String) -> void:
	emit_signal("request_zone_change", scene_path, door_name)
