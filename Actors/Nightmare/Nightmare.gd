extends "res://Actors/Actor.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : KinematicBody2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = get_node("Anim")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindPlayer() -> void:
	if _player == null:
		var plist = get_tree().get_nodes_in_group("Player")
		for p in plist:
			if p is KinematicBody2D:
				_player = p
				break

func _UpdateViz() -> void:
	_FindPlayer()
	if _player != null:
		var dir : Vector2 = global_position.direction_to(_player.global_position)
		var anim = "idle" + ("_right" if dir.x >= 0.0 else "_left")
		if dir.y < 0.0:
			anim += "_away"
		if anim_node.assigned_animation != anim:
			anim_node.play(anim)

func _Fade(anim_name : String) -> void:
	pass


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


