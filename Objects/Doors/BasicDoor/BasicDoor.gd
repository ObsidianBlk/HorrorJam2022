tool
extends "res://Objects/Doors/Door.gd"


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal door_opened()
signal door_closed()

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const BOTTOM_SCENE_ALPHA : float = 0.45

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
# TODO: Have doors look for "keys" within the actors that trigger it.

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = get_node("Anim")
onready var sprite_node : Sprite = get_node("Sprite")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_state(s : bool) -> void:
	.set_state(s)
	if not Engine.editor_hint:
		var db = System.get_db("game_state")
		if db:
			db.set_value("doors." + name + ".opened", state == STATE.Opened, true)
	if anim_node != null:
		anim_node.play("opened" if state == STATE.Opened else "closed")


func set_facing(f : int) -> void:
	.set_facing(f)
	if [FACING.Up, FACING.Left, FACING.Right].find(facing) >= 0:
		if sprite_node:
			sprite_node.self_modulate = Color(1,1,1,BOTTOM_SCENE_ALPHA)
		if col_shape_node:
			col_shape_node.position.y = -5
	else:
		if sprite_node:
			sprite_node.self_modulate = Color(1,1,1,1)
		if col_shape_node:
			col_shape_node.position.y = 5


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_facing(facing)
	if not Engine.editor_hint:
		if trigger_node != null:
			trigger_node.connect("body_entered", self, "on_body_entered")
			trigger_node.connect("body_exited", self, "on_body_exited")
		if anim_node != null:
			anim_node.connect("animation_finished", self, "on_animation_finished")
		var db = System.get_db("game_state")
		if db:
			if db.has_value("doors." + name + ".opened"):
				set_opened(db.get_value("doors." + name + ".opened"))
			else:
				set_opened(opened)
	else:
		set_opened(opened)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _ChangeDoorState(state : String, anim_name : String, animate : bool) -> void:
	if anim_node.assigned_animation != state:
		if animate:
			anim_node.play(anim_name)
			return
		else:
			anim_node.play(state)
	if state == "opened":
		set_opened(true)
		call_deferred("emit_signal", "door_opened")
	else:
		set_opened(false)
		call_deferred("emit_signal", "door_closed")

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func open_door(animate : bool = true) -> void:
	_ChangeDoorState("opened", "opening", animate)

func close_door(animate : bool = true) -> void:
	_ChangeDoorState("closed", "closing", animate)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_animation_finished(anim : String) -> void:
	if anim_node == null:
		return
	
	match anim:
		"opening":
			anim_node.play("opened")
			set_opened(true)
			emit_signal("door_opened")
		"closing":
			anim_node.play("closed")
			set_opened(false)
			emit_signal("door_closed")

func on_interact(body : Node2D) -> void:
	if anim_node == null:
		return
	
	if body.is_connected("interact", self, "on_interact"):
		match anim_node.assigned_animation:
			"opened":
				anim_node.play("closing")
			"closed":
				anim_node.play("opening")

