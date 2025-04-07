extends Node2D

var player_drill: CharacterBody2D

var current_fuel_level = 1

const MAX_FUEL_LEVEL = 5
const FUEL_UPGRADE_COSTS = [5, 9, 12, 15]
const FUEL_UPGRADE_VALUES = [20, 30, 35, 45]

const MAX_WEAPON_LEVEL = 3
const WEAPON_UPGRADE_COSTS = [5, 10, 15]

const MAX_RADAR_LEVEL = 4
const RADAR_UPGRADE_COSTS = [3, 7, 12, 18]

const MAX_DRILL_LEVEL = 4
const DRILL_UPGRADE_COSTS = [4, 5, 9, 11]

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
		
		var fuel_price = get_node("Mechanic/UIOrigin/UI/FuelTank/Price")
		var fuel_label = get_node("Mechanic/UIOrigin/UI/FuelTank/Label")
		if current_fuel_level >= MAX_FUEL_LEVEL:
			var coin = get_node("Mechanic/UIOrigin/UI/FuelTank/TextureRect")
			fuel_price.visible = false
			coin.visible = false
			fuel_label.text = "FUELTANK MAX"
		else:
			fuel_price.text = str(FUEL_UPGRADE_COSTS[current_fuel_level-1])
			# fuel_label.text = "FUELTANK " + str(current_fuel_level)

func _on_weapon_upgrade_pressed() -> void:
	if Static.PLAYER_GUN_LEVEL >= MAX_WEAPON_LEVEL:
		return
	if Static.spend_gems(WEAPON_UPGRADE_COSTS[Static.PLAYER_GUN_LEVEL]):
		Static.PLAYER_GUN_LEVEL += 1
		
		var weapon_price = get_node("Mechanic/UIOrigin/UI/Weapon/Price")
		var weapon_label = get_node("Mechanic/UIOrigin/UI/Weapon/Label")
		if Static.PLAYER_GUN_LEVEL >= MAX_WEAPON_LEVEL:
			var coin = get_node("Mechanic/UIOrigin/UI/Weapon/TextureRect")
			weapon_price.visible = false
			coin.visible = false
			weapon_label.text = "WEAPON MAX"
		else:
			weapon_price.text = str(WEAPON_UPGRADE_COSTS[Static.PLAYER_GUN_LEVEL])
			# weapon_label.text = "WEAPON " + str(Static.PLAYER_GUN_LEVEL+1)

func _on_radar_upgrade_pressed() -> void:
	if Static.PLAYER_RADAR_LEVEL >= MAX_RADAR_LEVEL:
		return
	if Static.spend_gems(RADAR_UPGRADE_COSTS[Static.PLAYER_RADAR_LEVEL]):
		Static.PLAYER_RADAR_LEVEL += 1
		player_drill.update_radar_power()
		
		var radar_price = get_node("Researcher/UIOrigin/UI/Radar/Price")
		var radar_label = get_node("Researcher/UIOrigin/UI/Radar/Label")
		if Static.PLAYER_RADAR_LEVEL >= MAX_RADAR_LEVEL:
			var coin = get_node("Researcher/UIOrigin/UI/Radar/TextureRect")
			radar_price.visible = false
			coin.visible = false
			radar_label.text = "RADAR MAX"
		else:
			radar_price.text = str(RADAR_UPGRADE_COSTS[Static.PLAYER_RADAR_LEVEL])
			# radar_label.text = "RADAR " + str(Static.PLAYER_RADAR_LEVEL+1)

func _on_drill_upgrade_pressed() -> void:
	if Static.PLAYER_DRILL_LEVEL >= MAX_DRILL_LEVEL:
		return
	if Static.spend_gems(DRILL_UPGRADE_COSTS[Static.PLAYER_DRILL_LEVEL]):
		Static.PLAYER_DRILL_LEVEL += 1
		
		var drill_price = get_node("Researcher/UIOrigin/UI/Drill/Price")
		var drill_label = get_node("Researcher/UIOrigin/UI/Drill/Label")
		if Static.PLAYER_DRILL_LEVEL >= MAX_DRILL_LEVEL:
			var coin = get_node("Researcher/UIOrigin/UI/Drill/TextureRect")
			drill_price.visible = false
			coin.visible = false
			drill_label.text = "DRILL MAX"
		else:
			drill_price.text = str(DRILL_UPGRADE_COSTS[Static.PLAYER_DRILL_LEVEL])
			# drill_label.text = "DRILL " + str(Static.PLAYER_DRILL_LEVEL+1)

func reset_labels() -> void:
	var drill_price = get_node("Researcher/UIOrigin/UI/Drill/Price")
	var drill_label = get_node("Researcher/UIOrigin/UI/Drill/Label")
	drill_label.text = "DRILL"
	drill_price.text = str(DRILL_UPGRADE_COSTS[0])
	var radar_price = get_node("Researcher/UIOrigin/UI/Radar/Price")
	var radar_label = get_node("Researcher/UIOrigin/UI/Radar/Label")
	radar_label.text = "RADAR"
	radar_price.text = str(RADAR_UPGRADE_COSTS[0])
	var weapon_price = get_node("Mechanic/UIOrigin/UI/Weapon/Price")
	var weapon_label = get_node("Mechanic/UIOrigin/UI/Weapon/Label")
	weapon_label.text = "WEAPON"
	weapon_price.text = str(WEAPON_UPGRADE_COSTS[0])
	var fuel_price = get_node("Mechanic/UIOrigin/UI/FuelTank/Price")
	var fuel_label = get_node("Mechanic/UIOrigin/UI/FuelTank/Label")
	fuel_label.text = "FUELTANK"
	fuel_price.text = str(FUEL_UPGRADE_COSTS[0])
