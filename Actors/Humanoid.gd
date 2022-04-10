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
onready var sndctrl : Node2D = $SoundCTRL

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
	elif _velocity.length() < 0.01:
		if anim_node.assigned_animation.substr(0, 4) != "rest":
			anim_node.play("rest" if _facing.y >= 0 else "rest_away")
	_UpdateXFacing()

func _UpdateXFacing() -> void:
	if _facing.x < 0.0:
		for sprite_node in _sprite_nodes:
			sprite_node.flip_h = true
	elif _facing.x > 0.0:
		for sprite_node in _sprite_nodes:
			sprite_node.flip_h = false

func _Fade(anim_name : String) -> void:
	_velocity = Vector2.ZERO
	_direction = Vector2.ZERO
	$AnimFade.play(anim_name)
	set_physics_process(false)
	yield($AnimFade, "animation_finished")
	set_physics_process(true)
	emit_signal("faded")

func _PlayStep() -> void:
	var _db : DBResource = System.get_db("game_state")
	if _db and sndctrl:
		var setname = _db.get_value("player.footsteps.soundset", "steps")
		sndctrl.play_random_set(setname)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func hide_viz(enable : bool = true) -> void:
	.hide_viz(enable)
	if anim_node:
		$AnimFade.play("RESET")

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

