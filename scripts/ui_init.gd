extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Static.UI = self
	Static.gold_counter = get_node("GoldCounter")
	Static.gems_counter = get_node("GemCounter")
	Static.hide_shop()
