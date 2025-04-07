extends Control

var timer = 0
var anouncing = false

@onready var label: Label = get_node("Label") 

func _ready() -> void:
    label.position = Vector2(0, 30)

func _process(delta: float) -> void:
    if !anouncing:
        return

    timer += delta

    if timer < 1:
        label.position = Vector2(0, 30 - Static.easing(timer) * 30)
    
    if timer > 2:
        label.position = Vector2(0, Static.easing(timer - 2) * 30)

    if timer > 3:
        anouncing = false


func announce():
    timer = 0
    anouncing = true

    label.text = "ROUND " + str(Static.round_number)
