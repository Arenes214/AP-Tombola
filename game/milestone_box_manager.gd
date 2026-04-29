extends Control

signal milestone_achieved(loc_id: int)
const score_type_strings = [0,0,"Ambo","Terno","Quaterna","Cinquina","Decina","Tombola"]

var stylebox_orange = load("res://game/styles/milestone_box_background_orange.tres")
var stylebox_green = load("res://game/styles/milestone_box_background_green.tres")
var bar_green = load("res://game/styles/milestone_bar_green.tres")

var label_max = 0
var what_score = 0
var location_id = 0
var is_achieved = false

var type1_score_type = 0
var type1_already_received = []

var type2_collection = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate_milestone(milestone_name, milestone_id_f, game_manager_node: Node):
	var milestone_id = int(milestone_id_f)
	location_id  = milestone_id
	@warning_ignore("integer_division")
	var milestone_type = (milestone_id - 70000) / 1000
	
	match milestone_type:
		1: # Score Collection
			@warning_ignore("integer_division")
			var score_type = (milestone_id - 71000) / 100
			type1_score_type = score_type
			@warning_ignore("integer_division")
			var score_count = (milestone_id - 71000 - (score_type)*100 - 1) / 10
			$V/NameBox.text = milestone_name
			$V/DescBox.text = "Score %s %s (sanity locations excluded)" % [score_count, score_type_strings[score_type]]
			$V/Bar.max_value = score_count
			$V/Bar/Label.text = "0 / %s" % score_count
			label_max = score_count
			what_score = 1
			game_manager_node.regular_location_sent.connect(_on_location_sent)
			
		2: # Collections of Numbers
			var all_collections = Archipelago.conn.slot_data["All Collection of Numbers Milestones"]
			var collection
			for item in all_collections:
				if item[1] == milestone_id:
					collection = item[2]
			
			$V/NameBox.text = milestone_name
			
			var collection_string = ""
			for n in collection:
				type2_collection.append(int(n))
				collection_string += str(int(n))
				if n == collection[-1]:
					collection_string += "."
				else:
					collection_string += ", "
				$V/DescBox.text = "Mark the following numbers: %s" % collection_string
			
			$V/Bar.max_value = collection.size()
			$V/Bar/Label.text = "0 / %s" % collection.size()
			label_max = collection.size()
			what_score = 2
			game_manager_node.n_marked_update.connect(_on_marked_update)
			
		
		3: # Total Count
			var all_counts = Archipelago.conn.slot_data["All Total Count Milestones"]
			var target
			for item in all_counts:
				if item[1] == milestone_id:
					target = int(item[2])
			
			$V/NameBox.text = milestone_name
			$V/DescBox.text = "Get the sum of all numbers marked to %s or greater" % target
			$V/Bar.max_value = target
			$V/Bar/Label.text = "0 / %s" % target
			label_max = target
			what_score = 3
			game_manager_node.n_sum_update.connect(_on_sum_update)
		
		4: # Even/Odd
			@warning_ignore("integer_division")
			var even_or_odd = (milestone_id - 74000) / 100
			var target = milestone_id - 74000 - (even_or_odd * 100)
			
			$V/NameBox.text = milestone_name
			if even_or_odd == 1:
				$V/DescBox.text = "Mark %s odd numbers" % target
				game_manager_node.n_odd_count_update.connect(_on_odd_update)
			else:
				$V/DescBox.text = "Mark %s even numbers" % target
				game_manager_node.n_even_count_update.connect(_on_even_update)
			$V/Bar.max_value = target
			$V/Bar/Label.text = "0 / %s" % target
			label_max = target
			what_score = 4
	
	# Restore previous status
	Archipelago.conn.retrieve(str(location_id), _restore_previous_status)

func set_status(status: int):
	match status:
		1: # Sendable / Orange
			if not is_achieved:
				$Background.add_theme_stylebox_override("panel", stylebox_orange)
				$V/Bar.theme = bar_green
				$Button.visible = true
				
				if GameOptions.automark:
					_on_button_pressed()
		2: # Sent
			$Background.add_theme_stylebox_override("panel", stylebox_green)
			$Button.visible = false
			$V/Bar.theme = bar_green
			milestone_achieved.emit(location_id)
			is_achieved = true
			Archipelago.send_command("Set",{"key": str(location_id), "default":0, "want_reply": true, "operations":[{"operation": "replace", "value": 2}]})

func _on_location_sent(id: int):
	var id_score = str(id)
	if type1_already_received.has(id):
		return
	elif type1_score_type == (int(id_score[1])): # AKA the location is for the score i care
		type1_already_received.append(id)
		$V/Bar.value += 1
		$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
		if ($V/Bar.value >= $V/Bar.max_value):
			set_status(1)

func _on_marked_update(n: int, _n_list: Array):
	if type2_collection.has(n):
		$V/Bar.value += 1
		$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
		if ($V/Bar.value >= $V/Bar.max_value):
			set_status(1)


func _on_sum_update(sum: int):
	$V/Bar.value = sum
	$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
	if ($V/Bar.value >= $V/Bar.max_value):
			set_status(1)


func _on_odd_update(count: int):
	$V/Bar.value = count
	$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
	if ($V/Bar.value >= $V/Bar.max_value):
			set_status(1)


func _on_even_update(count: int):
	$V/Bar.value = count
	$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
	if ($V/Bar.value >= $V/Bar.max_value):
			set_status(1)

func _restore_previous_status(prop) -> void:
	if prop == 2:
		set_status(2)

func _on_button_pressed() -> void:
	set_status(2)
