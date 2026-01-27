class_name HealthComponent
extends Node

## Tracks unit health and emits signals when damaged or depleted.

signal health_changed(current: float, max_hp: float)
signal damage_taken(amount: float, current: float)
signal health_depleted

@export var max_hp: float = 100.0

var current_hp: float


func _ready() -> void:
	current_hp = max_hp


## Apply damage to this component. Returns actual damage dealt.
func take_damage(amount: float) -> float:
	if current_hp <= 0:
		return 0.0

	var actual_damage = minf(amount, current_hp)
	current_hp -= actual_damage

	damage_taken.emit(actual_damage, current_hp)
	health_changed.emit(current_hp, max_hp)

	print("[%s] Took %.1f damage, HP: %.1f/%.1f" % [get_parent().name, actual_damage, current_hp, max_hp])

	if current_hp <= 0:
		current_hp = 0
		health_depleted.emit()

	return actual_damage


## Heal this component. Returns actual amount healed.
func heal(amount: float) -> float:
	if current_hp <= 0:
		return 0.0

	var actual_heal = minf(amount, max_hp - current_hp)
	current_hp += actual_heal

	if actual_heal > 0:
		health_changed.emit(current_hp, max_hp)

	return actual_heal


## Set health to a specific value (clamped to 0-max_hp).
func set_health(value: float) -> void:
	current_hp = clampf(value, 0.0, max_hp)
	health_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		health_depleted.emit()


## Get current health as a percentage (0.0 - 1.0).
func get_health_percent() -> float:
	return current_hp / max_hp if max_hp > 0 else 0.0


## Check if still alive (HP > 0).
func is_alive() -> bool:
	return current_hp > 0


## Reset health to max.
func reset() -> void:
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
