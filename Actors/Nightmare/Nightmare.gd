extends KinematicBody2D


onready var legL_node : Node2D = get_node("LegL")
onready var legLpos_node : Position2D = get_node("LegLPos")
onready var legR_node : Node2D = get_node("LegR")
onready var legRpos_node : Position2D = get_node("LegRPos")

func _process(_delta : float) -> void:
	legL_node.solve(legLpos_node.global_position)
	legR_node.solve(legRpos_node.global_position)
