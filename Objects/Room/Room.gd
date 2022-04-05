tool
extends Node2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const FLOOR_BASE_PATH = "res://Assets/Env/Floors/"
const WALL_BASE_PATH = "res://Assets/Env/Walls/"
const FLOOR_SHADOW_PATH = "res://Assets/Env/Floors/floor_shadow.png"
const WALL_EDGE_SHADOW_PATH = "res://Assets/Env/Walls/wall_edge_shadow.png"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var wall_base : String = ""					setget set_wall_base
export var floor_base : String = ""					setget set_floor_base
export var include_wall_left : bool = true			setget set_include_wall_left
export var include_wall_right : bool = true			setget set_include_wall_right
export var room_size : float = 256.0				setget set_room_size
export var shadow_color : Color = Color.dimgray		setget set_shadow_color

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

var _wall_sprite : Sprite = null
var _floor_sprite : Sprite = null
var _edge_l_sprite : Sprite = null
var _edge_r_sprite : Sprite = null

var _ready : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var north_col_node : CollisionShape2D = get_node("Body/North")
onready var south_col_node : CollisionShape2D = get_node("Body/South")
onready var east_col_node : CollisionPolygon2D = get_node("Body/East")
onready var west_col_node : CollisionPolygon2D = get_node("Body/West")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_wall_base(b : String) -> void:
	b = b.lstrip(" \n\r\t").rstrip(" \r\n\t")
	wall_base = b
	if wall_base == "":
		_ReleaseWallSprite()
	else:
		_BuildWallSprite(wall_base)
	set_include_wall_left(include_wall_left)
	set_include_wall_right(include_wall_right)
	_UpdateCollision()

func set_floor_base(b : String) -> void:
	b = b.lstrip(" \n\r\t").rstrip(" \r\n\t")
	floor_base = b
	if floor_base == "":
		_ReleaseShadowedSprite("floor")
	else:
		_BuildFloorSprite(floor_base)
	_UpdateCollision()

func set_include_wall_left(inc : bool) -> void:
	include_wall_left = inc
	if not include_wall_left:
		_ReleaseShadowedSprite("edge_l")
	elif wall_base != "":
		_BuildWallEdgeSprite(wall_base, true)
	_UpdateCollision()

func set_include_wall_right(inc : bool) -> void:
	include_wall_right = inc
	if not include_wall_right:
		_ReleaseShadowedSprite("edge_r")
	elif wall_base != "":
		_BuildWallEdgeSprite(wall_base)
	_UpdateCollision()

func set_room_size(s : float) -> void:
	if s > 0.0:
		room_size = s
		_BuildRoom()

func set_shadow_color(c : Color) -> void:
	shadow_color = c
	_ColorSpriteShadow(_floor_sprite)
	_ColorSpriteShadow(_edge_l_sprite)
	_ColorSpriteShadow(_edge_r_sprite)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_ready = true
	set_wall_base(wall_base)
	set_floor_base(floor_base)
	set_shadow_color(shadow_color)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildSprite(tex : Texture, norm : Texture = null, centered : bool = false, region : Rect2 = Rect2(0,0,0,0)) -> Sprite:
	if tex != null:
		var spr : Sprite = Sprite.new()
		if spr:
			spr.texture = tex
			if norm != null:
				spr.normal_map = norm
			if region.size.x > 0 and region.size.y > 0:
				spr.region_enabled = true
				spr.region_rect = region
			spr.centered = centered
			return spr
	return null

func _BuildWallSprite(src : String) -> void:
	var res_path = WALL_BASE_PATH + src + ".png"
	var res_n_path = WALL_BASE_PATH + src + "_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			if _wall_sprite != null and _wall_sprite.texture != tex:
				_wall_sprite.texture = tex
				_wall_sprite.normal_map = load(res_n_path)
				_wall_sprite.region_rect = Rect2(0, 0, room_size, tex.get_height())
			elif _wall_sprite == null:
				_wall_sprite = _BuildSprite(tex, load(res_n_path), false, Rect2(0,0,room_size, tex.get_height()))
				if _wall_sprite:
					add_child(_wall_sprite)
			if _wall_sprite != null and _floor_sprite != null:
				_floor_sprite.position = Vector2(0, _wall_sprite.texture.get_height())

func _ReleaseWallSprite() -> void:
	if _wall_sprite == null:
		return
	
	var parent = _wall_sprite.get_parent()
	if parent:
		parent.remove_child(_wall_sprite)
	_wall_sprite.queue_free()
	_wall_sprite = null

func _BuildWallEdgeSprite(src : String, left_edge : bool = false) -> void:
	var res_path = WALL_BASE_PATH + src + "_e.png"
	var res_n_path = WALL_BASE_PATH + src + "_e_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			var edge : Sprite = _edge_l_sprite if left_edge else _edge_r_sprite
			if edge != null and edge.texture != tex:
				edge.texture = tex
				edge.normal_map = load(res_n_path)
				if not left_edge:
					edge.position = Vector2(room_size - tex.get_width(), 0)
			elif edge == null:
				edge = _BuildSprite(tex, load(res_n_path))
				if edge:
					add_child(edge)
					var shd = _BuildSprite(load(WALL_EDGE_SHADOW_PATH))
					if shd:
						shd.name = "shadow"
						shd.modulate = shadow_color
						if left_edge:
							shd.flip_h = true
						edge.add_child(shd)
					if left_edge:
						edge.flip_h = true
						_edge_l_sprite = edge
					else:
						_edge_r_sprite = edge
						_edge_r_sprite.position = Vector2(room_size - tex.get_width(), 0)


