extends Control

# SCORING LOCATIONS
const AMBO_LOCATIONS_MAX = 1
const TERNO_LOCATIONS_MAX = 2
const QUATERNA_LOCATIONS_MAX = 2
const CINQUINA_LOCATIONS_MAX = 3
const DECINA_LOCATIONS_MAX = 3
const TOMBOLA_LOCATIONS_MAX = 4
const ARRAY_LOCATIONS_MAX = [0,0,AMBO_LOCATIONS_MAX, TERNO_LOCATIONS_MAX, QUATERNA_LOCATIONS_MAX, CINQUINA_LOCATIONS_MAX, DECINA_LOCATIONS_MAX, TOMBOLA_LOCATIONS_MAX] # Padding to make calcs easier

var n_marked = []
var n_sum = 0
var n_total_count = 0
var n_even_count = 0
var n_odd_count = 0

signal n_marked_update(n: int, n_list: Array[int])
signal n_sum_update(sum: int)
signal n_total_count_update(count: int)
signal n_even_count_update(count: int)
signal n_odd_count_update(count: int)

signal regular_location_sent(id: int) # id will end with 1
signal milestone_location_sent(id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate cards with their numbers and connect to signals
	for i in range (1,7):
		var card_node = card_id_to_node(i)
		card_node.populate_card(Archipelago.conn.slot_data["Cards"][i-1], i-1)
		card_node.possible_regular_location_send.connect(_on_possible_regular_location)
		card_node.possible_unlock_loc_send.connect(_on_possible_unlock)
		card_node.possible_rowsanity_location_send.connect(_on_possible_rowsanity_location)
		card_node.number_was_marked.connect(_on_number_was_marked)

		if (Archipelago.conn.slot_data.has("Cards Locked")):
			if Archipelago.conn.slot_data["Cards Locked"].find(float(i)) != -1:
				card_node.lock()
				pass
	
	# Populate Milestones
	var vmile_node = self.find_child("VMile", true)
	for milestone in Archipelago.conn.slot_data["Milestones Chosen"]:
		var child = preload("res://game/milestone_box.tscn").instantiate()
		child.populate_milestone(milestone[0],milestone[1], self)
		vmile_node.add_child(child)
		child.milestone_achieved.connect(_on_possible_milestone_location)
	
	# Populate Goals
	var goal_node = self.find_child("GoalContainer", true)
	goal_node.populate_goals(self)
	# Connect to various AP signals
	Archipelago.conn.obtained_item.connect(_on_item_received)
	
	# Connect to Usable Signals
	var mark_node = self.find_child("MarkContainer", true)
	mark_node.using_free_mark.connect(_on_using_free_mark)
	mark_node.cancel_free_mark.connect(_on_cancel_free_mark_or_trap)
	
	# Connect to Trap Signals
	var trap_node = self.find_child("TrapContainer", true)
	trap_node.start_trap.connect(_on_starting_trap)
	trap_node.finish_trap.connect(_on_ending_trap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_item_received(item: NetworkItem):
	# Number
	if item.id >= 1 and item.id <= 90:
		for card_id in range (1,7):
			var card = Archipelago.conn.slot_data["Cards"][card_id-1]
			for row_id in card.size():
				# The array has the numbers as floats and search is type sensitive
				var col_id = card[row_id].find(float(item.id))
				if (col_id != -1):
					var card_node = card_id_to_node(card_id)
					card_node.mark_number(item.id, row_id, col_id, 1)
					if not card_node.is_locked and GameOptions.automark:
						card_node.automark_numbers()
	
	# Unlock
	elif item.id >= 101 and item.id <= 106:
		var card_id = item.id-100
		var card_node = card_id_to_node(card_id)
		if card_node.is_locked:
			card_node.allow_unlock()
			if GameOptions.automark:
				card_node._on_unlock_button_pressed()
	
	elif item.id == 201: # Free Mark
		var mark_node = self.find_child("MarkContainer", true)
		mark_node.possible_item()
	elif item.id == 202: # Free Location Hint
		var lhint_node = self.find_child("LHintContainer", true)
		lhint_node.possible_item()
	elif [203,301,302].has(item.id): # Trap Shield or Traps
		var trap_node = self.find_child("TrapContainer", true)
		trap_node.possible_item(item)

func _on_cancel_free_mark_or_trap():
	for i in range(1,7):
		var card_node = card_id_to_node(i)
		card_node.restore_status()
	var mark_node = self.find_child("MarkContainer", true)
	mark_node._free_lock()
	mark_node.reset_usable()

func _on_number_was_marked(n: int, special: int):
	if special == 3: # Free Mark Done
		_on_cancel_free_mark_or_trap()
		
	if not n_marked.has(n):
		n_total_count += 1
		n_total_count_update.emit(n_total_count)
		n_sum += n
		n_sum_update.emit(n_sum)
		if n % 2 == 0:
			n_even_count += 1
			n_even_count_update.emit(n_even_count)
		else:
			n_odd_count += 1
			n_odd_count_update.emit(n_odd_count)
		n_marked.append(n)
		n_marked_update.emit(n, n_marked)

func _on_using_free_mark():
	var mark_node = self.find_child("MarkContainer", true)
	var trap_node = self.find_child("TrapContainer", true)
	
	if trap_node.middle_of_trap_exec:
		mark_node._refuse_free_mark()
		return
	
	for i in range(1,7):
		var card_node = card_id_to_node(i)
		card_node.set_all_numbers_status(true, 4)

func _on_starting_trap(id: int):
	var mark_node = self.find_child("MarkContainer", true)
	mark_node._on_button_pressed()
	if id == 301:
		for i in range(1,7):
			var card_node = card_id_to_node(i)
			card_node.set_all_numbers_status(false, 11) # Status 11 is Blindness Trap
	elif id == 302:
		for i in range(1,7):
			var card_node = card_id_to_node(i)
			card_node.set_all_numbers_status(true, 12) # Status 12 is Lock Trap

func _on_ending_trap():
	print("Game knows to end trap")
	_on_cancel_free_mark_or_trap()
	pass
	
func _on_possible_regular_location(card_id: int, score_type: int):
	var id_start = (card_id+1)*10000 + score_type*1000 + 1
	regular_location_sent.emit(id_start)
	for i in range(ARRAY_LOCATIONS_MAX[score_type]):
		if Archipelago.location_exists(id_start+i):
			if not Archipelago.location_checked(id_start+i):
				Archipelago.collect_location(id_start+i)					

func _on_possible_rowsanity_location(card_id: int, score_type: int, row_id: int, decina_row: int):
	if (not score_type == 6):
		var id = (card_id+1)*10000 + score_type*1000 + 100 + (row_id+1)*10 + 1
		if Archipelago.location_exists(id):
			if not Archipelago.location_checked(id):
				Archipelago.collect_location(id)
	else:
		if [row_id,decina_row].has(0) && [row_id,decina_row].has(2):
			var id = (card_id+1)*10000 + score_type*1000 + 100+ 3*10 + 1 # Discriminator in ID is 3
			if Archipelago.location_exists(id):
				if not Archipelago.location_checked(id):
					Archipelago.collect_location(id)
		else:
			var id = (card_id+1)*10000 + score_type*1000 + 100 + ([row_id,decina_row].min()+1)*10 + 1 # Discriminator is Lower of the two
			if Archipelago.location_exists(id):
				if not Archipelago.location_checked(id):
					Archipelago.collect_location(id)

func _on_possible_unlock(card_id: int): # CARD UNLOCK
	var id = (card_id+1)*10000 + 8001
	if Archipelago.location_exists(id):
		if not Archipelago.location_checked(id):
			Archipelago.collect_location(id)

func _on_possible_milestone_location(loc_id: int):
	milestone_location_sent.emit(loc_id)
	if Archipelago.location_exists(loc_id):
		if not Archipelago.location_checked(loc_id):
			Archipelago.collect_location(loc_id)
	pass

func card_id_to_node(n: int) -> Node:
	var card_node = self.find_child("Card %s" % str(n), true)
	return card_node
