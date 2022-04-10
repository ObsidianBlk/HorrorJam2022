extends Node2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const INITIAL_ZONE : String = "res://Scenes/MenuZone.tscn"
const START_ZONE : String = "res://Scenes/Area1/Hall_001.tscn"
const WORLD_SHIFT_TIME : float = 1.0

enum WORLD {Real=0, Alt=1}

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal show_ui(ui_name)
signal zone_changed()
signal player_as_ai(ai_mode)

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : Node2D = null

var _real_world : Node2D = null
var _alt_world : Node2D = null

var _last_world : int = WORLD.Real
var _world_time : float = 0.0

var _game_over : bool = false

var _input_dir = [0,0,0,0]

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var real_viewport_node : Viewport = get_node("Real_World_View")
onready var alt_viewport_node : Viewport = get_node("Alt_World_View")

onready var gameview_node : Control = get_node("Canvas/GameView")
onready var canvas_node : CanvasLayer = get_node("Canvas")
#onready var dialog_node : Control = get_node("Canvas/Dialog")

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	# NOTE: This call won't actually load a resource file as one will not automatically
	# exist. This is here just for test purposes at the moment.
	System.load_or_create_db("game_state", "user://game_state.tres")
	System.connect("request_dialog", self, "_on_request_dialog")
	
	_PrepareWorld()
	
	# Kick the pig!
	#var load_zone = _GetDBValue("world.zone_path", START_ZONE)
	call_deferred("_LoadZone", INITIAL_ZONE, "", false)
	#_LoadZone(load_zone)


func _process(delta : float) -> void:
	match _last_world:
		WORLD.Real:
			#if System.get_audio_sfx_effect() != "RealWorld":
			#	System.set_audio_sfx_effect("RealWorld")
			
			if _world_time > 0.0:
				_world_time = max(0.0, _world_time - delta)
				if _world_time == 0.0:
					gameview_node.material.set_shader_param("in_real_world", true)
					gameview_node.material.set_shader_param("transit", 0.0)
				else:
					var blend = _world_time / WORLD_SHIFT_TIME
					gameview_node.material.set_shader_param("blend", blend)
					gameview_node.material.set_shader_param("transit", 1.0 - blend)
		WORLD.Alt:
			#if System.get_audio_sfx_effect() != "AltWorld":
			#	System.set_audio_sfx_effect("AltWorld")
				
			if _world_time < WORLD_SHIFT_TIME:
				_world_time = min(WORLD_SHIFT_TIME, _world_time + delta)
				if _world_time == WORLD_SHIFT_TIME:
					gameview_node.material.set_shader_param("in_real_world", false)
					gameview_node.material.set_shader_param("transit", 0.0)
				else:
					var blend = _world_time / WORLD_SHIFT_TIME
					gameview_node.material.set_shader_param("blend", blend)
					gameview_node.material.set_shader_param("transit", blend)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetDBValue(key : String, default):
	var db : DBResource = System.get_db("game_state")
	if db:
		return db.get_value(key, default)
	return default


func _SetDBValue(key : String, value, create_if_nexists : bool = false) -> void:
	var db : DBResource = System.get_db("game_state")
	if db:
		db.set_value(key, value, create_if_nexists)


func _PrepareWorld() -> void:
	var pnode = get_tree().get_nodes_in_group("Player")
	if pnode.size() > 0:
		if pnode.size() > 1:
			printerr("WARNING: More than one 'player' node found. Using first found.")
		_player = pnode[0]
	else:
		printerr("WARNING: No 'Player' nodes found!!")

func _GetSceneArea(scene_path : String) -> int:
	var base : String = "res://Scenes/Area"
	if scene_path.begins_with(base):
		var from = base.length()
		var to = scene_path.findn("/", base.length())
		if to > from:
			var num : String = scene_path.substr(from, to - from)
			if num.is_valid_integer():
				return int(num)
	return -1


func _GetSceneName(scene_path : String) -> String:
	return scene_path.get_file().get_basename()


