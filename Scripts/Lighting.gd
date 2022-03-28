extends Light2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var energy_variance : float = 0.0			setget set_energy_variance
export var flicker_count_min : int = 0
export var flicker_count_max : int = 1
export var flicker_interval : float = 0.0			setget set_flicker_interval
export var flicker_interval_variance : float = 0.0	setget set_flicker_interval_variance

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _timer : Timer = null
var _tween : Tween = null
var _base_energy : float = 0.0
var _flick : int = 0
var _rng : RandomNumberGenerator = null

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_energy_variance(ev : float) -> void:
	if ev >= 0.0:
		energy_variance = ev

func set_flicker_interval(fi : float) -> void:
	if fi >= 0.0:
		flicker_interval = fi

func set_flicker_interval_variance(fiv : float) -> void:
	if fiv >= 0.0:
		flicker_interval_variance = fiv


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	if flicker_interval > 0.0 and flicker_count_min > 0 and flicker_count_max > flicker_count_min:
		_timer = Timer.new()
		add_child(_timer)
		_timer.connect("timeout", self, "_on_flicker_timeout")
		_on_flicker_timeout()
	
	if energy_variance > 0.0:
		_base_energy = energy
		_tween = Tween.new()
		add_child(_tween)
		_tween.connect("tween_all_completed", self, "_on_tween_completed")
		_on_tween_completed()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_flicker_timeout() -> void:
	if _flick == 0:
		enabled = true
		var variance : float = flicker_interval * flicker_interval_variance
		var duration : float = _rng.randf_range(
			flicker_interval - variance,
			flicker_interval + variance
		)
		_flick = _rng.randi_range(flicker_count_min, flicker_count_max)
		_timer.start(duration)
	else:
		if enabled:
			_flick -= 1
			enabled = false
		else:
			enabled = true
		_timer.start(_rng.randf_range(0.02, 0.1))

func _on_tween_completed() -> void:
	var variance = _base_energy * energy_variance
	var target_energy = _rng.randf_range(
		_base_energy - variance,
		_base_energy + variance
	)
	var duration : float = _rng.randf_range(0.1, 4.0)
	_tween.interpolate_property(
		self, "energy",
		energy, target_energy,
		duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.start()


