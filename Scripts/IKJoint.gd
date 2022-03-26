tool
extends Node2D

# Reference...
# http://www.andreasaristidou.com/publications/papers/FABRIK.pdf


# WARNING: As of this time, this class is not a fully complete implementation of FABRIK.
# It can only sort-of support sub-roots, but not accurately. Best used as single chain IK for
# the time being.

# ---------------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------------
const THRESHOLD : float = 0.01

# ---------------------------------------------------------------------------------------------
# Export Variables
# ---------------------------------------------------------------------------------------------
export var show_bone : bool = true					setget set_show_bone
export var bone_color : Color = Color.coral
export var max_cycles : int = 100					setget set_max_cycles
export var target_node_path : NodePath = ""
#export var verbose : bool = false


# ---------------------------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------------------------
var _desired_position : Vector2 = Vector2.ZERO
var _bone_length : float = 0.0

# ---------------------------------------------------------------------------------------------
# Setters / Getters
# ---------------------------------------------------------------------------------------------
func set_show_bone(s : bool, from_base : bool = true) -> void:
	if from_base:
		var base = get_chain_base()
		if base != null and base != self:
			base.set_show_bone(s, false)
			return

	show_bone = s
	var end = _GetChildJoint()
	if end != null:
		end.set_show_bone(s, false)

func set_max_cycles(c : int, from_base : bool = true) -> void:
	if from_base:
		var base = get_chain_base()
		if base != null and base != self:
			base.set_max_cycles(c, false)
			return
	
	if c > 0:
		max_cycles = c
		var end = _GetChildJoint()
		if end != null:
			end.set_max_cycles(c, false)

	
# ---------------------------------------------------------------------------------------------
# Override Methods
# ---------------------------------------------------------------------------------------------
func _ready() -> void:
	pass


func _draw_joint_bone(joint : Node2D) -> void:
	var angle = joint.position.angle_to_point(Vector2.ZERO) - deg2rad(90)
	var dist = Vector2.ZERO.distance_to(joint.position)
	
	if dist < THRESHOLD:
		return
	
	var bone_width = dist * 0.25
	var hbw = bone_width * 0.5
	var dtrd = (1.0/3.0) * dist
	
	draw_multiline(PoolVector2Array([
		Vector2.ZERO,
		Vector2(hbw, dtrd).rotated(angle),
		Vector2(hbw, dtrd).rotated(angle),
		Vector2(0.0, dist).rotated(angle),
		Vector2(0.0, dist).rotated(angle),
		Vector2(-hbw, dtrd).rotated(angle),
		Vector2(-hbw, dtrd).rotated(angle),
		Vector2.ZERO
	]), bone_color)
	draw_line(Vector2.ZERO, Vector2(0, dist).rotated(angle), bone_color)
	draw_line(Vector2(-hbw, dtrd).rotated(angle), Vector2(hbw, dtrd).rotated(angle), bone_color)


func _draw() -> void:
	if not Engine.editor_hint:
		if not show_bone:
			return
	var joints : Array = _GetChildJoints()
	for joint in joints:
		_draw_joint_bone(joint)


func _process(_delta : float) -> void:
	if not Engine.editor_hint and is_base() and target_node_path != "":
		var target = get_node_or_null(target_node_path)
		if target is Node2D:
			solve(target.global_position)
	update()


# ---------------------------------------------------------------------------------------------
# Private Methods
# ---------------------------------------------------------------------------------------------
func _GetChildJoint() -> Node2D:
	for child in get_children():
		if child.has_method("get_chain_length"):
			return child
	return null


func _GetChildJoints() -> Array:
	var joints : Array = []
	for child in get_children():
		if child.has_method("get_chain_length"):
			joints.append(child)
	return joints


func _GetJointAngle() -> float:
	var joints : Array = _GetChildJoints()
	var size = joints.size()
	if size <= 0:
		return 0.0
	
	var pos = Vector2.ZERO
	for i in range(size):
		pos += joints[i].position
	return (pos / size).angle()



func _OrientToTarget(target : Vector2) -> void:
	var jangle = _GetJointAngle()
	var srot = jangle + global_rotation
	var tangle = (target - global_position).angle()
	rotate(tangle - srot)


func _EffectorWithinThreshold(target : Vector2) -> bool:
	var joints : Array = _GetChildJoints()
	if joints.size() > 0:
		for joint in joints:
			if joint._EffectorWithinThreshold(target):
				return true
		return false
	return _desired_position.distance_to(target) <= THRESHOLD


