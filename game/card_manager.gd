extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func populate_card(card_arrays: Array):
	for array_index in card_arrays.size():
		for n_index in card_arrays[array_index].size():
			var n_node = self.find_child("N%s" % str(array_index*9+n_index+1), true)
			n_node.set_number(card_arrays[array_index][n_index])
			pass
	pass
