extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal possible_location_send(card_id: int, score_type: int)

var card_id: int = 0
var own_card: Array
var is_locked: bool = false

func lock():
	is_locked = true
	$VBoxContainer.visible = false
	$LockPanel.visible =  true

func allow_unlock():
	# TODO Change text of button
	$LockPanel/UnlockButton.disabled = false

func populate_card(card_arrays: Array, card_iden: int):
	card_id = card_iden
	own_card = card_arrays
	for row_id in card_arrays.size():
		for col_id in card_arrays[row_id].size():
			var n_node = self.find_child("N%s" % str(row_id*9+col_id+1), true)
			n_node.set_number(card_arrays[row_id][col_id], col_id, row_id)
			n_node.number_pressed.connect(on_number_pressed)


func mark_number(n: int, row_id: int, col_id: int, mark_type: int):
	var n_node = self.find_child("N%s" % str(row_id*9+col_id+1), true)
	n_node.mark(mark_type)
	
func automark_numbers():
	for hbox in $VBoxContainer.get_children():
		for node in hbox.get_children():
			if not node.n == 0 and node.is_markable:
				node.auto_press()

func on_number_pressed(n: int, row_id: int):
	var count = 0
	for i in range(9):
		var n_node = self.find_child("N%s" % str(row_id*9+i+1), true)
		if n_node.has_been_marked == true:
			count += 1
			
			if count >= 2:
				possible_location_send.emit(card_id, count)
				
				pass
	# Check Decina and Tombola
	if count == 5:
		var other_rows = [0,1,2]
		other_rows.erase(row_id)
		
		for other_row_id in other_rows:
			if not count == 10:
				count = 5 # Reset count only if it was not decina already
			for i in range(9):
				var n_node = self.find_child("N%s" % str(other_row_id*9+i+1), true)
				if n_node.n != 0:
					if n_node.has_been_marked == true:
						count += 1
					else:
						break
				if count == 10:
					possible_location_send.emit(card_id, 6)
					pass
		
		if count == 15:
			possible_location_send.emit(card_id, 7)
			pass
	

func _on_unlock_button_pressed() -> void:
	$LockPanel.visible = false
	$VBoxContainer.visible = true
	is_locked = false
	if not is_locked and GameOptions.automark:
		automark_numbers()
