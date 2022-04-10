tool
extends StaticBody2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (int, "left_facing", "right_facing") var facing : int = 0	setget set_facing

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var sprite_node : Sprite = get_node("Sprite")
onready var col_left_node : CollisionPolygon2D = get_node("Collision_Left")
onready var col_right_node : CollisionPolygon2D = get_node("Collision_Right")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_facing(f : int) -> void:
	if f == 0 or f == 1:
		facing = f
		_UpdateFacing()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_UpdateFacing()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateFacing() -> void:
	if not (sprite_node and col_left_node and col_right_node):
		return
	
	match facing:
		0 : # Left Facing
			sprite_node.flip_h = false
			col_left_node.disabled = false
			col_right_node.disabled = true
		1 : # Right Facing
			sprite_node.flip_h = true
			col_left_node.disabled = true
			col_right_node.disabled = false


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

