class_name TeamComponent
extends Node

## Stores team affiliation and provides team-related utilities.

enum Team {
	TEAM_A,
	TEAM_B
}

@export var team: Team = Team.TEAM_A

## Color tint for Team A (default, no tint)
@export var team_a_color: Color = Color.WHITE

## Color tint for Team B (reddish tint to distinguish)
@export var team_b_color: Color = Color(1.0, 0.7, 0.7, 1.0)

var _sprite: CanvasItem = null


func _ready() -> void:
	_find_and_tint_sprite()


func _find_and_tint_sprite() -> void:
	# Find the sprite in parent unit
	var parent = get_parent()
	if parent:
		_sprite = parent.get_node_or_null("AnimatedSprite2D")
		if not _sprite:
			_sprite = parent.get_node_or_null("Sprite2D")

	apply_team_color()


## Apply team color tint to the sprite.
func apply_team_color() -> void:
	if _sprite:
		_sprite.modulate = get_team_color()


## Get the color for the current team.
func get_team_color() -> Color:
	match team:
		Team.TEAM_A:
			return team_a_color
		Team.TEAM_B:
			return team_b_color
	return Color.WHITE


## Check if another team is an enemy.
func is_enemy(other_team: Team) -> bool:
	return other_team != team


## Check if another TeamComponent belongs to an enemy.
func is_enemy_of(other: TeamComponent) -> bool:
	return other != null and other.team != team


## Check if a unit is an enemy (expects unit to have team property or TeamComponent).
func is_enemy_unit(unit: Node) -> bool:
	if unit == null:
		return false

	# Check for TeamComponent first
	var other_team_comp = unit.get_node_or_null("TeamComponent") as TeamComponent
	if other_team_comp:
		return is_enemy_of(other_team_comp)

	# Fallback: check for team property on unit
	if "team" in unit:
		return unit.team != team

	return false


## Set team and update visuals.
func set_team(new_team: Team) -> void:
	team = new_team
	apply_team_color()


## Get facing direction based on team (Team A faces right, Team B faces left).
func get_facing_direction() -> int:
	return 1 if team == Team.TEAM_A else -1
