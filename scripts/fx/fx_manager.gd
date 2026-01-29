extends Node

## Spawns FX in response to combat events. Single entry point for all visual effects.

const MuzzleFlashScene = preload("res://scenes/fx/muzzle_flash.tscn")
const HitSparkScene = preload("res://scenes/fx/hit_spark.tscn")
const TracerScene = preload("res://scenes/fx/tracer.tscn")

var _fx_container: Node2D = null
var _combat_events: Node = null


func _ready() -> void:
	# Find FX container in scene
	var root = get_tree().current_scene
	if root:
		_fx_container = root.get_node_or_null("RenderRoot/FX")
		if not _fx_container:
			push_warning("[FXManager] Could not find RenderRoot/FX container")
		else:
			print("[FXManager] Found FX container: %s" % _fx_container.get_path())


## Connect to a CombatEventBus to auto-spawn FX.
func connect_to_combat_events(events: Node) -> void:
	_combat_events = events
	events.weapon_fired.connect(_on_weapon_fired)
	events.target_hit.connect(_on_target_hit)
	events.unit_died.connect(_on_unit_died)


func _on_weapon_fired(from_pos: Vector2, to_pos: Vector2, shooter: Node2D) -> void:
	print("[FXManager] Weapon fired from %s to %s by %s" % [from_pos, to_pos, shooter.name if shooter else "null"])
	spawn_muzzle_flash(from_pos, shooter)
	spawn_tracer(from_pos, to_pos)


func _on_target_hit(_target: Node2D, _damage: float, hit_pos: Vector2) -> void:
	spawn_hit_spark(hit_pos)


func _on_unit_died(unit: Node2D, death_pos: Vector2) -> void:
	# Could spawn death FX here
	pass


## Spawn a tracer line from shooter to target.
func spawn_tracer(from_pos: Vector2, to_pos: Vector2) -> void:
	if not _fx_container:
		return

	var tracer = TracerScene.instantiate()
	_fx_container.add_child(tracer)
	tracer.set_endpoints(from_pos, to_pos)


## Spawn a hit spark at the given position.
func spawn_hit_spark(pos: Vector2) -> void:
	if not _fx_container:
		push_warning("[FXManager] No FX container for hit spark")
		return

	var spark = HitSparkScene.instantiate()
	_fx_container.add_child(spark)
	spark.global_position = pos + Vector2(randf_range(-4, 4), randf_range(-4, 4))


## Spawn a muzzle flash at the given position.
func spawn_muzzle_flash(pos: Vector2, shooter: Node2D = null) -> void:
	if not _fx_container:
		return

	var flash = MuzzleFlashScene.instantiate()

	# Flip to match shooter direction
	if shooter and "facing_direction" in shooter:
		flash.flip_h = (shooter.facing_direction < 0)

	_fx_container.add_child(flash)
	flash.global_position = pos
