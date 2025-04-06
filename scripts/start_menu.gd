extends Node2D

@onready var highscore_label: Label = get_node("Highscore") 

var show = true

func _ready() -> void:
	highscore_label.visible = false

func fade_out():
	show = false

func fade_in():
	show = true

	highscore_label.visible = Static.deepest > 0
	highscore_label.text = "DEEPEST: " + str(int(Static.deepest)) + "m"

func _process(delta: float):
	if !show:
		modulate = Static.fixed_lerp(modulate, Color(1, 1, 1, 0), 4, delta)
	else:
		modulate = Static.fixed_lerp(modulate, Color(1, 1, 1, 1), 4, delta)