func _ReleaseShadowedSprite(spr_name : String) -> void:
	var spr : Sprite = null
	match spr_name:
		"floor":
			spr = _floor_sprite
		"edge_l":
			spr = _edge_l_sprite
		"edge_r":
			spr = _edge_r_sprite


	if spr != null:
		var shd : Sprite = _GetSpriteShadow(spr)
		if shd:
			spr.remove_child(shd)
			shd.queue_free()
		var parent = spr.get_parent()
		if parent:
			parent.remove_child(spr)
		spr.queue_free()
	
	match spr_name:
		"floor":
			_floor_sprite = null
		"edge_l":
			_edge_l_sprite = null
		"edge_r":
			_edge_r_sprite = null


func _BuildFloorSprite(src : String) -> void:
	var res_path = FLOOR_BASE_PATH + src + ".png"
	var res_n_path = FLOOR_BASE_PATH + src + "_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			if _floor_sprite != null and _floor_sprite.texture != tex:
				_floor_sprite.texture = tex
				_floor_sprite.normal_map = load(res_n_path)
			elif _floor_sprite == null:
				_floor_sprite = _BuildSprite(tex, load(res_n_path), false, Rect2(0, 0, room_size, tex.get_height()))
				if _floor_sprite:
					var shd = _BuildSprite(load(FLOOR_SHADOW_PATH), null, false, Rect2(0, 0, room_size, tex.get_height()))
					if shd:
						shd.name = "shadow"
						shd.modulate = shadow_color
						_floor_sprite.add_child(shd)
					if _wall_sprite != null:
						add_child_below_node(_wall_sprite, _floor_sprite)
						_floor_sprite.position = Vector2(0, _wall_sprite.texture.get_height())
					else:
						add_child(_floor_sprite)


func _BuildRoom() -> void:
	if _wall_sprite:
		_wall_sprite.region_rect = Rect2(0, 0, room_size, _wall_sprite.texture.get_height())
		if _floor_sprite:
			_floor_sprite.position = Vector2(0, _wall_sprite.texture.get_height())
	if _floor_sprite:
		_floor_sprite.region_rect = Rect2(0, 0, room_size, _floor_sprite.texture.get_height())
		var floor_shadow : Sprite = _GetSpriteShadow(_floor_sprite)
		if floor_shadow:
			floor_shadow.region_rect = Rect2(0, 0, room_size, floor_shadow.texture.get_height())
	if _edge_r_sprite:
		var ew = _edge_r_sprite.texture.get_width()
		_edge_r_sprite.position = Vector2(room_size - ew, 0)
	_UpdateCollision()


func _UpdateCollision() -> void:
	if _ready  and _wall_sprite:
		var wheight : float = _wall_sprite.texture.get_height()
		var fheight : float = 64 if not _floor_sprite else _floor_sprite.texture.get_height()
		
		if north_col_node.shape == null:
			var shape : RectangleShape2D = RectangleShape2D.new()
			shape.extents.x = room_size * 0.5
			shape.extents.y = 10
			north_col_node.shape = shape
		else:
			north_col_node.shape.extents.x = room_size * 0.5
		
		north_col_node.position = Vector2(
			room_size * 0.5,
			wheight - (north_col_node.shape.extents.y)
		) 
		
		if south_col_node.shape == null:
			south_col_node.shape = north_col_node.shape
		south_col_node.position = north_col_node.position + Vector2(
			0,
			fheight + (south_col_node.shape.extents.y * 2)
		)
		
		var points = null
		if _edge_l_sprite:
			var ewidth = _edge_l_sprite.texture.get_width()
			var eheight = _edge_l_sprite.texture.get_height()
			points = PoolVector2Array([
				Vector2(ewidth, wheight),
				Vector2(0, wheight + fheight),
				Vector2(-10, wheight + fheight),
				Vector2(ewidth - 10, wheight)
			])
		else:
			points = PoolVector2Array([
				Vector2(0, wheight),
				Vector2(0, wheight + fheight),
				Vector2(-10, wheight + fheight),
				Vector2(-10, wheight)
			])
		if points != null:
			west_col_node.polygon = points
		
		points = null
		if _edge_r_sprite:
			var ewidth = _edge_r_sprite.texture.get_width()
			var eheight = _edge_r_sprite.texture.get_height()
			points = PoolVector2Array([
				Vector2(room_size - ewidth, wheight),
				Vector2(room_size, wheight + fheight),
				Vector2(room_size + 10, wheight + fheight),
				Vector2((room_size - ewidth) + 10, wheight)
			])
		else:
			points = PoolVector2Array([
				Vector2(room_size, wheight),
				Vector2(room_size, wheight + fheight),
				Vector2(room_size + 10, wheight + fheight),
				Vector2(room_size + 10, wheight)
			]) 
		if points != null:
			east_col_node.polygon = points


func _GetSpriteShadow(spr : Sprite) -> Sprite:
	if spr != null:
		for child in spr.get_children():
			if child.name == "shadow":
				return child
	return null

func _ColorSpriteShadow(spr : Sprite) -> void:
	if spr != null:
		var ss = _GetSpriteShadow(spr)
		if ss:
			ss.modulate = shadow_color

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

