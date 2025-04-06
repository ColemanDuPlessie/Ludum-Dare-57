extends Node2D

var show = true

func fade_out():
	show = false

func fade_in():
	show = true

func _process(delta: float):
	if !show:
		modulate = Static.fixed_lerp(modulate, Color(1, 1, 1, 0), 4, delta)
	else:
		modulate = Static.fixed_lerp(modulate, Color(1, 1, 1, 1), 4, delta)
