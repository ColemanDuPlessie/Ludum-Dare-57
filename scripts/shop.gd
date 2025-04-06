extends Node2D

var player_drill: CharacterBody2D

var current_fuel_level = 1

const MAX_FUEL_LEVEL = 5
const FUEL_UPGRADE_COSTS = [5, 10, 15, 25]
const FUEL_UPGRADE_VALUES = [25, 30, 35, 40]

const MAX_WEAPON_LEVEL = 3
const WEAPON_UPGRADE_COSTS = [5, 10, 15]

const MAX_RADAR_LEVEL = 4
const RADAR_UPGRADE_COSTS = [3, 7, 12, 18]

func _ready():
	Static.shop = self
	
func _on_drill_spawned(player):
	player_drill = player

func _on_fuel_upgrade_pressed() -> void:
	if current_fuel_level >= MAX_FUEL_LEVEL:
		return
	if Static.spend_gold(FUEL_UPGRADE_COSTS[current_fuel_level-1]):
		player_drill.fuel_remaining += FUEL_UPGRADE_VALUES[current_fuel_level-1]
		Static.MAX_FUEL += FUEL_UPGRADE_VALUES[current_fuel_level-1]
		current_fuel_level += 1
		player_drill.update_fuel_gague()
		# TODO change button graphics...

func _on_weapon_upgrade_pressed() -> void:
	if Static.PLAYER_GUN_LEVEL >= MAX_WEAPON_LEVEL:
		return
	if Static.spend_gems(WEAPON_UPGRADE_COSTS[Static.PLAYER_GUN_LEVEL]):
		Static.PLAYER_GUN_LEVEL += 1
		# TODO change button graphics...

func _on_radar_upgrade_pressed() -> void:
	if Static.PLAYER_RADAR_LEVEL >= MAX_RADAR_LEVEL:
		return
	if Static.spend_gems(RADAR_UPGRADE_COSTS[Static.PLAYER_RADAR_LEVEL]):
		Static.PLAYER_RADAR_LEVEL += 1
		player_drill.update_radar_power()
		# TODO change button graphics...
