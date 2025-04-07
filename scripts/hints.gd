extends Node

var moves = 0
var shots = 0

var passed_move = false
var passed_build = false
var passed_return = false
var passed_start = false
var passed_shoot = false
var passed_defend = false
var passed_deep = false

func _ready() -> void:
	Static.game_manager.spawned_drill.connect(_on_drill_spawned)
	Static.game_manager.spawned_combat.connect(_on_combat_spawned)
	Static.tower_menu.built_tower.connect(_on_built_tower)
	Static.game_manager.completed_round.connect(_on_completed_room)

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)

func _on_combat_spawned(player):
	player.shot.connect(_on_player_shot)

	passed_start = true

	advance_to_next_hint()
	
func _on_player_moving_to_tile(location):
	moves += 1

	if moves > 3:
		passed_move = true

		advance_to_next_hint()

	if passed_build && location.y <= 8:
		passed_return = true

		advance_to_next_hint()

	if passed_defend && location.y >= 8 + 16 * 7:
		passed_deep = true

		advance_to_next_hint()

func _on_built_tower():
	passed_build = true

	advance_to_next_hint()

func _on_player_shot():
	shots += 1

	if shots > 3:
		passed_shoot = true

		advance_to_next_hint()

func _on_completed_room():
	passed_defend = true

	advance_to_next_hint()

func advance_to_next_hint():
	if passed_move:
		Static.currently_displayed_hint = "build"

	if passed_build:
		Static.currently_displayed_hint = "return"

	if passed_return:
		Static.currently_displayed_hint = "start"

	if passed_start:
		Static.currently_displayed_hint = "shoot"

	if passed_shoot:
		Static.currently_displayed_hint = "defend"

	if passed_defend:
		Static.currently_displayed_hint = "deep"

	if passed_deep:
		if !passed_shoot:
			Static.currently_displayed_hint = "shoot"
		else:
			Static.currently_displayed_hint = "none"