tool
extends "res://Objects/Doors/Door.gd"


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal door_opened()
signal door_closed()
signal game_win()


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const BOTTOM_SCENE_ALPHA : float = 0.45

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var db_variable_name : String = ""
export var lock_variable_name : String = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _nready : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var anim_node : AnimationPlayer = get_node("Anim")
onready var sprite_node : Sprite = get_node("Sprite")
onready var sndctrl_node : Node2D = get_node("SoundCTRL")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_state(s : int) -> void:
	.set_state(s)
	_SetDBVar(db_variable_name + ".opened", state == STATE.Opened, true)
	_BasicDoorState()


func set_facing(f : int) -> void:
	if FACING.values().find(f) >= 0:
		facing = f
		_UpdateCollisionShapes()
	
	_BasicDoorState()
	if facing == FACING.Up:
		if sprite_node:
			sprite_node.self_modulate = Color(1,1,1,BOTTOM_SCENE_ALPHA)
	else:
		if sprite_node:
			sprite_node.self_modulate = Color(1,1,1,1)


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_nready = true
	set_facing(facing)
	if not Engine.editor_hint:
#		if trigger_node != null:
#			trigger_node.connect("body_entered", self, "on_body_entered")
#			trigger_node.connect("body_exited", self, "on_body_exited")
		if anim_node != null:
			anim_node.connect("animation_finished", self, "on_animation_finished")
		var val = _GetDBVar(db_variable_name + ".opened", state == STATE.Opened)
		set_state(STATE.Opened if val == true else STATE.Blocked)
	else:
		set_state(state)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SetDBVar(key_name : String, value, create_if_nexists : bool = false) -> void:
	if not Engine.editor_hint and _nready and db_variable_name != "":
		var db = System.get_db("game_state")
		if db:
			db.set_value(key_name, value, create_if_nexists)


func _GetDBVar(key_name : String, default = null):
	if not Engine.editor_hint and _nready and db_variable_name != "":
		var db = System.get_db("game_state")
		if db:
			return db.get_value(key_name, default)
	return default


func _BasicDoorState() -> void:
	if anim_node != null:
		var facing_name = _GetFacingNameAdj()
		if state == STATE.Opened:
			anim_node.play("opened_" + facing_name)
		else:
			anim_node.play("closed_" + facing_name)

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
	return get_facing_name() # I know this looks stupid. It's a hold-over I didn't bother fixing.

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
			sndctrl_node.play_random_set("close")
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
				var open : bool = true
				if lock_variable_name != "":
					open = _GetDBVar(lock_variable_name, false)
				if open:
					sndctrl_node.play_random_set("open")
					anim_node.play("opening_" + facing_name)


func on_trigger(body : Node2D) -> void:
	if state == STATE.Opened and connected_door == "game win":
		_ConnectBody(body, false)
		var dir_name = "up"
		match facing:
			FACING.Down:
				dir_name = "down"
			FACING.Left:
				dir_name = "left"
			FACING.Right:
				dir_name = "right"
		body.fade_out(dir_name)
		yield(body, "faded")
		emit_signal("game_win")
	else:
		.on_trigger(body)
