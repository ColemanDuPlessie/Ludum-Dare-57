extends Node2D

signal spawned_drill(player)

@export var world: Node2D
@export var pathfinding: Node
@export var walls: Node

var state = "building"
var current_player: CharacterBody2D = null

var player_drill_scene: PackedScene = ResourceLoader.load("res://scenes/player_drill.tscn")
var player_scene: PackedScene = ResourceLoader.load("res://scenes/player.tscn")
var enemy_scene: PackedScene = ResourceLoader.load("res://scenes/enemy.tscn")

func _ready():
	Static.game_manager = self
	
	start_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_swap_mode"):
		if state == "building":
			begin_combat()
		else:
			begin_building()

func start_game():
	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = Vector2.ONE * 8
	world.add_child(new_player)
	current_player = new_player

	spawned_drill.emit(new_player)

	Static.gold_counter = 15
	Static.gems_counter = 1
	Static.health = 3

	walls.generate_start()

func end_game():
	current_player.queue_free()

	start_game()

func spawn_enemy(scene: PackedScene) -> void:
	var spawn_location = pathfinding.get_enemy_spawn_location()

	var world_spawn_location = Vector2(spawn_location.x - Static.GAME_WIDTH / 2.0, spawn_location.y) * 16 + Vector2.ONE * 8
			
	var enemy: Node2D = enemy_scene.instantiate()
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

	if len(pathfinding.spawn_locations) > 0:
		spawn_enemy(enemy_scene)

func begin_building():
	print("Starting building!")

	state = "building"

	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = floor(current_player.global_position / 16) * 16 + Vector2.ONE * 8
	world.add_child(new_player)
	current_player.queue_free()
	current_player = new_player

	spawned_drill.emit(new_player)

func take_damage():
	Static.health -= 1

	if Static.health <= 0:
		end_game()