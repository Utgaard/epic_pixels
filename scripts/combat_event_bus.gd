extends Node

## Central hub for combat events. Bridges weapons → FX system.
## Added as a child of BattleController and wired to all units.

signal weapon_fired(from_pos: Vector2, to_pos: Vector2, shooter: Node2D)
signal target_hit(target: Node2D, damage: float, hit_pos: Vector2)
signal unit_died(unit: Node2D, death_pos: Vector2)

var _tracked_units: Array[Node2D] = []


## Register a unit to listen for its combat events.
func register_unit(unit: Node2D) -> void:
	if unit in _tracked_units:
		return

	_tracked_units.append(unit)

	# Connect weapon signals
	var weapon = unit.get("weapon_component")
	if weapon:
		weapon.fired.connect(
			func(from_pos: Vector2, to_pos: Vector2):
				weapon_fired.emit(from_pos, to_pos, unit)
		)
		weapon.hit.connect(
			func(target: Node2D, damage: float):
				var hit_pos = target.global_position + Vector2(0, -12)
				target_hit.emit(target, damage, hit_pos)
		)

	# Connect death signal
	if unit.has_signal("died"):
		unit.died.connect(
			func(u: Node2D):
				unit_died.emit(u, u.global_position)
				_tracked_units.erase(u)
		)


## Unregister a unit (called automatically on death).
func unregister_unit(unit: Node2D) -> void:
	_tracked_units.erase(unit)
