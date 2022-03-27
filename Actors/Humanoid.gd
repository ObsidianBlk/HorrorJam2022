extends "res://Actors/Actor.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _sprite_nodes : Array = []

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = $Anim

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	for child in viz_node.get_children():
		if child is Sprite and child.is_in_group("Flippable"):
			_sprite_nodes.append(child)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateViz() -> void:	
	if _direction.length() > 0:
		var walk_anim = "walk" if _facing.y >= 0 else "walk_away"
		anim_node.play("run" if _running else walk_anim)
		if _facing.x < 0.0:
			for sprite_node in _sprite_nodes:
				sprite_node.flip_h = true
		elif _facing.x > 0.0:
			for sprite_node in _sprite_nodes:
				sprite_node.flip_h = false
	elif _velocity.length() < 0.01:
		if anim_node.assigned_animation.substr(0, 4) != "rest":
			anim_node.play("rest" if _facing.y >= 0 else "rest_away")

func _Fade(anim_name : String) -> void:
	_velocity = Vector2.ZERO
	_direction = Vector2.ZERO
	$AnimFade.play(anim_name)
	set_physics_process(false)
	yield($AnimFade, "animation_finished")
	set_physics_process(true)
	emit_signal("faded")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

