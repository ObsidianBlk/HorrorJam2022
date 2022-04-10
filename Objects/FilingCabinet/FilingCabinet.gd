tool
extends Node2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var memetic_effect : bool = false
export var memetic_color : Color = Color(1,1,1,1)	setget set_memetic_color
export var timeline_name : String = ""
export var trigger_key : String = ""
export var trigger_on_true : bool = false

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var static_col_node : CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")
onready var trigger_node : Area2D = get_node("Trigger")
onready var sprite_node : Sprite = get_node("Sprite")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_memetic_color(c : Color) -> void:
	memetic_color = c
	memetic_color.a = 1.0
	if memetic_effect and sprite_node and Engine.editor_hint:
		sprite_node.modulate = c


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.editor_hint:
		if memetic_effect:
			var _res = Memetics.connect("memetic_changed", self, "_on_memetic_changed")
			_on_memetic_changed(Memetics.get_memetic_value())
		else:
			sprite_node.modulate = Color(1,1,1,1)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetDBValue(key : String, default = null):
	var _db = System.get_db("game_state")
	if _db:
		return _db.get_value(key, default)
	return default


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_memetic_changed(value : float) -> void:
	if sprite_node and memetic_effect:
		sprite_node.modulate = lerp(Color(1,1,1,0), memetic_color, value)
		if value > 0.0:
			static_col_node.disabled = false
			trigger_node.enabled = true
		else:
			static_col_node.disabled = true
			trigger_node.enabled = false


func _on_trigger_on():
	if timeline_name != "":
		var trigger = trigger_key == ""
		if trigger_key != "":
			var val = _GetDBValue(trigger_key, false)
			if val and trigger_on_true:
				trigger = true
			elif not val and not trigger_on_true:
				trigger = true

		if trigger:
			System.request_dialog(timeline_name)
