extends "res://Scripts/Interactable.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var sprite_node : Sprite = get_node("Sprite")
onready var light_node : Light2D = get_node("Light2D")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_interact() -> void:
	if sprite_node.frame == 0:
		sprite_node.frame = 1
		light_node.enabled = true
		emit_signal("trigger_on")
