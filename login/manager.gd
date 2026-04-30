extends Node

var client_ver = 2
var game_scene = preload("res://game/game.tscn")

var conn_try = false
var conn_yes = false
var version_mismatch = false

var all_save_slots = {}
var current_scene: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(_on_connected)
	Archipelago.connectionrefused.connect(_on_connection_refused)
	Archipelago.disconnected.connect(_on_disconnected)
	restore_saves()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func restore_saves():
	if %SaveBox.get_child_count() > 0:
		for child in %SaveBox.get_children():
			child.queue_free()
		
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
	
	var save_info = {
		"save_name" = %LoginBox/SaveField.text,
		"slot_name" = %LoginBox/NameField.text,
		"ip" = %LoginBox/IPField.text,
		"port" = %LoginBox/PortField.text,
		"password" = %LoginBox/PasswordField.text,
		"ip_hidden" = %LoginBox/IpHideButton.button_pressed
	}
	all_save_slots[all_save_slots.size()] = save_info
	_write_saves()
	
	connect_to_ap()

 # TODO slot validation

func _on_connected(conn: ConnectionInfo, json: Dictionary):
	if not Archipelago.conn.slot_data.has("Genver"):
		Archipelago.ap_disconnect()
		$"../LoginBox/ConnLabel".clear()
		$"../LoginBox/ConnLabel".add_text("Error: The room you tried to connect to was generated with APWorld version 0.1.x .\nThis client is not currently backwards compatible with seeds generated on 0.1.x .\nIf it has been a few days since the release of client 0.2.0, check for a possible 0.2.x update that will bring backwards compatibility.\n(I, the dev, promise that the update will happen)")
		version_mismatch = true
		return
	else:
		var genver = Archipelago.conn.slot_data["Genver"]
		if genver > client_ver:
			Archipelago.ap_disconnect()
			$"../LoginBox/ConnLabel".clear()
			$"../LoginBox/ConnLabel".add_text("Error: The room you tried to connect was generated with an APWorld newer than what the client currently supports.\n Update your client.")
			version_mismatch = true
			return
	
	GameOptions.actual_automark = %LoginBox/AutoClickButton.button_pressed
	$"../LoginBox/ConnLabel".clear()
	$"../LoginBox/ConnLabel".add_text("Connected!")
	
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	current_scene = scene
	%LoginBox.hide()
	$"../ScrollContainer".hide()
	conn_try = false
	conn_yes = true

func connect_to_ap():
	conn_try = true
	conn_yes = false
	Archipelago.ap_connect(%LoginBox/IPField.text, %LoginBox/PortField.text, %LoginBox/NameField.text, %LoginBox/PasswordField.text)
	$"../LoginBox/ConnLabel".clear()
	$"../LoginBox/ConnLabel".add_text("Connecting...")
	
	
var refused = false
func _on_connection_refused(conn, json):
	$"../LoginBox/ConnLabel".clear()
	$"../LoginBox/ConnLabel".add_text("Connection refused with error %s" % json["errors"])
	refused = true
	conn_try = false

var retry = true
func _on_disconnected():
	if version_mismatch:
		return
	if conn_try:
		$"../LoginBox/ConnLabel".clear()
		$"../LoginBox/ConnLabel".add_text("Connection not successful. Check if the room is open...")
	elif conn_yes and retry and not refused:
		retry = not retry
		$"../LoginBox/ConnLabel".clear()
		$"../LoginBox/ConnLabel".add_text("Connection Lost, trying to Reconnect...")
	elif not refused:
		retry = not retry
		$"../LoginBox/ConnLabel".clear()
		$"../LoginBox/ConnLabel".add_text("Connection Lost!")
	refused = false
	if current_scene:
		current_scene.queue_free()
		%LoginBox.show()
		$"../ScrollContainer".show()
	conn_try = false

func _connect_from_save(slot_name: String, ip: String, port: String, password: String):
	conn_try = true
	Archipelago.ap_connect(ip, port, slot_name, password)
	$"../LoginBox/ConnLabel".clear()
	$"../LoginBox/ConnLabel".add_text("Connecting...")

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
	save_file.close()
	restore_saves()
