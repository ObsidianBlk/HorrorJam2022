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
func _UpdateViz() -> void:
	var anim = ""
	if _direction.length() > 0:
		anim = "walk_right" if _direction.x >= 0.0 else "walk_left"
		if _direction.y < 0:
			anim += "_away"
	elif _velocity.length() < 0.01:
		anim = "idle_right" if _facing.x >= 0.0 else "idle_left"
		if _facing.y < 0:
			anim += "_away"
	
	if anim != "" and anim_node.assigned_animation != anim:
		anim_node.play(anim)

func _Fade(anim_name : String) -> void:
	pass


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


