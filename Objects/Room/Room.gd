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
export var wall_base : String = ""
export var floor_base : String = ""
export var include_wall_left : bool = true
export var include_wall_right : bool = true
export var room_size : float = 256.0				setget  set_room_size

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

var _wall_sprite : Sprite = null
var _floor_sprite : Sprite = null
var _edge_l_sprite : Sprite = null
var _edge_r_sprite : Sprite = null

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
	return null

func _BuildWallSprite(src : String) -> Sprite:
	var res_path = WALL_BASE_PATH + src + ".png"
	var res_n_path = WALL_BASE_PATH + src + "_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			return _BuildSprite(tex, load(res_n_path), false, Rect2(0,0,room_size, tex.get_height()))
	return null

func _ReleaseWallSprite() -> void:
	if _wall_sprite == null:
		return
	
	var parent = _wall_sprite.get_parent()
	if parent:
		parent.remove_child(_wall_sprite)
	_wall_sprite.queue_free()
	_wall_sprite = null

func _BuildWallEdgeSprite(src : String) -> Sprite:
	var res_path = WALL_BASE_PATH + src + "_e.png"
	var res_n_path = WALL_BASE_PATH + src + "_e_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			var spr = _BuildSprite(tex, load(res_n_path))
			if spr:
				var shd = _BuildSprite(load(WALL_EDGE_SHADOW_PATH))
				if shd:
					shd.name = "Wall_Edge_Shadow"
					spr.add_child(shd)
				return spr
	return null

func _ReleaseShadowedSprite(spr_name : String) -> void:
	var spr : Sprite = null
	match spr_name:
		"floor":
			pass
		"edge_l":
			pass
		"edge_r":
			pass
	
	if spr != null:
		pass
	
	match spr_name:
		"floor":
			_floor_sprite = null
		"edge_l":
			_edge_l_sprite = null
		"edge_r":
			_edge_r_sprite = null

func _BuildFloorSprite(src : String) -> Sprite:
	var res_path = FLOOR_BASE_PATH + src + ".png"
	var res_n_path = FLOOR_BASE_PATH + src + "_n.png"
	if ResourceLoader.exists(res_path):
		var tex : Texture = load(res_path)
		if tex:
			var spr = _BuildSprite(tex, load(res_n_path), false, Rect2(0, 0, room_size, tex.get_height()))
			if spr:
				var shd = _BuildSprite(load(FLOOR_SHADOW_PATH), null, false, Rect2(0, 0, room_size, tex.get_height()))
				if shd:
					shd.name = "floor_shadow"
					spr.add_child(shd)
				if _wall_sprite != null:
					spr.position = Vector2(0, _wall_sprite.texture.get_height())
				return spr
	return null


func _BuildRoom() -> void:
	pass


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

