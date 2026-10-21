extends VBoxContainer

signal automark_enabled()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameOptions.automark:
		$AutoMarkButton.button_pressed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_disconnect_button_pressed() -> void:
	GameOptions.intentional_disconnect = true
	Archipelago.ap_disconnect()

func _on_auto_mark_button_toggled(toggled_on: bool) -> void:
	GameOptions.automark = toggled_on
	automark_enabled.emit()
	
