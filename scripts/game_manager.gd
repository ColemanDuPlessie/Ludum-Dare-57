extends Node2D

signal spawned_drill(player)

@export var world: Node2D
@export var pathfinding: Node
@export var walls: Node

var state = "building"
var current_player: CharacterBody2D = null

var player_drill_scene: PackedScene = ResourceLoader.load("res://scenes/player_drill.tscn")
var player_scene: PackedScene = ResourceLoader.load("res://scenes/player.tscn")
var bat_scene: PackedScene = ResourceLoader.load("res://scenes/enemies/bat.tscn")
var goblin_scene: PackedScene = ResourceLoader.load("res://scenes/enemies/goblin.tscn")

var enemies = [bat_scene, goblin_scene]

@onready var start_menu = get_node("../World/StartMenu") 
@onready var drill_menu = get_node("../Camera2D/UIOverlay/DrillUI") 
@onready var resource_menu = get_node("../Camera2D/UIOverlay/ResourceUI") 
@onready var round_announcement = get_node("../Camera2D/UIOverlay/RoundAnouncement") 

var GRID_ALIGNED = {bat_scene : false, goblin_scene : true}

var waves = [[bat_scene],
			[bat_scene, bat_scene],
			[bat_scene, bat_scene, bat_scene, bat_scene],
			[goblin_scene,],
			[bat_scene, goblin_scene],
			[bat_scene, bat_scene, bat_scene, bat_scene, bat_scene, bat_scene, bat_scene, bat_scene],
			[bat_scene, bat_scene, goblin_scene, bat_scene, bat_scene, goblin_scene]]

func _ready():
	Static.game_manager = self

	walls.generate_start()

func _input(event: InputEvent) -> void:
	if !Static.game_in_progress && event is InputEventKey:
		start_game()

	if event.is_action_pressed("debug_swap_mode"):
		if state == "building":
			begin_combat()
		else:
			begin_building()

func start_game():
	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	state = "building"
	new_player.global_position = Vector2.ONE * 8
	world.add_child(new_player)
	current_player = new_player

	spawned_drill.emit(new_player)

	Static.current_gold = 0
	Static.increment_gold(500)
	Static.current_gems = 0
	Static.increment_gems(500)
	Static.health = 3

	Static.game_in_progress = true

	walls.generate_start()
	new_player.update_fuel_gague()

	start_menu.fade_out()
	drill_menu.enable()
	resource_menu.enable()

	Static.round_number = 1

func end_game():
	current_player.queue_free()
	
	for i in Static.all_enemies.duplicate():
		i.destroy()

	Static.all_enemies = []

	for i in Static.all_tower_locations.values():
		i.destroy()

	Static.all_tower_locations = {}

	Static.game_in_progress = false

	start_menu.fade_in()
	drill_menu.disable()
	resource_menu.disable()
	Static.MAX_FUEL = 40
	Static.PLAYER_DRILL_LEVEL = 0
	Static.PLAYER_GUN_LEVEL = 0
	Static.PLAYER_RADAR_LEVEL = 0

func spawn_enemy(type) -> void:
	var spawn_location = pathfinding.get_enemy_spawn_location()

	var world_spawn_location = Vector2(spawn_location.x - Static.GAME_WIDTH / 2.0, spawn_location.y) * 16 + Vector2.ONE * 8
	if not GRID_ALIGNED[type]:
		world_spawn_location += Vector2(randf_range(-4, 4), randf_range(-4, 4))
			
	var enemy: Node2D = type.instantiate()
	enemy.pathfinding = pathfinding
	enemy.global_position = world_spawn_location
	
	world.add_child(enemy)
	
	Static.all_enemies.append(enemy)

func begin_combat():
	print("Starting combat!")

	state = "combat"

	var new_player: CharacterBody2D = player_scene.instantiate()
	new_player.global_position = current_player.global_position
	world.add_child(new_player)

	current_player.queue_free()
	current_player = new_player

	pathfinding.calc_pathing()
	
	if Static.round_number > len(waves): # Use hand-curated waves if possible, but then switch to an exponentially-escalating endless mode eventually
		for i in range(Static.round_number ** 1.5):
			spawn_enemy(enemies.pick_random())
	else:
		for enemy in waves[Static.round_number-1]: # TODO spawn enemies over time, not all at once.
			spawn_enemy(enemy)

	round_announcement.announce()

func begin_building():
	print("Starting building!")

	state = "building"

	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = floor(current_player.global_position / 16) * 16 + Vector2.ONE * 8
	world.add_child(new_player)
	current_player.queue_free()
	current_player = new_player

	spawned_drill.emit(new_player)
	new_player.update_fuel_gague()

	Static.round_number += 1

func take_damage():
	Static.health -= 1

	if Static.health <= 0:
		end_game()

	Static.camera.shake(2)
