extends Node2D

signal spawned_drill(player)

@export var world: Node2D

var state = "building"
var current_player: CharacterBody2D = null

var player_drill_scene: PackedScene = ResourceLoader.load("res://scenes/player_drill.tscn")
var player_scene: PackedScene = ResourceLoader.load("res://scenes/player.tscn")

func _ready():
	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = Vector2.ONE * 8
	world.add_child(new_player)
	current_player = new_player

	spawned_drill.emit(new_player)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_swap_mode"):
		if state == "building":
			begin_combat()
		else:
			begin_building()

func begin_combat():
	print("Starting combat!")

	state = "combat"

	var new_player: CharacterBody2D = player_scene.instantiate()
	new_player.global_position = current_player.global_position
	world.add_child(new_player)

	current_player.queue_free()
	current_player = new_player

func begin_building():
	print("Starting building!")

	state = "building"

	var new_player: CharacterBody2D = player_drill_scene.instantiate()
	new_player.global_position = floor(current_player.global_position / 16) * 16 + Vector2.ONE * 8
	world.add_child(new_player)
	current_player.queue_free()
	current_player = new_player

	spawned_drill.emit(new_player)
