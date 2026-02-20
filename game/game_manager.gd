extends Control

# SCORING LOCATIONS
const AMBO_LOCATIONS_MAX = 1
const TERNO_LOCATIONS_MAX = 2
const QUATERNA_LOCATIONS_MAX = 2
const CINQUINA_LOCATIONS_MAX = 3
const DECINA_LOCATIONS_MAX = 3
const TOMBOLA_LOCATIONS_MAX = 4
const ARRAY_LOCATIONS_MAX = [0,0,AMBO_LOCATIONS_MAX, TERNO_LOCATIONS_MAX, QUATERNA_LOCATIONS_MAX, CINQUINA_LOCATIONS_MAX, DECINA_LOCATIONS_MAX, TOMBOLA_LOCATIONS_MAX] # Padding to make calcs easier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate cards with their numbers and connect to signals
	for i in range (1,7):
		var card_node = card_id_to_node(i)
		card_node.populate_card(Archipelago.conn.slot_data["Cards"][i-1], i-1)
		card_node.possible_location_send.connect(_on_possible_location)
		card_node.possible_unlock_loc_send.connect(_on_possible_unlock)
		
		if Archipelago.conn.slot_data["Cards Locked"].find(float(i)) != -1:
			card_node.lock()
			pass
	
	# Connect to various AP signals
	Archipelago.conn.obtained_item.connect(_on_item_received)



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
	manage_goal()


func _on_possible_location(card_id: int, score_type: int):
	var id_start = (card_id+1)*10000 + score_type*1000 + 1
	for i in range(ARRAY_LOCATIONS_MAX[score_type]):
		if Archipelago.location_exists(id_start+i):
			if not Archipelago.location_checked(id_start+i):
				Archipelago.collect_location(id_start+i)
	manage_goal()

func _on_possible_unlock(card_id: int):
	var id = (card_id+1)*10000 + 8001
	if Archipelago.location_exists(id):
		if not Archipelago.location_checked(id):
			pass
			Archipelago.collect_location(id)
	manage_goal()

func manage_goal():
	var score_requirement = int(Archipelago.conn.slot_data["tombola_victory_count"])
	var count = 0
	for i in range(1,7):
		var card_node = card_id_to_node(i)
		if card_node.has_scored_tombola:
			count += 1
	
	if count >= score_requirement:
		$CardContainer/OtherContainer/MilestoneContainer/GoalContainer/Label.text = "Tombola Requirement Reached!"
		$CardContainer/OtherContainer/MilestoneContainer/GoalContainer/Button.visible = true
		$CardContainer/OtherContainer/MilestoneContainer/GoalContainer/Button.disabled = false
		if (GameOptions.automark):
			_on_button_pressed()
	else:
		$CardContainer/OtherContainer/MilestoneContainer/GoalContainer/Label.text = "Need %s more Tombola" % (score_requirement - count)



func card_id_to_node(n: int) -> Node:
	var card_node = self.find_child("Card %s" % str(n), true)
	return card_node


func _on_button_pressed() -> void:
	Archipelago.set_client_status(Archipelago.ClientStatus.CLIENT_GOAL)


func _on_tombola_timer_timeout() -> void:
	manage_goal()
