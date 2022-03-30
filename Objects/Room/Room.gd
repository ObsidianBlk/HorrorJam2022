tool
extends Node2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var wall_sprite_path : NodePath = ""
export var wall_edge_sprite_path : NodePath = ""
export var floor_sprite_path : NodePath = ""
export var include_wall_left : bool = true
export var include_wall_right : bool = true
export var room_size : float = 256.0				setget  set_room_size

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------

func set_room_size(s : float) -> void:
	if s > 0.0:
		room_size = s
		_BuildRoom()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildRoom() -> void:
	var wall_height : float = 0.0
	if wall_sprite_path != "":
		var wall = get_node_or_null(wall_sprite_path)
		if wall and wall is Sprite and wall.texture != null:
			wall_height = wall.texture.get_height()
			wall.centered = false
			wall.region_enabled = true
			wall.region_rect = Rect2(0, 0, room_size, wall_height)
	
	if floor_sprite_path != "" and wall_height > 0.0:
		var flr = get_node_or_null(floor_sprite_path)
		if flr and flr is Sprite and flr.texture != null:
			var flr_height = flr.texture.get_height()
			flr.centered = false
			flr.region_enabled = true
			flr.region_rect = Rect2(0, 0, room_size, flr_height)
			flr.position = Vector2(0, wall_height)


	if wall_edge_sprite_path != "":
		var edge = get_node_or_null(wall_edge_sprite_path)
		if edge and edge is Sprite and edge.texture != null:
			var width = edge.texture.get_width()
			edge.centered = false
			if include_wall_left:
				var edgeL : Sprite = edge.duplicate()
				add_child(edgeL)
				edgeL.flip_h = true
			if include_wall_right:
				edge.position = Vector2(room_size - width, 0)
			else:
				edge.visible = false


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

