extends Control
signal login_from_save(slot_name: String, ip: String, port: String, password: String, save_name: String)
signal delete_save_request(save_name: String)
signal edit_save_request(save_name: String, slot_name: String, ip: String, port: String, password: String)

var save_name: String
var slot_name: String
var ip: String
var port: String
var password: String
var ip_hidden: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_info(info: Dictionary):
	save_name = info["save_name"]
	slot_name = info["slot_name"]
	ip = info["ip"]
	port = info["port"]
	password = info["password"]
	ip_hidden = info["ip_hidden"]
	
	%VBox/SaveName.text = save_name
	%VBox/SlotName.text = slot_name
	if not ip_hidden:
		%VBox/Address.text = "%s:%s" % [ip, port]
	else:
		%VBox/Address.text = "IP Hidden"

func _on_load_button_pressed() -> void:
	login_from_save.emit(slot_name, ip, port, password, save_name)

func _on_delete_button_pressed() -> void:
	delete_save_request.emit(save_name)

func is_equal_to(save: String, slot: String):
	if save == save_name and slot == slot_name:
		return true
	else:
		return false

func _on_edit_button_pressed() -> void:
	edit_save_request.emit(save_name, slot_name, ip, port, password)
