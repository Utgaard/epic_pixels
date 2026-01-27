class_name CameraRig
extends Node2D

## Camera rig with pixel snapping and trauma-based screen shake.

@onready var camera: Camera2D = $Camera2D

# Shake parameters
@export var max_shake_offset: float = 8.0
@export var trauma_decay_rate: float = 2.0

var _trauma: float = 0.0
var _base_position: Vector2


func _ready() -> void:
	_base_position = position

	# Ensure camera settings for pixel-perfect rendering
	if camera:
		camera.position_smoothing_enabled = false


func _process(delta: float) -> void:
	_decay_trauma(delta)
	_apply_shake()
	_snap_to_pixel()


func _decay_trauma(delta: float) -> void:
	_trauma = maxf(0.0, _trauma - trauma_decay_rate * delta)


func _apply_shake() -> void:
	if _trauma <= 0.0:
		position = _base_position
		return

	# Quadratic falloff for more natural feel
	var shake_intensity = _trauma * _trauma

	var offset = Vector2(
		randf_range(-1.0, 1.0) * max_shake_offset * shake_intensity,
		randf_range(-1.0, 1.0) * max_shake_offset * shake_intensity
	)

	position = _base_position + offset


func _snap_to_pixel() -> void:
	# Round position to nearest pixel for crisp rendering
	position = position.round()
	if camera:
		camera.position = camera.position.round()


## Add trauma to trigger screen shake. Value is clamped to 0-1 range.
func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


## Get current trauma level (0-1).
func get_trauma() -> float:
	return _trauma


## Reset camera to base position with no shake.
func reset() -> void:
	_trauma = 0.0
	position = _base_position
