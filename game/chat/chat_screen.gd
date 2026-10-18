extends RichTextLabel

var links = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.printjson.connect(_on_message_received)
	for slot in Archipelago.conn.slots:
		if Archipelago.conn.player_id in slot.group_members:
			links.append(slot.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_message_received(json: Dictionary, plain: String):
	var to_print: String = ""
	if json.has("type"):
		var msg_type = json["type"]
		match msg_type:
			"Chat":
				to_print = _parse_chat_message(json["slot"],json["message"])
			"Tutorial":
				to_print = " " # Don't print for now
			"Hint":
				#if json["found"] == false: TODO DO THE CHECK
					to_print = _parse_hint_message(json)
			"ItemSend":
				to_print = _parse_itemsend_message(json)
	
	if to_print == "":
		to_print = "[color=a3a3a3ff]%s[/color]" % plain + "\n"# Failsafe Handle
	append_text(to_print)

func _parse_chat_message(player_slot: int, message: String) -> String:
	var msg_return: String 
	msg_return = "[color=%s]%s:[/color] %s\n" % [_is_player_self_color(player_slot),_escape_bbcode(Archipelago.conn.get_player_name(player_slot)), _escape_bbcode(message)]

	return msg_return
	
func _parse_hint_message(json: Dictionary):
	var message: String
	
	var item_id = int(json["item"]["item"])
	var location_id = int(json["item"]["location"])
	var sending_player = int(json["item"]["player"])
	var receiving_player = int(json["receiving"])
	
	var is_found: String = ""
	if (json["found"]):
		is_found = ". (found)"
	else:
		is_found="."
	
	var sending_player_data = Archipelago.conn.get_gamedata_for_player(sending_player)
	var receiving_player_data = Archipelago.conn.get_gamedata_for_player(receiving_player)
	
	var item_name = receiving_player_data.get_item_name(item_id)
	var location_name = sending_player_data.get_loc_name(location_id)
	var receiving_name = Archipelago.conn.get_player_name(receiving_player)
	var sending_name = Archipelago.conn.get_player_name(sending_player)
	var item_color = _get_item_progtype_color(int(json["item"]["flags"]))
	var receiving_color = _is_player_self_color(receiving_player)
	var sending_color = _is_player_self_color(sending_player)
	var location_color = "009300"
	var entrance_color = "4b7f4c"
	#Color("4b7f4cff")
	
	var entrance_message: String = ""
	for elem in json["data"]:
		if elem.has("type"):
			if elem["type"] == "entrance_name":
				entrance_message = " at [color=%s]%s[/color]" % [entrance_color, elem["text"]]
	
	
	message = "[Hint]: [color=%s]%s[/color]'s [color=%s]%s[/color] is in [color=%s]%s[/color] of [color=%s]%s[/color]%s%s\n" % [receiving_color, _escape_bbcode(receiving_name), item_color, _escape_bbcode(item_name), location_color, _escape_bbcode(location_name), sending_color, _escape_bbcode(sending_name), entrance_message, is_found]
	
	return message

func _parse_itemsend_message(json: Dictionary):
	var message: String
	
	var item_id = int(json["item"]["item"])
	var location_id = int(json["item"]["location"])
	var sending_player = int(json["item"]["player"])
	var receiving_player = int(json["receiving"])
	
	var sending_player_data = Archipelago.conn.get_gamedata_for_player(sending_player)
	var receiving_player_data = Archipelago.conn.get_gamedata_for_player(receiving_player)
	
	var item_name = receiving_player_data.get_item_name(item_id)
	var location_name = sending_player_data.get_loc_name(location_id)
	var receiving_name = Archipelago.conn.get_player_name(receiving_player)
	var sending_name = Archipelago.conn.get_player_name(sending_player)
	var item_color = _get_item_progtype_color(int(json["item"]["flags"]))
	var receiving_color = _is_player_self_color(receiving_player)
	var sending_color = _is_player_self_color(sending_player)
	var location_color = "009300"
	
	message = item_color
	if sending_name == receiving_name:
		message = "[color=%s]%s[/color] has found their [color=%s]%s[/color] ([color=%s]%s[/color])\n" % [sending_color, _escape_bbcode(sending_name), item_color, _escape_bbcode(item_name), location_color, _escape_bbcode(location_name)]
	else:
		message = "[color=%s]%s[/color] has found [color=%s]%s[/color]'s [color=%s]%s[/color] ([color=%s]%s[/color])\n" % [sending_color, _escape_bbcode(sending_name), receiving_color, _escape_bbcode(receiving_name), item_color, _escape_bbcode(item_name), location_color, _escape_bbcode(location_name)]
	# Check Hinted
	for hint in Archipelago.conn.hints:
		var item = hint.item
		if item.src_player_id == sending_player and \
		item.dest_player_id == receiving_player and \
		sending_player == Archipelago.conn.get_player().slot and \
		location_id == item.loc_id:
			var hint_color = "d72f7cff"
			var hint_message = "[color=%s]Notice: The item above was hinted![/color]" % hint_color
			
			message = message + "%s\n" % hint_message

	return message

func _escape_bbcode(msg: String) -> String:
	return msg.replace("[","[lb]")
	
func _is_player_self_color(player_slot: int) -> String:
	print("test name is %s" % Archipelago.conn.get_slot(player_slot).name)
	if player_slot == Archipelago.conn.player_id or Archipelago.conn.get_slot(player_slot).name in links:
		return "ef960c"
	return "f5f5dc"
	
func _get_item_progtype_color(flag: int) -> String:
	if flag == 1 or flag == 3 or flag == 5 or flag == 7:
		return "9735d9"
	elif flag == 2 or flag == 6:
		return "6eb3e4"
	elif flag == 4:
		return "ff4500"
	else:
		return "a7a7a7"
