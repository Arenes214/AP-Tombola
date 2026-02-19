extends Node

var game_scene = preload("res://game/game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(_on_connected)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_connect_button_pressed() -> void:
	Archipelago.ap_connect(%LoginBox/IPField.text, %LoginBox/PortField.text, %LoginBox/NameField.text, %LoginBox/PasswordField.text)

 # TODO slot validation

func _on_connected(conn: ConnectionInfo, json: Dictionary):
	GameOptions.automark = $"../LoginBox/AutoClickButton".button_pressed
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	
	%LoginBox.hide()
