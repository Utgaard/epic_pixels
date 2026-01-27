class_name MovementComponent
extends Node

## Handles unit movement with inertia-based acceleration/deceleration.

signal stopped
signal started_moving

@export var max_speed: float = 60.0
@export var acceleration: float = 200.0
@export var deceleration: float = 300.0

var _body: CharacterBody2D = null
var _current_velocity: float = 0.0
var _target_direction: int = 0  # -1, 0, or 1
var _is_moving: bool = false


func _ready() -> void:
	# Get parent CharacterBody2D
	_body = get_parent() as CharacterBody2D
	if not _body:
		push_warning("[MovementComponent] Parent is not CharacterBody2D")


func _physics_process(delta: float) -> void:
	if not _body:
		return

	_update_velocity(delta)
	_apply_movement()


func _update_velocity(delta: float) -> void:
	if _target_direction != 0:
		# Accelerate toward target direction
		var target_velocity = _target_direction * max_speed
		_current_velocity = move_toward(_current_velocity, target_velocity, acceleration * delta)

		if not _is_moving and absf(_current_velocity) > 0.1:
			_is_moving = true
			started_moving.emit()
	else:
		# Decelerate to stop
		_current_velocity = move_toward(_current_velocity, 0.0, deceleration * delta)

		if _is_moving and absf(_current_velocity) < 0.1:
			_current_velocity = 0.0
			_is_moving = false
			stopped.emit()


func _apply_movement() -> void:
	_body.velocity.x = _current_velocity
	_body.velocity.y = 0  # No vertical movement for ground units
	_body.move_and_slide()


## Start moving in a direction. direction should be 1 (right) or -1 (left).
func move_forward(direction: int) -> void:
	_target_direction = signi(direction)


## Stop moving (will decelerate to halt).
func stop() -> void:
	_target_direction = 0


## Immediately halt all movement (no deceleration).
func halt() -> void:
	_target_direction = 0
	_current_velocity = 0.0
	if _body:
		_body.velocity = Vector2.ZERO
	if _is_moving:
		_is_moving = false
		stopped.emit()


## Check if currently moving.
func is_moving() -> bool:
	return _is_moving


## Get current velocity.
func get_velocity() -> float:
	return _current_velocity


## Get current speed (absolute value).
func get_speed() -> float:
	return absf(_current_velocity)
