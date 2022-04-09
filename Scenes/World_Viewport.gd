extends Viewport

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var sibling_viewport_path : NodePath = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : Node2D = null
var _nightmare : Node2D = null
var _camera : Camera2D = null

var _sibling_viewport : Viewport = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / getters
# -------------------------------------------------------------------------

func set_sibling_viewport_path(vpp : NodePath) -> void:
	sibling_viewport_path = vpp
	if sibling_viewport_path == "":
		_sibling_viewport = null
	else:
		var n = get_node_or_null(sibling_viewport_path)
		if n != null and n is Viewport:
			if n.has_method("_GetCamera"):
				_sibling_viewport = n

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_FindPlayer()
	_FindNightmare()
	_FindCamera()
	set_sibling_viewport_path(sibling_viewport_path)

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

func _FindNightmare() -> void:
	var nnode = get_tree().get_nodes_in_group("Nightmare")
	if nnode.size() > 0:
		if nnode.size() > 1:
			printerr("WARNING More than one 'Nightmare' node found. Using first found.")
		_nightmare = nnode[0]
	else:
		printerr("EARNING: No 'Nightmare' nodes found!!")

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

func _FindYSort() -> YSort:
	for child in get_children():
		if child is YSort:
			return child
	return null

func _GetCamera() -> Camera2D:
	return _camera


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

func has_player() -> bool:
	return _player != null

func add_player(player : Node2D) -> void:
	if _player == null and player.get_parent() == null:
		_player = player
		var container = _FindYSort()
		if container:
			container.add_child(player)
		else:
			add_child(player)
	
	if _camera != null and _player != null:
		_camera.target_node_path = _camera.get_path_to(_player)

func resort_nightmare() -> void:
	if _nightmare != null:
		var container = _FindYSort()
		if container:
			remove_child(_nightmare)
			container.add_child(_nightmare)

func release_player() -> void:
	if _player != null:
		if _camera != null:
			_camera.target_node_path = ""
		var parent = _player.get_parent()
		if parent:
			parent.remove_child(_player)
		_player = null

func release_nightmare() -> void:
	if _nightmare != null:
		var parent = _nightmare.get_parent()
		if parent != self:
			parent.remove_child(_nightmare)
			add_child(_nightmare)

func clear_children() -> void:
	release_nightmare()
	for child in get_children():
		if child != _player and child != _camera and child != _nightmare and not child.is_in_group("keep_in_view"):
			if _player and _player.get_parent() == child:
				release_player()
			remove_child(child)
			child.queue_free()

func snap_camera_to_target() -> void:
	if _player != null and _camera != null:
		_camera.snap_to_target()

func track_sibling_camera() -> void:
	if _sibling_viewport != null and _camera != null:
		var sibling_camera : Camera2D = _sibling_viewport._GetCamera()
		if sibling_camera:
			_camera.target_node_path = _camera.get_path_to(sibling_camera)

func get_camera_path_to(n : Node) -> NodePath:
	return n.get_path_to(_camera)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


