extends Node2D

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal request_zone_change(scene, door_name)

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var opened : bool = false			setget set_opened
# TODO: Have doors look for "keys" within the actors that trigger it.
export (String, FILE, "*.tscn") var connected_scene : String = ""
export var connected_door : String = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var trigger_node : Area2D = get_node_or_null("TriggerArea")
onready var anim_node : AnimationPlayer = get_node_or_null("Anim")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_opened(o : bool) -> void:
	opened = o
	if anim_node != null:
		anim_node.play("open" if opened else "closed")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	if trigger_node != null:
		trigger_node.connect("body_entered", self, "on_body_entered")
		trigger_node.connect("body_exited", self, "on_body_exited")
	if anim_node != null:
		anim_node.connect("animation_finished", self, "on_animation_finished")
	set_opened(opened)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _ConnectBody(body : Node2D, enable : bool = true) -> void:
	if enable:
		if not body.is_connected("interact", self, "on_interact"):
			body.connect("interact", self, "on_interact", [body])
			body.connect("trigger", self, "on_trigger", [body])
	else:
		if body.is_connected("interact", self, "on_interact"):
			body.disconnect("interact", self, "on_interact")
			body.disconnect("trigger", self, "on_trigger")

func _ChangeDoorState(state : String, anim_name : String, animate : bool, wait_for_completion : bool) -> void:
	if anim_node.assigned_animation != state:
		if animate:
			anim_node.play(anim_name)
			if wait_for_completion:
				yield(anim_node, "animation_finished")
		else:
			anim_node.play(state)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func open_door(animate : bool = true, wait_for_completion : bool = false) -> void:
	_ChangeDoorState("opened", "opening", animate, wait_for_completion)

func close_door(animate : bool = true, wait_for_completion : bool = false) -> void:
	_ChangeDoorState("closed", "closing", animate, wait_for_completion)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_animation_finished(anim : String) -> void:
	if anim_node == null:
		return
	
	match anim:
		"opening":
			anim_node.play("opened")
		"closing":
			anim_node.play("closed")


func on_body_exited(body : Node2D) -> void:
	if body.is_in_group("Actor") and body.has_signal("interact"):
		_ConnectBody(body, false)


func on_body_entered(body : Node2D) -> void:
	if body.is_in_group("Actor") and body.has_signal("interact"):
		_ConnectBody(body)


func on_interact(body : Node2D) -> void:
	if anim_node == null:
		return
	
	if body.is_connected("interact", self, "on_interact"):
		match anim_node.assigned_animation:
			"opened":
				anim_node.play("closing")
			"closed":
				anim_node.play("opening")

func on_trigger(body : Node2D) -> void:
	if anim_node == null:
		return
	if anim_node.assigned_animation == "opened" and connected_scene != "" and connected_door != "":
		_ConnectBody(body, false)
		body.fade_out()
		emit_signal("request_zone_change", connected_scene, connected_door)

