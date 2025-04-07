extends Node2D

signal spawned_drill(player)
signal spawned_combat(player)
signal completed_round()

@export var world: Node2D
@export var pathfinding: Node
@export var walls: Node

var state = "building"
var current_player: CharacterBody2D = null

var player_drill_scene: PackedScene = ResourceLoader.load("res://scenes/player_drill.tscn")
var player_scene: PackedScene = ResourceLoader.load("res://scenes/player.tscn")
var bat: PackedScene = ResourceLoader.load("res://scenes/enemies/bat.tscn")
var goblin: PackedScene = ResourceLoader.load("res://scenes/enemies/goblin.tscn")
var fire_goblin: PackedScene = ResourceLoader.load("res://scenes/enemies/fire_goblin.tscn")

var enemies = [bat, bat, bat, goblin, goblin, fire_goblin]

@onready var start_menu = get_node("../World/StartMenu") 
@onready var drill_menu = get_node("../Camera2D/UIOverlay/DrillUI") 
@onready var resource_menu = get_node("../Camera2D/UIOverlay/ResourceUI") 
@onready var round_announcement = get_node("../Camera2D/UIOverlay/RoundAnouncement")
@onready var tower_range = get_node("../TowerTargeting")

var GRID_ALIGNED = {bat : false, goblin : true, fire_goblin : true}

var waves = [[0, [bat]],
			[3.0, [bat, bat, bat]],
			[1.0, [bat, goblin]],
			[2.0, [bat, bat, bat, bat, bat, bat, bat, bat]],
			[9.0, [bat, bat, goblin, bat, bat, goblin]],
			[6.0, [goblin, goblin, goblin, goblin]],
			[3.0, [bat, bat, bat, bat, fire_goblin]],
			[10.0, [bat, bat, bat, goblin, bat, bat, bat, goblin, bat, bat, bat, goblin, bat, bat, bat, fire_goblin]],
			[15.0, [goblin, fire_goblin, goblin, fire_goblin, goblin, fire_goblin]],
			[2.0, [fire_goblin, fire_goblin, fire_goblin]],
			[6.0, [bat, bat, goblin, bat, bat, goblin, bat, bat, goblin, bat, bat, fire_goblin, bat, bat, goblin, bat, bat, goblin, bat, bat, goblin, bat, bat, fire_goblin, bat, bat, goblin, bat, bat, goblin, bat, bat, goblin, bat, bat, fire_goblin]]]

var spawn_delayed = [] # Elements are of the form [seconds_until_spawn, unit_to_spawn]

func _ready():
	Static.game_manager = self

	walls.generate_start()

const START_SCREEN_COOLDOWN_TIME = 1.0
var time_to_start = 0

func _process(delta):
	if time_to_start > 0:
		time_to_start = max(0, time_to_start-delta)
		
	var to_remove = []
	for spawn in spawn_delayed:
		spawn[0] -= delta
		if spawn[0] <= 0:
			to_remove.append(spawn)
			spawn_enemy(spawn[1])
	for t in to_remove:
		spawn_delayed.erase(t)

func _input(event: InputEvent) -> void:
	if !Static.game_in_progress && event is InputEventKey && time_to_start <= 0:
		start_game()

	# if event.is_action_pressed("debug_swap_mode"):
	# 	if state == "building":
	# 		begin_combat()
	# 	else:
	# 		begin_building()

func start_game():
	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	state = "building"
	new_player.global_position = Vector2.ONE * 8
	world.add_child(new_player)
	current_player = new_player

	spawned_drill.emit(new_player)

	Static.current_gold = 0
	Static.increment_gold(5)
	Static.current_gems = 0
	Static.increment_gems(3)
	Static.health = 3

	Static.game_in_progress = true

	walls.generate_start()
	new_player.update_fuel_gague()

	start_menu.fade_out()
	drill_menu.enable()
	resource_menu.enable()

	Static.round_number = 1

func end_game():
	state = "building"

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
	Static.MAX_FUEL = Static.INITIAL_MAX_FUEL
	Static.PLAYER_DRILL_LEVEL = 0
	Static.PLAYER_GUN_LEVEL = 0
	Static.PLAYER_RADAR_LEVEL = 0
	time_to_start = START_SCREEN_COOLDOWN_TIME

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
	
	Static.fuel_meter.visible = false

	var new_player: CharacterBody2D = player_scene.instantiate()
	new_player.global_position = current_player.global_position
	world.add_child(new_player)

	current_player.queue_free()
	current_player = new_player

	pathfinding.calc_pathing()
	
	if Static.round_number > len(waves): # Use hand-curated waves if possible, but then switch to an exponentially-escalating endless mode eventually
		var duration = float(Static.round_number)/(int((Static.round_number-4) ** 1.5)+1)
		var num = 0
		for i in range((Static.round_number-4) ** 1.5):
			spawn_delayed.append([duration*num, enemies.pick_random()])
			num += 1
	else:
		var duration = waves[Static.round_number-1][0]/max(len(waves[Static.round_number-1][1])-1, 1)
		var num = 0
		for enemy in waves[Static.round_number-1][1]:
			spawn_delayed.append([duration*num, enemy])
			num += 1

	round_announcement.announce()

	spawned_combat.emit(new_player)

func begin_building():
	if len(spawn_delayed) > 0: return
	print("Starting building!")

	state = "building"
	
	Static.fuel_meter.visible = true

	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = floor(current_player.global_position / 16) * 16 + Vector2.ONE * 8
	world.add_child(new_player)
	current_player.queue_free()
	current_player = new_player

	spawned_drill.emit(new_player)
	new_player.update_fuel_gague()

	Static.round_number += 1

func end_combat():
	completed_round.emit()

	begin_building()

func take_damage():
	Static.health -= 1

	if Static.health <= 0:
		end_game()

	Static.camera.shake(5)

func show_range_indicator(loc, size):
	tower_range.global_position = loc
	tower_range.scale = Vector2(size/tower_range.texture.get_width(), size/tower_range.texture.get_height())
	tower_range.visible = true

func hide_range_indicator():
	tower_range.visible = false
