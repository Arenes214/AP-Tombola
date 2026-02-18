extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate cards with their numbers
	for i in range (1,7):
		var card_node = card_id_to_node(i)
		card_node.populate_card(Archipelago.conn.slot_data["Cards"][i-1])
	
	# Connect to various AP signals
	Archipelago.conn.obtained_item.connect(_on_item_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_received(item: NetworkItem):
	pass



func card_id_to_node(n: int) -> Node:
	var card_node = self.find_child("Card %s" % str(n), true)
	return card_node
