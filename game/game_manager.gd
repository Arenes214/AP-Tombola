extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the slot data
	for card_index in Archipelago.conn.slot_data["Cards"].size():
		# call the thing that sends the numbers to the cards
		var card_node = self.find_child("Card %s" % str(card_index+1), true)
		card_node.populate_card(Archipelago.conn.slot_data["Cards"][card_index])
		pass
	
	
	
	
	# Send each card its numbers
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
