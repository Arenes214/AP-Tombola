extends Node

var game_scene = preload("res://game/game.tscn")

var all_save_slots = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(_on_connected)
	restore_saves()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func restore_saves():
	if not FileAccess.file_exists("user://saveslot1.tmblasave"):
		return # No Save
	
	var save_file = FileAccess.open("user://saveslot1.tmblasave", FileAccess.READ)
	
	var i = 0
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("Error parsing Save JSON: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		
		var node_data = json.data
		all_save_slots[i] = node_data
		i += 1
		
		var save_node = load("res://login/saveslot.tscn").instantiate()
		save_node.load_info(node_data)
		save_node.login_from_save.connect(_connect_from_save)
		save_node.delete_save_request.connect(_delete_save)
		%SaveBox.add_child(save_node)
	
	

func _on_connect_button_pressed() -> void: # Connect without saving
	connect_to_ap()

func _on_save_connect_button_pressed() -> void: # Save and then Connect
	# TODO Save
	# TODO save to a new slot, for now it just overrides the first save
	
	var save_info = {
		"save_name" = %LoginBox/SaveField.text,
		"slot_name" = %LoginBox/NameField.text,
		"ip" = %LoginBox/IPField.text,
		"port" = %LoginBox/PortField.text,
		"password" = %LoginBox/PasswordField.text,
		"ip_hidden" = %LoginBox/IpHideButton.button_pressed
	}
	all_save_slots[all_save_slots.size()+1] = save_info
	_write_saves()
	
	connect_to_ap()

 # TODO slot validation

func _on_connected(conn: ConnectionInfo, json: Dictionary):
	GameOptions.automark = %LoginBox/AutoClickButton.button_pressed
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	%LoginBox.hide()

func connect_to_ap():
	Archipelago.ap_connect(%LoginBox/IPField.text, %LoginBox/PortField.text, %LoginBox/NameField.text, %LoginBox/PasswordField.text)

func _connect_from_save(slot_name: String, ip: String, port: String, password: String):
	Archipelago.ap_connect(ip, port, slot_name, password)

func _delete_save(save_name: String):
	for slot_i in all_save_slots:
		var slot = all_save_slots[slot_i]
		if slot["save_name"] == save_name:
			all_save_slots.erase(slot_i)
			_write_saves()
			for node in %SaveBox.get_children():
				if node.save_name == save_name:
					node.queue_free()

func _write_saves():
		var save_file = FileAccess.open("user://saveslot1.tmblasave", FileAccess.WRITE)
		
		for slot in all_save_slots.values():
			var json_string = JSON.stringify(slot)
			save_file.store_line(json_string)
