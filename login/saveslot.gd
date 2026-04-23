extends Control
signal login_from_save(slot_name: String, ip: String, port: String, password: String)
signal delete_save_request(save_name: String)

var save_name: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_info(info: Dictionary):
	$VBox/SaveName.text = info["save_name"]
	save_name = info["save_name"]
	
	$VBox/SlotName.text = info["slot_name"]
	$VBox/IP.text = info["ip"]
	$VBox/Port.text = info["port"]
	$VBox/Password.text = info["password"]
	
	

func _on_load_button_pressed() -> void:
	login_from_save.emit($VBox/SlotName.text, $VBox/IP.text, $VBox/Port.text, $VBox/Password.text)


func _on_delete_button_pressed() -> void:
	delete_save_request.emit($VBox/SaveName.text)
