extends Control

var stylebox_clear = load("res://game/styles/number_box_default.tres")
var stylebox_orange = load("res://game/styles/number_box_orange.tres")
var stylebox_green = load("res://game/styles/number_box_green.tres")
var stylebox_purple = load("res://game/styles/number_box_purple.tres")
var stylebox_blue = load("res://game/styles/number_box_blue.tres")
var stylebox_black = load("res://game/styles/number_box_black.tres")

signal number_pressed(n: int, row_id: int, special: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var n: int = 0
var col_id: int = -1
var row_id: int = -1
var has_been_marked = false
var is_markable = false
var is_restoring = false
var current_mark = 0
var middle_of_free = false
var middle_of_trap = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_number(number: int, col: int, row: int):
	if number == 0:
		$PanelContainer/Label.text = ""
	else:
		$PanelContainer/Label.text = str(number)
		n = number
		col_id = col
		row_id = row
		Archipelago.conn.retrieve("Tombola P%s %s" % [Archipelago.conn.player_id,str(n)], _restore_previous_mark)

# Mark types:
# 1 = Orange
# 2 = Green
# 3 = Blue / Free Mark Used
# 4 = Purple / Using Free Mark
func mark(mark_type: int): #func name is kinda misleading fuck
	if mark_type == 0:
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_clear)
		$PanelContainer/Label/Button.visible = false
		
	elif mark_type == 1:
		current_mark = 1
		if has_been_marked:
			return
		if middle_of_trap:
			return
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_orange)
		$PanelContainer/Label/Button.visible = true
		is_markable = true
		middle_of_free = false
		
		
	elif mark_type == 2:
		current_mark = 2
		$PanelContainer/Label/Button.visible = false
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_green)
		has_been_marked = true
		is_markable = false
		number_pressed.emit(n, row_id, 0)
		Archipelago.send_command("Set",{"key": "Tombola P%s %s" % [Archipelago.conn.player_id,str(n)], "default":0, "want_reply": true, "operations":[{"operation": "replace", "value": 2}]})
		
		
	elif mark_type == 3:
		if current_mark == 3:
			return
		current_mark = 3
		$PanelContainer/Label/Button.visible = false
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_blue)
		has_been_marked = true
		is_markable = false
		number_pressed.emit(n, row_id, 3)
		Archipelago.send_command("Set",{"key": "Tombola P%s %s" % [Archipelago.conn.player_id,str(n)], "default":0, "want_reply": true, "operations":[{"operation": "replace", "value": 3}]})
		if not is_restoring:
			Archipelago.send_command("Set",{"key": "Tombola P%s Free Mark Used" % Archipelago.conn.player_id, "default":0, "want_reply": true, "operations":[{"operation": "add", "value": 1}]})
		
		
	elif mark_type == 4:
		if is_markable or has_been_marked:
			return
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_purple)
		$PanelContainer/Label/Button.visible = true
		middle_of_free = true
	
	elif mark_type == 11:
		$PanelContainer/Label.text = "??"
		$PanelContainer.add_theme_stylebox_override("panel", stylebox_clear)
		$PanelContainer/Label/Button.visible = false
		$PanelContainer/Label/FakeButton.visible  = true
		middle_of_trap = true
		
	
	elif mark_type == 12:
		if (current_mark == 0 or current_mark == 1):
			$PanelContainer/Label/Button.visible = false
			$PanelContainer.add_theme_stylebox_override("panel", stylebox_black)
			middle_of_trap = true
	
func restore_mark(was_a_free):
	if not was_a_free:
		middle_of_trap = false
	_restore_labels()
	mark(current_mark)
	$PanelContainer/Label/FakeButton.visible  = false
	if was_a_free:
		middle_of_free = false

func _restore_labels():
	if n == 0:
		$PanelContainer/Label.text = ""
	else:
		$PanelContainer/Label.text = str(n)


func auto_press():
	$PanelContainer/Label/Button.emit_signal("pressed")

func _on_button_pressed() -> void:
	if (middle_of_free):
		mark(3)
	else:
		mark(2)

func _on_fake_button_pressed() -> void:
	if is_markable:
		_on_button_pressed()

func _restore_previous_mark(prop) -> void:
	if prop == 2:
		mark(2)
	elif prop == 3:
		is_restoring = true
		mark(3)
