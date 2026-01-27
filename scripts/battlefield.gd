extends Node2D

## Main battlefield scene script. Initializes and starts the battle.

@onready var battle_controller: BattleController = $BattleController
@onready var camera_rig: CameraRig = $CameraRig

@export var team_a_infantry_count: int = 1
@export var team_b_infantry_count: int = 1
@export var start_delay: float = 0.5  ## Delay before battle starts


func _ready() -> void:
	# Connect battle events
	battle_controller.battle_ended.connect(_on_battle_ended)

	# Connect camera shake to combat events
	battle_controller.ready.connect(_connect_camera_shake, CONNECT_ONE_SHOT | CONNECT_DEFERRED)

	# Start the battle sequence
	_start_sequence()


func _connect_camera_shake() -> void:
	if battle_controller.combat_events and camera_rig:
		battle_controller.combat_events.weapon_fired.connect(
			func(_from: Vector2, _to: Vector2, _shooter: Node2D):
				camera_rig.add_trauma(0.05)
		)
		battle_controller.combat_events.unit_died.connect(
			func(_unit: Node2D, _pos: Vector2):
				camera_rig.add_trauma(0.2)
		)


func _start_sequence() -> void:
	print("[Battlefield] Initializing battle...")

	# Spawn units
	for i in team_a_infantry_count:
		battle_controller.spawn_infantry(UnitBase.Team.TEAM_A)

	for i in team_b_infantry_count:
		battle_controller.spawn_infantry(UnitBase.Team.TEAM_B)

	# Brief delay before starting
	await get_tree().create_timer(start_delay).timeout

	# Begin battle
	battle_controller.start_battle()


func _on_battle_ended(winning_team: int) -> void:
	var team_name = UnitBase.Team.keys()[winning_team]
	print("[Battlefield] === %s WINS! ===" % team_name)
