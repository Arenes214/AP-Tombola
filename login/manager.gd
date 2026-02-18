extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_connect_button_pressed() -> void:
	Archipelago.ap_connect(%LoginBox/IPField.text, %LoginBox/PortField.text, %LoginBox/NameField.text, %LoginBox/PasswordField.text)

 # TODO slot validation
