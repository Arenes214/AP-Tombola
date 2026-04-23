extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save():
	var save_dict = {
		"savename" = $VBox/SaveName.text,
		"slotname" = $VBox/SlotName.text,
		"ip" = $VBox/IP.text,
		"port" = $VBox/Port.text,
		"password" = $VBox/Password.text
	}
	return save_dict

func load_info(info: Dictionary):
	$VBox/SaveName.text = info["save_name"]
	$VBox/SlotName.text = info["slot_name"]
	$VBox/IP.text = info["ip"]
	$VBox/Port.text = info["port"]
	$VBox/Password.text = info["password"]
	
