extends "res://Actors/Actor.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : KinematicBody2D = null
var _active_anim : String = ""

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = get_node("Anim")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	anim_node.connect("animation_finished", self, "_on_anim_finished")

func _enter_tree() -> void:
	if _active_anim != "":
		anim_node.play(_active_anim)
		_active_anim = ""

func _exit_tree() -> void:
	if anim_node.is_playing():
		_active_anim = anim_node.assigned_animation

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateViz() -> void:
	if anim_node.is_playing() and anim_node.assigned_animation.substr(0, 4) == "fade":
		return
	
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
	if anim_node.assigned_animation.substr(0, 4) == "fade" and anim_node.is_playing():
		return
		
	if anim_node.assigned_animation != anim_name:
		anim_node.play(anim_name)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func fade_in(dir_name : String = "") -> void:
	_Fade("fade_in")

func fade_out(dir_name : String = "") -> void:
	_Fade("fade_out")

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_anim_finished(anim_name : String) -> void:
	if anim_name.substr(0, 4) == "fade":
		emit_signal("faded")

