class_name WeaponComponent
extends Node

## Hitscan weapon that fires at targets and deals damage.

signal fired(from_pos: Vector2, to_pos: Vector2)
signal hit(target: Node2D, damage: float)

@export var damage: float = 15.0
@export var fire_rate: float = 2.0        ## Shots per second
@export var range: float = 300.0          ## Max firing range in pixels
@export var muzzle_offset: Vector2 = Vector2(12, -8)  ## Offset from unit center

var _cooldown: float = 0.0
var _parent_unit: Node2D = null


func _ready() -> void:
	_parent_unit = get_parent() as Node2D


func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta


## Check if weapon can fire (cooldown ready).
func can_fire() -> bool:
	return _cooldown <= 0


## Check if a target is within weapon range.
func is_target_in_range(target: Node2D) -> bool:
	if not target or not _parent_unit:
		return false

	var distance = absf(target.global_position.x - _parent_unit.global_position.x)
	return distance <= range


## Fire at a target. Returns true if hit.
func fire(target: Node2D) -> bool:
	if not can_fire():
		return false

	if not target or not is_instance_valid(target):
		return false

	# Start cooldown
	_cooldown = 1.0 / fire_rate

	# Calculate positions
	var from_pos = _get_muzzle_position()
	var to_pos = _get_target_position(target)

	# Emit fired signal for FX
	fired.emit(from_pos, to_pos)

	# Check range
	if not is_target_in_range(target):
		print("[%s] Fired but target out of range" % [_parent_unit.name])
		return false

	# Apply damage (hitscan - instant hit)
	_apply_damage(target)

	return true


func _get_muzzle_position() -> Vector2:
	if not _parent_unit:
		return Vector2.ZERO

	var offset = muzzle_offset
	# Flip muzzle offset if facing left
	if "facing_direction" in _parent_unit and _parent_unit.facing_direction < 0:
		offset.x = -offset.x

	return _parent_unit.global_position + offset


func _get_target_position(target: Node2D) -> Vector2:
	# Aim at target center mass
	return target.global_position + Vector2(0, -12)


func _apply_damage(target: Node2D) -> void:
	hit.emit(target, damage)

	# Try HealthComponent first
	var health_comp = target.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.take_damage(damage)
		return

	# Fallback: call take_damage on target directly
	if target.has_method("take_damage"):
		target.take_damage(damage)
		return

	# Last resort: modify hp property directly
	if "current_hp" in target:
		target.current_hp -= damage

	print("[%s] Hit %s for %.1f damage" % [_parent_unit.name, target.name, damage])


## Get remaining cooldown time.
func get_cooldown() -> float:
	return maxf(0.0, _cooldown)


## Get cooldown progress (0.0 = ready, 1.0 = just fired).
func get_cooldown_percent() -> float:
	var cooldown_duration = 1.0 / fire_rate
	return clampf(_cooldown / cooldown_duration, 0.0, 1.0)


## Reset cooldown (ready to fire immediately).
func reset_cooldown() -> void:
	_cooldown = 0.0
