tool
extends Node2D



export var liquid_color : Color = Color.blueviolet

onready var _liquid_node : Sprite = get_node("Liquid")

func set_liquid_color(c : Color) -> void:
	liquid_color = c
	if _liquid_node:
		_liquid_node.modulate = liquid_color

func _ready() -> void:
	set_liquid_color(liquid_color)