func _LoadZone(scene_path : String, start_door : String = "", store_zone_in_db : bool = true) -> void:
	var zone_inst = load(scene_path)
	if zone_inst:
		var zone = zone_inst.instance()
		if zone:
			if store_zone_in_db:
				_SetDBValue("world.zone_path", scene_path, true)
				_SetDBValue("world.zone_area", _GetSceneArea(scene_path), true)
				_SetDBValue("world.zone_name", _GetSceneName(scene_path), true)
				emit_signal("player_as_ai", false)
			else:
				_last_world = WORLD.Real
				emit_signal("player_as_ai", true)
			
			_player.hide_viz(true)
			if real_viewport_node.has_player():
				real_viewport_node.release_player()
			else:
				alt_viewport_node.release_player()
			real_viewport_node.clear_children()
			alt_viewport_node.clear_children()
			
			for child in zone.get_children():
				if child.name == "RealWorld":
					zone.remove_child(child)
					real_viewport_node.add_child(child)
				elif child.name == "AltWorld":
					zone.remove_child(child)
					alt_viewport_node.add_child(child)
				if not child.visible:
					child.visible = true
			alt_viewport_node.resort_nightmare()
			
			if not real_viewport_node.has_world_nodes() and not alt_viewport_node.has_world_nodes():
				real_viewport_node.add_child(zone)
			else:
				zone.queue_free()
			call_deferred("_StartZone", start_door)
	else:
		printerr("ERROR: Failed to find zone '", scene_path, "'!!")


func _StartZone(door_name : String = "") -> void:
	if not _player:
		return
	
	var entry_door : Node2D = _ConnectDoors(door_name)
	_ConnectPortals()
	_ConnectScrollWalls()
	
	emit_signal("zone_changed")
	if entry_door:
		var vp = real_viewport_node
		if real_viewport_node.is_a_parent_of(entry_door):
			real_viewport_node.add_player(_player)
			_SetDBValue("player.world", "real", true)
			alt_viewport_node.track_sibling_camera()
			_ShowWorldPortals(real_viewport_node)
		else:
			vp = alt_viewport_node
			alt_viewport_node.add_player(_player)
			_SetDBValue("player.world", "alt", true)
			real_viewport_node.track_sibling_camera()
			_ShowWorldPortals(alt_viewport_node)
			
		
		var fvec = entry_door.get_facing_vector()
		if fvec.x != 0.0:
			fvec.y = 1
			_player.global_position = entry_door.global_position + (fvec * 20)
		else:
			_player.global_position = entry_door.global_position + (fvec * 12)
		vp.snap_camera_to_target()
		vp.camera_use_alt_target("camera_target") # This is a hack, really.
		if entry_door.has_method("open_door"):
			entry_door.open_door(true)
			yield(entry_door, "door_opened")
		_player.fade_in(entry_door.get_facing_name())
	else:
		var info : Dictionary = {}
		match _last_world:
			WORLD.Real:
				info = _FindViewportPlayerStart(real_viewport_node, alt_viewport_node)
			WORLD.Alt:
				info = _FindViewportPlayerStart(alt_viewport_node, real_viewport_node)
			_:
				info = {"pos":null, "primary":real_viewport_node, "secondary":alt_viewport_node}
		
		info.primary.add_player(_player)
		info.secondary.track_sibling_camera()
		info.primary.camera_use_alt_target("camera_target") # This is a hack, really.
		_ShowWorldPortals(info.primary)
		if info.pos != null:
			_player.global_position = info.pos
			info.primary.snap_camera_to_target()
		_player.hide_viz(false)
		#gameview_node.material.set_shader_param("blend", 1.0)

func _FindViewportPlayerStart(viewA : Viewport, viewB : Viewport) -> Dictionary:
	var res = {"pos":null, "primary":viewA, "secondary":viewB}
	res.pos = viewA.get_player_start()
	if res.pos == null:
		res.pos = viewB.get_player_start()
		if res.pos != null:
			res.primary = viewB
			res.primary = viewA
	return res

func _ConnectDoors(door_name : String) -> Node2D:
	var entry_door : Node2D = null
	var doors = get_tree().get_nodes_in_group("Door")
	if doors.size() > 0:
		for door in doors:
			door.connect("request_zone_change", self, "_LoadZone")
			if door.has_signal("game_win"):
				door.connect("game_win", self, "_on_game_win")
			if door.name == door_name:
				entry_door = door
	return entry_door

