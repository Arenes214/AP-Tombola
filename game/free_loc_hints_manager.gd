extends PanelContainer

var used = 0
var obtained = 0

var already_cached = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.conn.set_notify("Tombola P%s Free LH Used" % Archipelago.conn.player_id, set_used)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func possible_item():
	obtained += 1
	reset_usable()

func reset_usable():
	Archipelago.conn.retrieve("Tombola P%s Free LH Used" % Archipelago.conn.player_id, _after_retrieve)

func _after_retrieve(proc):
	if not proc:
		used = 0
	else:
		used = int(proc)
	
	if obtained > used:
		mark_usable(obtained - used)
	elif used >= obtained:
		$Label.text = "No Free Location Hint Available"
		$Button.visible = false
		$Button.disabled = true

func mark_usable(n: int):
	if n == 1:
		$Label.text = "1 Free Location Hint - Press to Use"
	else:
		$Label.text = "%s Free Location Hints - Press to Use" % n
	$Button.visible = true
	$Button.disabled = false

var all_ids = []
var middle_of_request = false

func _on_button_pressed() -> void:
	$Button.visible = false
	$Button.disabled = true
	$Label.text = "Finding Location with Prog Item"
	
	if not middle_of_request:
		all_ids = Archipelago.location_list()
		all_ids.erase(-1)
		for item in all_ids:
			if item < 0:
				all_ids.erase(item)
		all_ids.shuffle()
		middle_of_request = true
	
	if all_ids.size() == 0:
		$Label.text = "No Progression Items Remain..."
		return

	var id = all_ids.pop_front()
	print("trying %s" % id)
	
	Archipelago.conn.scout(id, 0, _post_scout)

func _post_scout(value):
	if value.is_prog() and not Archipelago.location_checked(value.loc_id):
		Archipelago.conn.scout(value.loc_id, 1, _after_hint)
	else:
		_on_button_pressed()

func _after_hint(_value):
	Archipelago.send_command("Set",{"key": "Tombola P%s Free LH Used" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "add", "value": 1}]})
	middle_of_request = false
	
func set_used(n):
	if not n:
		used = 0
	else:
		used = int(n)
	reset_usable()
