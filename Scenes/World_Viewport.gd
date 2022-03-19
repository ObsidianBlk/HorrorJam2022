extends Viewport

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : Node2D = null
var _camera : Camera2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_FindPlayer()
	_FindCamera()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindPlayer() -> void:
	var pnodes = get_tree().get_nodes_in_group("Player")
	if pnodes.size() > 0:
		if pnodes.size() > 1:
			print("WARNING: Multiple 'Player' nodes found.")
		if self.is_a_parent_of(pnodes[0]):
			_player = pnodes[0]
	else:
		printerr("WARNING: No 'Player' nodes found.")

func _FindCamera() -> void:
	var cnodes = get_tree().get_nodes_in_group("ShakeCamera")
	if cnodes.size() > 0:
		var camera = null
		for cam in cnodes:
			if cam.current and self.is_a_parent_of(cam):
				camera = cam
				break
		if camera == null:
			for cam in cnodes:
				if self.is_a_parent_of(cam):
					camera = cam
					camera.current = true
					break
		if camera != null:
			_camera = camera
	else:
		printerr("WARNING: No Camera nodes found.")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func has_world_nodes() -> bool:
	for child in get_children():
		if child != _player and child != _camera:
			return true
	return false

func get_player_start():
	if has_world_nodes():
		var psnodes = get_tree().get_nodes_in_group("Player_Start")
		if psnodes.size() > 0:
			for ps in psnodes:
				if self.is_a_parent_of(ps):
					return ps.global_position
	return null

func has_player_and_camera() -> bool:
	return _player != null and _camera != null

func add_player_and_camera(player : Node2D, camera : Camera2D) -> void:
	if _player == null and player.get_parent() == null:
		_player = player
		add_child(player)
	
	if _camera == null and camera.get_parent() == null:
		_camera = camera
		add_child(camera)
		if _player:
			_camera.target_node_path = _camera.get_path_to(_player)

func release_player_and_camera() -> void:
	if _player != null:
		remove_child(_player)
		_player = null
	
	if _camera != null:
		_camera.target_node_path = ""
		remove_child(_camera)
		_camera = null

func clear_children() -> void:
	for child in get_children():
		if child != _player and child != _camera:
			remove_child(child)
			child.queue_free()

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