func _ConnectPortals() -> void:
	var portals = get_tree().get_nodes_in_group("Portal")
	for portal in portals:
		if real_viewport_node.is_a_parent_of(portal):
			portal.connect(
				"world_shift",
				self, "_on_world_shift",
				[real_viewport_node, alt_viewport_node, WORLD.Alt]
			)
		elif alt_viewport_node.is_a_parent_of(portal):
			portal.connect(
				"world_shift",
				self, "_on_world_shift",
				[alt_viewport_node, real_viewport_node, WORLD.Real]
			)

func _ConnectScrollWalls() -> void:
	var wslist = get_tree().get_nodes_in_group("ScrollWall")
	for ws in wslist:
		if real_viewport_node.is_a_parent_of(ws):
			ws.camera_node_path = real_viewport_node.get_camera_path_to(ws)
		elif alt_viewport_node.is_a_parent_of(ws):
			ws.camera_node_path = alt_viewport_node.get_camera_path_to(ws)

func _ShowWorldPortals(view : Viewport) -> void:
	var portals = get_tree().get_nodes_in_group("Portal")
	for portal in portals:
		if view.is_a_parent_of(portal):
			portal.visible = true
		else:
			portal.visible = false

func _InvertShader() -> void:
	var shader_invert = gameview_node.material.get_shader_param("invert")
	gameview_node.material.set_shader_param("invert", not shader_invert)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_start_game() -> void:
	emit_signal("show_ui", "NONE")
	var load_zone = _GetDBValue("world.zone_path", START_ZONE)
	call_deferred("_LoadZone", load_zone)

func _on_world_shift(from_view : Viewport, to_view : Viewport, target_world : int) -> void:
	if WORLD.values().find(target_world) >= 0 and _last_world != target_world:
		if to_view.has_world_nodes():
			_last_world = target_world
			from_view.release_player()
			from_view.audio_listener_enable_2d = false
			to_view.add_player(_player)
			to_view.audio_listener_enable_2d = true
			from_view.track_sibling_camera()
			_SetDBValue("player.world", "real" if target_world == WORLD.Real else "alt", true)
			_ShowWorldPortals(to_view)


func _on_request_dialog(timeline_name : String) -> void:
	if timeline_name != "":
		var dialog = Dialogic.start(timeline_name, "", "res://addons/dialogic/Nodes/DialogNode.tscn",false)
		if dialog:
			dialog.connect("timeline_start", self, "_on_Dialog_timeline_start")
			dialog.connect("timeline_end", self, "_on_Dialog_timeline_end")
			dialog.connect("dialogic_signal", self, "_on_dialog_signal")
			dialog.pause_mode = PAUSE_MODE_PROCESS
			canvas_node.add_child(dialog)

func _on_dialog_signal(info : String) -> void:
	var segs = info.split(":")
	if segs.size() > 0:
		match segs[0]:
			"GameOver":
				_game_over = true
			"DBSet":
				var _db = System.get_db("game_state")
				if _db == null:
					printerr("DBSet database not found")
					return
				if segs.size() == 3:
					var key = segs[1]
					var sval : String = segs[2].to_lower()
					var val = null
					if ["true", "t"].find(sval) >= 0:
						val = true
					elif ["false", "f"].find(sval) >= 0:
						val = false
					elif sval.is_valid_float():
						val = float(sval)
					elif sval.is_valid_integer():
						val = int(sval)
					if val != null:
						_db.set_value(key, val, true)
					else:
						printerr("DBSet invalid value type")
				else:
					printerr("DBSet request malformed")


func _on_Dialog_timeline_start(timeline_name : String) -> void:
	if timeline_name != "":
		get_tree().paused = true


func _on_Dialog_timeline_end(timeline_name : String) -> void:
	if timeline_name != "":
		get_tree().paused = false
		if _game_over:
			_game_over = false
			_on_game_over()


func _on_player_died():
	System.request_dialog("DiedByNightmare")

func _on_game_win():
	System.request_dialog("Escaped")


func _on_game_over():
	emit_signal("show_ui", "MainMenu")
	System.reset_db("game_state")
	call_deferred("_LoadZone", INITIAL_ZONE, "", false)
