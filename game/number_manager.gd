extends Control

var stylebox_orange = load("res://game/styles/number_box_orange.tres")
var stylebox_green = load("res://game/styles/number_box_green.tres")

signal number_pressed(n: int, row_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var n: int = 0
var col_id: int = -1
var row_id: int = -1
var has_been_marked = false
var is_markable = false

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


func mark(mark_type: int):
	$PanelContainer.add_theme_stylebox_override("panel", stylebox_orange)
	$PanelContainer/Label/Button.visible = true
	is_markable = true

func auto_press():
	print("Number %s wants to autopress" % n)
	$PanelContainer/Label/Button.emit_signal("pressed")

func _on_button_pressed() -> void:
	$PanelContainer/Label/Button.visible = false
	$PanelContainer.add_theme_stylebox_override("panel", stylebox_green)
	has_been_marked = true
	is_markable = false
	number_pressed.emit(n, row_id)
