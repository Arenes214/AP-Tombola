extends PanelContainer

signal start_trap(id: int)
signal finish_trap()

var incoming_queue: Array
var to_execute_queue: Array

var shield_received = 0
var shield_used = 0
var sh_used_local_count = 0

var trap_received = 0
var timer: Timer

var middle_of_trap_try = false
var middle_of_trap_exec = false
var current_trap: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(end_trap)
	self.add_child(timer)
	
	Archipelago.conn.set_notify("Tombola P%s Shield Used" % Archipelago.conn.player_id, _set_shield_used)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# TODO REMOVE TEST 
	if middle_of_trap_exec:
		if current_trap == 301:
			$Label.text = "Blindness Trap: %s sec" % (snappedf(timer.time_left, 0.1))
		elif current_trap == 302:
			$Label.text = "Lock Trap: %s sec" % (snappedf(timer.time_left, 0.1))
	elif shield_received and shield_used:
		if shield_received <= shield_used:
			$Label.text = "No Shields - Vulnerable to Next Trap"
		elif shield_received == shield_used + 1:
			$Label.text = "1 Shield - Next Trap Prevented"
		else:
			$Label.text = "%s Shields - Next Traps Prevented" % (shield_received - shield_used)
	else:
		$Label.text = "No Shields - Vulnerable to Next Trap"

func possible_item(item: NetworkItem):
	if item.id == 203:
		shield_received += 1
		Archipelago.conn.retrieve("Tombola P%s Shield Used" % Archipelago.conn.player_id, _after_shield_retrieve)
	else:
		trap_received += 1
		incoming_queue.append([item.id, trap_received])
		Archipelago.conn.retrieve("Tombola P%s Last Trap Completed" % Archipelago.conn.player_id, _after_trap_retrieve)

func _after_trap_retrieve(proc):
	var last_completed = 0
	if proc:
		last_completed = int(proc)
	
	var trap = incoming_queue.pop_front()
	if trap[1] > last_completed:
		to_execute_queue.append(trap[0])
		execute_trap()

func _after_shield_retrieve(proc):
	if proc:
		_set_shield_used(proc)
	if shield_received > shield_used and middle_of_trap_exec:
		end_trap()
	
	# TODO check if this is even used lmao
	if shield_received >= shield_used:
		if middle_of_trap_exec:
			end_trap()
	
func execute_trap():
	if middle_of_trap_try:
		return
	middle_of_trap_try = true
	Archipelago.conn.retrieve("Tombola P%s Shield Used" % Archipelago.conn.player_id, _continue_trap)

func _continue_trap(proc):
	_set_shield_used(proc)
	var trap = to_execute_queue.pop_front()
	
	if shield_received > sh_used_local_count:
		sh_used_local_count += 1
		Archipelago.send_command("Set",{"key": "Tombola P%s Shield Used" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "add", "value": 1}]})
		Archipelago.send_command("Set",{"key": "Tombola P%s Last Trap Completed" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "add", "value": 1}]})
		middle_of_trap_try = false
		if to_execute_queue.size() > 0:
			execute_trap()
		return
	var time: int
	match trap:
		301:
			time = 60
		302:
			time = 30
	
	middle_of_trap_exec = true
	start_trap.emit(trap)
	timer.start(time)
	current_trap = trap
	
func end_trap():
	timer.stop()
	if not timer.wait_time == 0:
		timer.wait_time = 123
	Archipelago.send_command("Set",{"key": "Tombola P%s Last Trap Completed" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "add", "value": 1}]})
	middle_of_trap_try = false
	middle_of_trap_exec = false
	finish_trap.emit()
	print("size %s" % to_execute_queue.size())
	if to_execute_queue.size() > 0:
		execute_trap()

func _set_shield_used(value):
	if not value:
		return
	shield_used = int(value)
	if shield_used > sh_used_local_count:
		sh_used_local_count = shield_used
