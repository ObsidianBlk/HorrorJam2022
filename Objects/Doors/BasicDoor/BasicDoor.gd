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
var _nready : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = get_node("Anim")
onready var sprite_node : Sprite = get_node("Sprite")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_state(s : int) -> void:
	.set_state(s)
	if not Engine.editor_hint and _nready:
		var db = System.get_db("game_state")
		if db:
			db.set_value("doors." + name + ".opened", state == STATE.Opened, true)
	if anim_node != null:
		var facing_name = _GetFacingNameAdj()
		if state == STATE.Opened:
			anim_node.play("opened_" + facing_name)
		else:
			anim_node.play("closed_" + facing_name)


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
	_nready = true
	set_facing(facing)
	if not Engine.editor_hint:
		if trigger_node != null:
			trigger_node.connect("body_entered", self, "on_body_entered")
			trigger_node.connect("body_exited", self, "on_body_exited")
		if anim_node != null:
			anim_node.connect("animation_finished", self, "on_animation_finished")
		var db = System.get_db("game_state")
		var sval = state
		if db:
			if db.has_value("doors." + name + ".opened"):
				var val = db.get_value("doors." + name + ".opened", state == STATE.Opened)
				sval = STATE.Opened if val == true else STATE.Blocked
		set_state(sval)
	else:
		set_state(state)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _ChangeDoorState(state_name : String, anim_name : String, animate : bool) -> void:
	if anim_node.assigned_animation != state_name:
		if animate:
			set_state(STATE.Transition)
			anim_node.play(anim_name)
			return
		else:
			anim_node.play(state_name)
	if state_name.substr(0,6) == "opened":
		set_state(STATE.Opened)
		call_deferred("emit_signal", "door_opened")
	else:
		set_state(STATE.Blocked)
		call_deferred("emit_signal", "door_closed")

func _GetFacingNameAdj() -> String:
	var facing_name = get_facing_name()
	if facing_name == "left" or facing_name == "right":
		facing_name = "side"
	return facing_name

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func open_door(animate : bool = true) -> void:
	var facing_name = _GetFacingNameAdj()
	_ChangeDoorState("opened_" + facing_name, "opening_" + facing_name, animate)

func close_door(animate : bool = true) -> void:
	var facing_name = _GetFacingNameAdj()
	_ChangeDoorState("closed_" + facing_name, "closing_" + facing_name, animate)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_animation_finished(anim : String) -> void:
	if anim_node == null:
		return
	
	var facing_name = _GetFacingNameAdj()
	var base_name = anim.substr(0, 7)
	match base_name:
		"opening":
			anim_node.play("opened_" + facing_name)
			set_state(STATE.Opened)
			emit_signal("door_opened")
		"closing":
			anim_node.play("closed_" + facing_name)
			set_state(STATE.Blocked)
			emit_signal("door_closed")


func on_interact(body : Node2D) -> void:
	if anim_node == null:
		return
	
	if body.is_connected("interact", self, "on_interact"):
		var facing_name = _GetFacingNameAdj()
		var base_name = anim_node.assigned_animation.substr(0, 6)
		match base_name:
			"opened":
				anim_node.play("closing_" + facing_name)
			"closed":
				anim_node.play("opening_" + facing_name)

