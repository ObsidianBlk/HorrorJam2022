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
		var nppos = _nightmare_node.global_position
		var player = _GetPlayer()
		if player:
			var dist = nppos.distance_to(player.global_position)
			if dist > 24 and dist < 200:
				var direction : Vector2 = nppos.direction_to(player.global_position)
				_nightmare_node.move(direction.normalized())
			else:
				_nightmare_node.move(Vector2.ZERO)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindNightmare() -> void:
	if _nightmare_node == null:
		var nmlist = get_tree().get_nodes_in_group("Nightmare")
		for nm in nmlist:
			if nm is KinematicBody2D:
				_nightmare_node = nm
				break

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

