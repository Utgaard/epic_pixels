class_name TargetingComponent
extends Node

## Periodically scans for enemies and tracks the nearest valid target.

signal target_acquired(target: Node2D)
signal target_lost

@export var scan_interval: float = 0.3  ## Time between target scans
@export var max_range: float = 400.0    ## Maximum targeting range (0 = unlimited)

var current_target: Node2D = null
var _scan_timer: float = 0.0
var _parent_unit: Node2D = null
var _units_container: Node = null


func _ready() -> void:
	_parent_unit = get_parent() as Node2D

	# Find the Units container in the scene
	await get_tree().process_frame
	_find_units_container()


func _find_units_container() -> void:
	# Look for SimRoot/Units in the scene tree
	var root = get_tree().current_scene
	if root:
		_units_container = root.get_node_or_null("SimRoot/Units")
		if not _units_container:
			push_warning("[TargetingComponent] Could not find SimRoot/Units container")


func _process(delta: float) -> void:
	_scan_timer += delta

	if _scan_timer >= scan_interval:
		_scan_timer = 0.0
		_scan_for_targets()

	# Validate current target is still valid
	if current_target and not _is_valid_target(current_target):
		_lose_target()


func _scan_for_targets() -> void:
	if not _parent_unit or not _units_container:
		return

	var best_target: Node2D = null
	var best_distance: float = INF

	for unit in _units_container.get_children():
		if not _is_valid_target(unit):
			continue

		var distance = _get_distance_to(unit)

		# Check range limit
		if max_range > 0 and distance > max_range:
			continue

		if distance < best_distance:
			best_distance = distance
			best_target = unit

	# Update target if changed
	if best_target != current_target:
		if best_target:
			_acquire_target(best_target)
		elif current_target:
			_lose_target()


func _is_valid_target(unit: Node) -> bool:
	if unit == null or unit == _parent_unit:
		return false

	if not is_instance_valid(unit):
		return false

	# Check if unit is alive
	if "is_alive" in unit and not unit.is_alive():
		return false

	# Check if unit has a state and is not dead/dying
	if "current_state" in unit:
		var state = unit.current_state
		# Assuming State enum: DYING = 3, DEAD = 4
		if state >= 3:
			return false

	# Check if enemy
	if not _is_enemy(unit):
		return false

	return true


func _is_enemy(unit: Node) -> bool:
	# Check via TeamComponent on parent
	var my_team_comp = _parent_unit.get_node_or_null("TeamComponent") as TeamComponent
	if my_team_comp:
		return my_team_comp.is_enemy_unit(unit)

	# Fallback: check team property directly
	if "team" in _parent_unit and "team" in unit:
		return _parent_unit.team != unit.team

	return false


func _get_distance_to(unit: Node2D) -> float:
	return absf(unit.global_position.x - _parent_unit.global_position.x)


func _acquire_target(target: Node2D) -> void:
	current_target = target
	target_acquired.emit(target)
	print("[%s] Target acquired: %s" % [_parent_unit.name, target.name])


func _lose_target() -> void:
	var old_target = current_target
	current_target = null
	target_lost.emit()
	if old_target:
		print("[%s] Target lost: %s" % [_parent_unit.name, old_target.name if is_instance_valid(old_target) else "invalid"])


## Force an immediate target scan.
func scan_now() -> void:
	_scan_timer = 0.0
	_scan_for_targets()


## Check if we have a valid target.
func has_target() -> bool:
	return current_target != null and _is_valid_target(current_target)


## Get distance to current target, or INF if no target.
func get_target_distance() -> float:
	if current_target and is_instance_valid(current_target):
		return _get_distance_to(current_target)
	return INF


## Clear current target.
func clear_target() -> void:
	if current_target:
		_lose_target()
