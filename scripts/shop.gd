extends Control

var player_drill: CharacterBody2D

var current_fuel_level = 1

const MAX_FUEL_LEVEL = 5
const FUEL_UPGRADE_COSTS = [5, 10, 15, 25]
const FUEL_UPGRADE_VALUES = [10, 20, 40, 60]

func _on_drill_spawned(player):
	player_drill = player

func _on_fuel_upgrade_pressed() -> void:
	if current_fuel_level >= MAX_FUEL_LEVEL:
		return
	if Static.spend_gold(FUEL_UPGRADE_COSTS[current_fuel_level-1]):
		player_drill.fuel_remaining += FUEL_UPGRADE_VALUES[current_fuel_level-1]
		player_drill.MAX_FUEL += FUEL_UPGRADE_VALUES[current_fuel_level-1]
		current_fuel_level += 1
		player_drill.update_fuel_gague()
		# TODO change button graphics...
