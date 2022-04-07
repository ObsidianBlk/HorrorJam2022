tool
extends StaticBody2D


# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export (int, "Down", "Up", "Right", "Left") var facing : int = 0	setget set_facing

# -----------------------------------------------------------------------------
# Onready Variables
# -----------------------------------------------------------------------------
onready var sprite_node : Sprite = get_node("Sprite")

# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_facing(f : int) -> void:
	if f >= 0 and f < 4:
		facing = f
		_UpdateFacing()

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	_UpdateFacing()

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _UpdateFacing() -> void:
	if sprite_node != null:
		match facing:
			0: # Down
				sprite_node.flip_h = false
				sprite_node.frame = 0
			1: # Up
				sprite_node.flip_h = false
				sprite_node.frame = 1
			2: # Right
				sprite_node.flip_h = false
				sprite_node.frame = 2
			3: # Left
				sprite_node.flip_h = true
				sprite_node.frame = 2

