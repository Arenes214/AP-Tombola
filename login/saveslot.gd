extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_info(info: Dictionary):
	$VBox/SaveName.text = info["save_name"]
	$VBox/SlotName.text = info["slot_name"]
	$VBox/IP.text = info["ip"]
	$VBox/Port.text = info["port"]
	$VBox/Password.text = info["password"]
	
