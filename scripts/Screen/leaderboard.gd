extends Control

var add_menu_is_open: bool = false
var max_size_name: int = 24
var data_table

@onready var main = get_node("/root/Main")

func _ready() -> void:
	if Global.current_game == {}:
		$Background/VBoxContainer/Header/AddBoardButton.disabled = true
		$Background/VBoxContainer/WarningLabel.show()
	else:
		$Background/VBoxContainer/Header/AddBoardButton.disabled = false
		$Background/VBoxContainer/WarningLabel.hide()
		$Background/VBoxContainer/Header/Label.text = str(Global.current_game.keys()[0], " ", "leaderboard")
		data_table = load("res://scenes/table.tscn").instantiate()
		$Background/VBoxContainer/Table.add_child(data_table)
		getLeaderboard()
		data_table.button_clicked.connect(_on_delete_button_clicked)
		data_table.item_selected.connect(_on_item_selected)
	
func _on_add_board_button_pressed() -> void:
	$Background/VBoxContainer/AddMenu.hide()
	addMenuUpdate()

func addMenuUpdate() -> void:
	var button_texture = $Background/VBoxContainer/Header/AddBoardButton/TextureRect
	add_menu_is_open = !add_menu_is_open
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if add_menu_is_open:
		$Background/VBoxContainer/AddMenu.show()
		tween.tween_property(button_texture, "rotation", deg_to_rad(45), 0.3)
	else:
		$Background/VBoxContainer/AddMenu.hide()
		tween.tween_property(button_texture, "rotation", deg_to_rad(0), 0.3)

func _on_submit_button_pressed() -> void:
	$Background/VBoxContainer/AddMenu/Panel/ErrorLabel.hide()
	addLeaderboard()
	
func addLeaderboard() -> void:
	var error_label = $Background/VBoxContainer/AddMenu/Panel/ErrorLabel
	var input_leaderboard = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text.capitalize()
	var input_is_unique = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/IsUniqueInput/CheckBox.button_pressed

	if input_leaderboard.length() > 0:
		if input_leaderboard.length() < max_size_name:
			GameBoarder.leaderboard.newLeaderboard(input_leaderboard, input_is_unique, Global.current_game.values()[0], func(_code, response):
				if !response.has("error"):
					$Background/VBoxContainer/AddMenu.hide()
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text = ""
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/IsUniqueInput/CheckBox.button_pressed = false
					add_menu_is_open = false
					getLeaderboard()
				else:
					main.showError(error_label, response.error)
			)
		else:
			main.showError(error_label, str(tr("LEADERBOARD_TO_LONG"), max_size_name, tr("CHARS")))
	else:
		main.showError(error_label, tr("ALL_FIELD_REQUIRED"))

func getLeaderboard() -> void :
	GameBoarder.game.getLeaderboard(Global.current_game.values()[0], func(_code, response):
		var all_leaderboards = response
		viewAllLeaderboard(all_leaderboards)
	)

func viewAllLeaderboard(all_leaderboards: Array):
	data_table.setup({"id": "id", tr("NAME") : "name", tr("SCORE_UNIQUE") : "is_unique", tr("CREATED_AT") : "created_at", tr("DELETE"): null}, true, "tree_selected")
	data_table.hydrate(all_leaderboards)

func _on_delete_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	GameBoarder.leaderboard.delete(item.get_metadata(0), func(_code, response):
		if response.has("message"):
			getLeaderboard()	
	)

func _on_item_selected():
	var selected_item = data_table.get_selected()
	if selected_item:
		var item_id = selected_item.get_metadata(0)
		viewLeaderboard(item_id)
		

func viewLeaderboard(leaderboard_id: int):
	_clear_view()
	GameBoarder.leaderboard.getLeaderboard(leaderboard_id, func(_code, response):
		if response.has("id"):
			var new_view = preload("res://scenes/Screen/ViewLeaderboard.tscn").instantiate()
			new_view.setup(response)
			$Background.add_child(new_view)
			$Background/VBoxContainer.hide()
	)
	
func _clear_view(_is_index: bool = false):
	for child in $Background.get_children():
			if child.name != "VBoxContainer":
				$Background.remove_child(child)
				child.queue_free()
	if _is_index:
		$Background/VBoxContainer.show()
