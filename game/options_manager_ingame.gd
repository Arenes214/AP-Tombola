extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AutoMarkButton.button_pressed = GameOptions.actual_automark


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_disconnect_button_pressed() -> void:
	GameOptions.intentional_disconnect = true
	Archipelago.ap_disconnect()


func _on_auto_mark_button_toggled(toggled_on: bool) -> void:
	GameOptions.actual_automark = toggled_on
	GameOptions.automark = toggled_on
