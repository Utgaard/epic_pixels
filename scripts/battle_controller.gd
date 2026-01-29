class_name BattleController
extends Node

## Orchestrates battle flow: spawning, tracking units, and win conditions.

signal battle_started
signal battle_ended(winning_team: int)

const InfantryScene = preload("res://scenes/units/infantry.tscn")
const CombatEventBusScript = preload("res://scripts/combat_event_bus.gd")
const FXManagerScript = preload("res://scripts/fx/fx_manager.gd")
const AudioManagerScript = preload("res://scripts/audio/audio_manager.gd")

@export var units_node_path: NodePath
@export var projectiles_node_path: NodePath

var units_node: Node2D
var projectiles_node: Node2D

var combat_events: Node = null
var fx_manager: Node = null
var audio_manager: Node = null

var _battle_active: bool = false
var _units_team_a: Array = []
var _units_team_b: Array = []


func _ready() -> void:
	# Resolve node paths
	units_node = get_node(units_node_path) as Node2D
	projectiles_node = get_node_or_null(projectiles_node_path) as Node2D

	# Create the combat event bus
	combat_events = CombatEventBusScript.new()
	combat_events.name = "CombatEventBus"
	add_child(combat_events)

	# Create the FX manager
	fx_manager = FXManagerScript.new()
	fx_manager.name = "FXManager"
	add_child(fx_manager)

	# Create the audio manager
	audio_manager = AudioManagerScript.new()
	audio_manager.name = "AudioManager"
	add_child(audio_manager)

	# Wire FX and audio to combat events (_ready has already run after add_child)
	fx_manager.connect_to_combat_events(combat_events)
	audio_manager.connect_to_combat_events(combat_events)


func start_battle() -> void:
	_battle_active = true
	battle_started.emit()

	# Start all units
	for unit in _units_team_a + _units_team_b:
		unit.start_battle()

	print("[BattleController] Battle started - Team A: %d, Team B: %d" % [_units_team_a.size(), _units_team_b.size()])


func end_battle(winning_team: int) -> void:
	_battle_active = false
	battle_ended.emit(winning_team)
	print("[BattleController] Battle ended - Winner: %s" % UnitBase.Team.keys()[winning_team])


func is_battle_active() -> bool:
	return _battle_active


## Spawn an infantry unit for a given team.
func spawn_infantry(team: int) -> UnitBase:
	var unit = InfantryScene.instantiate() as UnitBase
	unit.team = team

	# Position based on team
	if team == UnitBase.Team.TEAM_A:
		unit.position = Vector2(Constants.SPAWN_LEFT_X, Constants.GROUND_Y)
		unit.name = "Infantry_A_%d" % (_units_team_a.size() + 1)
	else:
		unit.position = Vector2(Constants.SPAWN_RIGHT_X, Constants.GROUND_Y)
		unit.name = "Infantry_B_%d" % (_units_team_b.size() + 1)

	# Add to scene
	units_node.add_child(unit)

	# Track unit
	_track_unit(unit, team)

	# Register with combat event bus (unit's _ready has already run after add_child)
	combat_events.register_unit(unit)

	print("[BattleController] Spawned %s at %s" % [unit.name, unit.position])
	return unit


func _track_unit(unit: UnitBase, team: int) -> void:
	if team == UnitBase.Team.TEAM_A:
		_units_team_a.append(unit)
	else:
		_units_team_b.append(unit)

	# Listen for death to check win condition
	unit.died.connect(_on_unit_died)


func _on_unit_died(unit: UnitBase) -> void:
	_units_team_a.erase(unit)
	_units_team_b.erase(unit)

	print("[BattleController] Unit died: %s (A: %d, B: %d remaining)" % [unit.name, _units_team_a.size(), _units_team_b.size()])

	if not _battle_active:
		return

	# Check win conditions
	if _units_team_a.is_empty():
		end_battle(UnitBase.Team.TEAM_B)
	elif _units_team_b.is_empty():
		end_battle(UnitBase.Team.TEAM_A)
