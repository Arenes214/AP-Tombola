extends Control

signal score_is_reached(self_node: Node)

var box_green = load("res://game/styles/milestone_box_background_green.tres")
var bar_green = load("res://game/styles/milestone_bar_green.tres")

var already_signalled_score = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate(text: String, target: int):
	update_name(text)
	update_bar_max(target)

func update_name(text: String):
	$V/NameBox.text = text
	
func update_bar_max(n: int):
	$V/Bar.max_value = n
	$V/Bar/Label.text = "0 / %s" % n

func update_score():
	$V/Bar.value += 1
	$V/Bar/Label.text = "%s / %s" % [int($V/Bar.value), int($V/Bar.max_value)]
	if ($V/Bar.value >= $V/Bar.max_value and not already_signalled_score):
			score_reached()
			already_signalled_score = true
	
	
func score_reached():
	$Background.add_theme_stylebox_override("panel", box_green)
	$V/Bar.theme = bar_green
	score_is_reached.emit(self)
	
func allow_goal_button():
	$Button.visible = true
	
	
	
func _on_button_pressed() -> void:
	Archipelago.set_client_status(Archipelago.ClientStatus.CLIENT_GOAL)
