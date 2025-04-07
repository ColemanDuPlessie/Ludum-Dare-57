extends ColorRect

func _ready() -> void:
	var button: Button = get_parent()

	button.mouse_entered.connect(enter)
	button.mouse_exited.connect(exit)

	visible = false


func enter():
	visible = true
			
func exit():
	visible = false
