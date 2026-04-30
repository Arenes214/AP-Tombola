extends VBoxContainer

var victory_box: Node
var tombola_box: Node
var milestone_box: Node

var already_received_regular = []
var already_received_milestone = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate_goals(game_manager_node: Node):
	victory_box = self.find_child("VictoryBox")
	tombola_box = self.find_child("TombolaBox")
	milestone_box = self.find_child("MilestoneBox")
	
	victory_box.score_is_reached.connect(_on_score_reached)
	tombola_box.score_is_reached.connect(_on_score_reached)

	var tombola_requirement = int(Archipelago.conn.slot_data["tombola_victory_count"])
	
	var goals: int
	if GameOptions.enable_genver1_fixes:
		goals = 1
	else:
		goals = 2
	
	victory_box.populate("Complete all of the below...", goals)
	tombola_box.populate("Score %s Tombola" % tombola_requirement, tombola_requirement)
	
	game_manager_node.regular_location_sent.connect(_on_regular_location_sent)
	
	if not GameOptions.enable_genver1_fixes:
		milestone_box.score_is_reached.connect(_on_score_reached)
		var milestone_requirement = int(Archipelago.conn.slot_data["milestone_victory_count"])
		milestone_box.populate("Complete %s Milestones" % milestone_requirement, milestone_requirement)
		game_manager_node.milestone_location_sent.connect(_on_milestone_location_sent)
	else:
		milestone_box.queue_free()


func _on_regular_location_sent(id: int):
	var id_score = str(id)
	if already_received_regular.has(id):
		return
	elif id_score[1] == str(7):
		already_received_regular.append(id)
		tombola_box.update_score()

func _on_milestone_location_sent(id: int):
	if already_received_milestone.has(id):
		return
	else:
		already_received_milestone.append(id)
		milestone_box.update_score()
	
func _on_score_reached(the_node: Node):
	if the_node == victory_box:
		victory_box.update_name("PRESS HERE TO GOAL!!!")
		victory_box.allow_goal_button()
		return
	victory_box.update_score()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
