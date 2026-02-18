extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_number(n: int):
	if n == 0:
		$PanelContainer/Label.text = ""
	else:
		$PanelContainer/Label.text = str(n)


func _on_button_pressed() -> void:
	print("Boop")
