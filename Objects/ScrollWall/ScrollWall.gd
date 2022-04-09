tool
extends Node2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var camera_node_path : NodePath = ""
export var texture : Texture = null				setget set_texture
export var scroll_width = 0
export var virtual_width = 0
export var offset : Vector2 = Vector2.ZERO
export var invert_scroll : bool = false


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var sprite_node : Sprite = get_node("Sprite")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_texture(tex : Texture) -> void:
	texture = tex
	if sprite_node:
		sprite_node.texture = tex

func set_offset(o : Vector2) -> void:
	offset = o
	if sprite_node:
		sprite_node.position = offset

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _draw():
	if not Engine.editor_hint:
		return
	
	var height : float = 0 if texture == null else texture.get_height()
	var width : float = 0 if texture == null else texture.get_width()
	var center : Vector2 = Vector2(scroll_width, height) * 0.5
	var rect : Rect2 = Rect2(offset - center, Vector2(scroll_width, height))
	draw_rect(rect, Color(0.0, 0.25, 1.0), false)


func _process(_delta : float) -> void:
	if Engine.editor_hint:
		update()
		return
	
	if camera_node_path != "" and virtual_width > 0 and scroll_width > 0 and texture != null:
		var tex_width : float = texture.get_width()
		if tex_width <= scroll_width:
			print("Tex Width: ", tex_width, " | scroll Width: ", scroll_width)
			return
		
		var cam = get_node_or_null(camera_node_path)
		if not (cam is Camera2D):
			print("Failed to find camera")
			return
		
		var ipos : float = (global_position.x + offset.x) - (virtual_width * 0.5)
		var cam_pos : float = cam.global_position.x - ipos
		var across : float = max(0.0, min(1.0, cam_pos / virtual_width))
		if invert_scroll:
			across = 1.0 - across
		
		var tex_reg_size : Vector2 = Vector2(scroll_width, texture.get_height())
		var tex_reg_offset : Vector2 = Vector2(
			(tex_width - scroll_width) * across,
			0
		)
		
		if sprite_node:
			if sprite_node.texture != texture:
				sprite_node.texture = texture
			sprite_node.position = offset
			sprite_node.region_enabled = true
			sprite_node.region_rect = Rect2(tex_reg_offset, tex_reg_size)
	else:
		print("Camera Path: ", camera_node_path)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

