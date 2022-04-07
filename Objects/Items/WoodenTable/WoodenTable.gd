tool
extends Node2D


# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var table_width : float = 3.0		setget set_table_width

# -----------------------------------------------------------------------------
# Onready Variables
# -----------------------------------------------------------------------------
onready var left_side_node : Node2D = get_node("LeftSide")
onready var right_side_node : Node2D = get_node("RightSide")
onready var surface_sprite_node : Sprite = get_node("Sprite")
onready var surface_col_node : CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")

# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_table_width(w : float) -> void:
	if w >= 1.0:
		table_width = w
		_UpdateTable()

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	_UpdateTable()

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _UpdateTable() -> void:
	if surface_sprite_node != null: # I'm going to assume if one is there, all needed nodes are there
		surface_sprite_node.region_rect.size.x = (table_width * 2) + 1
		surface_col_node.shape.extents.x = table_width
		left_side_node.position.x = -(table_width + 0.5)
		right_side_node.position.x = table_width + 0.5
