extends Node

var game_scene = preload("res://game/game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(_on_connected)
	# TODO Call the function that will display the saves

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_connect_button_pressed() -> void: # Connect without saving
	connect_to_ap()

func _on_save_connect_button_pressed() -> void: # Save and then Connect
	# TODO Save
	# TODO save to a new slot, for now it just overrides the first save
	var save_file = FileAccess.open("user://saveslot1.tmblasave", FileAccess.WRITE)
	
	var save_info = {
		"save_name" = %LoginBox/SaveField.text,
		"slot_name" = %LoginBox/NameField.text,
		"ip" = %LoginBox/IPField.text,
		"port" = %LoginBox/PortField.text,
		"password" = %LoginBox/PasswordField.text
	}
	
	var json_string = JSON.stringify(save_info)
	
	save_file.store_line(json_string)
	
	connect_to_ap()

 # TODO slot validation

func _on_connected(conn: ConnectionInfo, json: Dictionary):
	GameOptions.automark = $"../LoginBox/AutoClickButton".button_pressed
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	%LoginBox.hide()

func connect_to_ap():
	Archipelago.ap_connect(%LoginBox/IPField.text, %LoginBox/PortField.text, %LoginBox/NameField.text, %LoginBox/PasswordField.text)
