extends Control
signal login_from_save(slot_name: String, ip: String, port: String, password: String)
signal delete_save_request(save_name: String)

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
	login_from_save.emit(slot_name, ip, port, password)


func _on_delete_button_pressed() -> void:
	delete_save_request.emit(save_name)
