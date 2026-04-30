extends PanelContainer

signal using_free_mark
signal cancel_free_mark(was_a_free: bool)

var obtained = 0
var used = 0
var state = 0
var usable = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.conn.set_notify("Tombola P%s Free Mark Used" % Archipelago.conn.player_id, _on_mark_used)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func possible_item():
	obtained += 1
	Archipelago.conn.retrieve("Tombola P%s Free Mark Used" % Archipelago.conn.player_id, _after_retrieve)

func _on_mark_used(_nope):
	reset_usable()

func reset_usable():
	Archipelago.conn.retrieve("Tombola P%s Free Mark Used" % Archipelago.conn.player_id, _after_retrieve)

func _after_retrieve(proc):
	if not proc:
		used = 0
	else:
		used = int(proc)
	if obtained > used:
		mark_usable(obtained - used)
	elif used >= obtained:
		$Label.text = "No Free Mark Available"
		$Button.visible = false
		$Button.disabled = true
	
func mark_usable(n: int):
	if n == 1:
		$Label.text = "1 Free Mark Available - Press to Use"
	else:
		$Label.text = "%s Free Marks Available - Press to Use" % n
	$Button.visible = true
	$Button.disabled = false
	state = 0
	
func _on_button_pressed() -> void:
	if state == 0:
		Archipelago.conn.retrieve("Tombola P%s Free Mark Lock" % Archipelago.conn.player_id, _on_lock_retrieved)
	else:
		_free_lock()
		$LockTimer.stop()
		cancel_free_mark.emit(true)
	
func _refuse_free_mark():
	state = 0
	_free_lock()
	reset_usable()

func _free_lock():
	Archipelago.send_command("Set",{"key": "Tombola P%s Free Mark Lock" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "replace", "value": 0}]})


func _set_lock():
	Archipelago.send_command("Set",{"key": "Tombola P%s Free Mark Lock" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "replace", "value": _get_time()}]})

func _on_lock_retrieved(lock):
	if not lock or lock + 30 <= _get_time():
		_set_lock()
		$Label.text = "Press to Cancel Free Mark Usage"
		state = 1
		using_free_mark.emit()
		$LockTimer.start()


func _get_time():
	var temp = Time.get_datetime_string_from_system(true)
	var result = Time.get_unix_time_from_datetime_string(temp)
	return result

func _on_lock_timer_timeout() -> void:
	cancel_free_mark.emit(true)
	_refuse_free_mark()
