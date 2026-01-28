class_name UnitBase
extends CharacterBody2D

## Base class for all combat units. Handles state machine, HP, and component coordination.

signal died(unit: UnitBase)
signal state_changed(old_state: State, new_state: State)

enum State {
	IDLE,
	ADVANCING,
	ATTACKING,
	DYING,
	DEAD
}

enum Team {
	TEAM_A,
	TEAM_B
}

@export var team: Team = Team.TEAM_A
@export var max_hp: float = 100.0
@export var facing_direction: int = 1  # 1 = right, -1 = left
@export var body_persist_time: float = 2.0  # How long body stays after death

var current_hp: float
var current_state: State = State.IDLE
var current_target: UnitBase = null

# Component references (set by child scenes or in _ready)
var health_component: Node = null
var movement_component: Node = null
var targeting_component: Node = null
var weapon_component: Node = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _death_timer: float = 0.0
var _is_fading: bool = false


func _ready() -> void:
	current_hp = max_hp
	_setup_components()
	_connect_signals()

	# Flip sprite based on facing direction
	if sprite:
		sprite.flip_h = (facing_direction < 0)


func _setup_components() -> void:
	# Find components by class name if not manually assigned
	for child in get_children():
		if child is HealthComponent and not health_component:
			health_component = child
		elif child is MovementComponent and not movement_component:
			movement_component = child
		elif child is TargetingComponent and not targeting_component:
			targeting_component = child
		elif child is WeaponComponent and not weapon_component:
			weapon_component = child
		elif child is TeamComponent:
			# Sync team and facing direction from TeamComponent
			var team_comp = child as TeamComponent
			team_comp.team = team
			facing_direction = team_comp.get_facing_direction()
			# Update sprite flip after getting facing direction
			if sprite:
				sprite.flip_h = (facing_direction < 0)


func _connect_signals() -> void:
	if health_component and health_component.has_signal("health_depleted"):
		health_component.health_depleted.connect(_on_health_depleted)

	if targeting_component and targeting_component.has_signal("target_acquired"):
		targeting_component.target_acquired.connect(_on_target_acquired)
		targeting_component.target_lost.connect(_on_target_lost)

	# Connect to sprite animation finished for death handling
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.ADVANCING:
			_process_advancing(delta)
		State.ATTACKING:
			_process_attacking(delta)
		State.DYING:
			_process_dying(delta)
		State.DEAD:
			_process_dead(delta)


func _process_idle(_delta: float) -> void:
	# Wait for start_battle() to be called
	pass


func _process_advancing(_delta: float) -> void:
	# Keep moving forward
	if movement_component:
		movement_component.move_forward(facing_direction)

	# Check if we have a target in range
	if current_target and weapon_component:
		if weapon_component.is_target_in_range(current_target):
			change_state(State.ATTACKING)


func _process_attacking(_delta: float) -> void:
	# Stop moving while attacking
	if movement_component:
		movement_component.stop()

	# Verify target is still valid
	if not _is_target_valid():
		current_target = null
		# Try to get a new target from targeting component
		if targeting_component and targeting_component.has_target():
			current_target = targeting_component.current_target

		if not current_target:
			change_state(State.ADVANCING)
			return

	# Check if target moved out of range - resume advancing to chase
	if weapon_component and not weapon_component.is_target_in_range(current_target):
		change_state(State.ADVANCING)
		return

	# Fire weapon when ready
	if weapon_component and weapon_component.can_fire():
		weapon_component.fire(current_target)


func _process_dying(_delta: float) -> void:
	# Dying state waits for animation_finished signal
	pass


func _process_dead(delta: float) -> void:
	# Fade out over time
	if _is_fading:
		_death_timer += delta
		var fade_progress = _death_timer / body_persist_time
		if sprite:
			sprite.modulate.a = 1.0 - fade_progress

		if _death_timer >= body_persist_time:
			queue_free()


func _is_target_valid() -> bool:
	if not current_target:
		return false
	if not is_instance_valid(current_target):
		return false
	if not current_target.is_alive():
		return false
	return true


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	_on_state_exit(old_state)
	_on_state_enter(new_state)
	state_changed.emit(old_state, new_state)

	print("[%s] State: %s -> %s" % [name, State.keys()[old_state], State.keys()[new_state]])


func _on_state_exit(state: State) -> void:
	match state:
		State.ATTACKING:
			# Could add exit logic here if needed
			pass


func _on_state_enter(state: State) -> void:
	match state:
		State.IDLE:
			_play_animation("idle_gun")
			if movement_component:
				movement_component.stop()
		State.ADVANCING:
			_play_animation("run_gun")
		State.ATTACKING:
			_play_animation("shoot")
		State.DYING:
			_play_animation("die")
			# Shift sprite down so death animation body rests on ground
			if sprite:
				sprite.position.y = -8.0
			if movement_component:
				movement_component.halt()  # Immediate stop
			# Disable targeting while dying
			if targeting_component:
				targeting_component.set_process(false)
		State.DEAD:
			_on_death()


func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


func _on_animation_finished() -> void:
	if current_state == State.DYING:
		change_state(State.DEAD)


func _on_health_depleted() -> void:
	if current_state != State.DYING and current_state != State.DEAD:
		change_state(State.DYING)


func _on_target_acquired(target: Node2D) -> void:
	current_target = target as UnitBase


func _on_target_lost() -> void:
	current_target = null
	if current_state == State.ATTACKING:
		change_state(State.ADVANCING)


func _on_death() -> void:
	died.emit(self)

	# Disable collision (layer 2 is units)
	collision_layer = 0
	collision_mask = 0

	# Start fade out
	_is_fading = true
	_death_timer = 0.0


## Called by BattleController to start the unit
func start_battle() -> void:
	if current_state == State.IDLE:
		change_state(State.ADVANCING)


## Apply damage to this unit
func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)
	else:
		# Fallback if no health component
		current_hp -= amount
		if current_hp <= 0:
			_on_health_depleted()


## Check if this unit is an enemy of another unit
func is_enemy_of(other: UnitBase) -> bool:
	return other != null and other.team != team


## Check if this unit is alive (not dying or dead)
func is_alive() -> bool:
	return current_state != State.DYING and current_state != State.DEAD
