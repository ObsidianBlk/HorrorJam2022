extends Node

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _nightmare_node : KinematicBody2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	pass

func _process(_delta : float) -> void:
	_FindNightmare()
	if _nightmare_node != null:
		var db = System.get_db("game_state")
		var lastpos = db.get_value("ai.nightmare.position")
		var nppos = _nightmare_node.global_position
		var player = _GetPlayer()
		if player:
			var dist = nppos.distance_to(player.global_position)
			if dist > 24 and dist < 200:
				var direction : Vector2 = nppos.direction_to(player.global_position)
				_nightmare_node.move(direction.normalized())
			else:
				_nightmare_node.move(Vector2.ZERO)
		if db and (lastpos == null or lastpos != _nightmare_node.global_position):
			db.set_value("ai.nightmare.position", _nightmare_node.global_position)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindNightmare() -> void:
	if _nightmare_node == null:
		var nmlist = get_tree().get_nodes_in_group("Nightmare")
		for nm in nmlist:
			if nm is KinematicBody2D:
				_nightmare_node = nm
				var db = System.get_db("game_state")
				if db and db.has_value("ai.nightmare.position"):
					_nightmare_node.global_position = db.get_value("ai.nightmare.position", _nightmare_node.global_position)
				else:
					print("Nightmare - No DATABASE")
				break
	elif not is_instance_valid(_nightmare_node):
		_nightmare_node = null

func _GetPlayer() -> KinematicBody2D:
	var plist = get_tree().get_nodes_in_group("Player")
	for p in plist:
		if p is KinematicBody2D:
			return p
	return null

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