func _PresolveSnapshot() -> void:
	_bone_length = get_bone_length()
	_desired_position = global_position
	for joint in _GetChildJoints():
		joint._PresolveSnapshot()

# Forward ... Recursively travels up the tree until it reaches the first effector, then
# propagates down to the base.
func _ForwardReach(target : Vector2) -> void:
	if is_effector():
		_desired_position = target
	else:
		var joints : Array = _GetChildJoints()
		var targets : Array = []
		for joint in joints:
			joint._ForwardReach(target) # Keep looking up the tree
#			var vdir = (gpl[item].pos - gpl[item+1].pos).normalized()
#			gpl[item].pos = gpl[item+1].pos + (vdir * gpl[item].length)
			var vdir = (_desired_position - joint._desired_position).normalized()
			targets.append(joint._desired_position + (vdir * _bone_length))
		_desired_position = targets[0]
		if targets.size() > 1:
			for i in range(1, targets.size() - 1):
				_desired_position += targets[i]
			_desired_position /= targets.size()


func _BackwardReach(base : Vector2) -> void:
	var joints : Array = _GetChildJoints()
	if is_base():
		_desired_position = base
	else:
#		var vdir = (gpl[item].pos - gpl[item - 1].pos).normalized()
#		gpl[item].pos = gpl[item-1].pos + (vdir * gpl[item-1].length)
		var parent = get_parent()
		if not parent:
			return # Technically something is wrong here, but let's just bail for now.
		var vdir = (_desired_position - base).normalized()
		_desired_position = base + (vdir * parent._bone_length)
	for joint in joints:
		joint._BackwardReach(_desired_position)


func _OrientChain() -> void:
	var joints : Array = _GetChildJoints()
	if joints.size() <= 0: # We're at an effector. Nothing to orient.
		return
	
	if joints.size() > 1:
		var target : Vector2 = Vector2.ZERO
		for joint in joints:
			target += joint._desired_position
		target /= joints.size()
		_OrientToTarget(target)
		for joint in joints:
			joint._OrientChain()
	else:
		_OrientToTarget(joints[0]._desired_position)
		joints[0]._OrientChain()


func _SolveUnreachable(target : Vector2) -> void:
	_OrientToTarget(target)
	var joints : Array = _GetChildJoints()
	for joint in joints:
		joint._SolveUnreachable(target)


# ---------------------------------------------------------------------------------------------
# Public Methods
# ---------------------------------------------------------------------------------------------
func is_effector() -> bool:
	# The joint is an effector if it has no other IKJoints as children.
	for child in get_children():
		if child.has_method("get_chain_length"):
			return false
	return true

func is_subbase() -> bool:
	return _GetChildJoints().size() > 1

func is_base() -> bool:
	var parent = get_parent()
	if parent:
		return not parent.has_method("get_chain_length")
	return true

func get_bone_length() -> float:
	var joints : Array = _GetChildJoints()
	if joints.size() > 0:
		var end : Vector2 = Vector2.ZERO
		for joint in joints:
			end += joint.position
		end /= joints.size()
		return Vector2.ZERO.distance_to(end)
	return 0.0


func get_chain_length(from_base : bool = false) -> float:
	if from_base:
		var base = get_chain_base()
		if base != self:
			base.get_chain_length()
	
	var joint_dist : float = 0.0
	var clen : float = get_bone_length()
	var joints : Array = _GetChildJoints()
	if joints.size() > 0:
		for joint in joints:
			var d = joint.get_chain_length()
			if d > joint_dist:
				joint_dist = d
	return clen + joint_dist


func get_chain_base() -> Node2D:
	var parent = get_parent()
	if parent != null and parent.has_method("get_chain_base"):
		return parent.get_chain_base()
	else:
		return self


func solve(target : Vector2) -> void:
	var base = get_chain_base()
	if base == self:
		var dist = target.distance_to(global_position)
		var clen = get_chain_length()
		if clen < dist: # Cannot reach target
			_SolveUnreachable(target)
		else: # CAN reach target
			_PresolveSnapshot()
			for i in range(max_cycles):
				if _EffectorWithinThreshold(target):
					break
				
				_ForwardReach(target)
				_BackwardReach(global_position)
			
			_OrientChain()
	else:
		base.solve(target)


