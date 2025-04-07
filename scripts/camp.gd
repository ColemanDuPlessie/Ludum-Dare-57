extends Node2D

var size = 0
var appearing = false

@export var uiOrigin: Node2D

var player_in = true

func _ready():
	uiOrigin.scale = Vector2(1, 0)

func _player_entered_area(_body):
	player_in = true
	if Static.currently_displayed_hint != "move" and Static.currently_displayed_hint != "build" and (Static.currently_displayed_hint != "return" or Static.fuel_meter.flashing):
		appearing = true

func _player_exited_area(_body):
	player_in = false
	appearing = false

func _process(delta: float) -> void:
	if appearing:
		size += delta * 3
	else:
		size -= delta * 3

	size = clampf(size, 0, 1)

	if appearing:
		uiOrigin.scale = Vector2(Static.easing(size), Static.easing(size))
	else:
		uiOrigin.scale = Vector2(Static.easing(size), Static.easing(size))

func start_round():
	Static.game_manager.begin_combat()
