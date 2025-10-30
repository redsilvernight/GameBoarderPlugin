extends Control

var add_menu_is_open: bool = false
var password_rules: String = r"^(?=.*[A-Z])(?=.*\d).{6,}$" # 6 characters && 1 Uppercase && 1 Number
var password_regex: RegEx
var data_table

@onready var main = get_node("/root/Main")

func _ready() -> void:
	if Global.current_game == {}:
		$Background/VBoxContainer/Header/AddPlayerButton.disabled = true
		$Background/VBoxContainer/WarningLabel.show()
	else:
		$Background/VBoxContainer/Header/AddPlayerButton.disabled = false
		$Background/VBoxContainer/WarningLabel.hide()
		$Background/VBoxContainer/Header/Label.text = str(Global.current_game.keys()[0], " ", tr("PLAYER_LIST"))
		password_regex = RegEx.new()
		password_regex.compile(password_rules)
		data_table = load("res://scenes/table.tscn").instantiate()
		$Background/VBoxContainer/Table.add_child(data_table)
		getPlayers()
		data_table.button_clicked.connect(_on_delete_button_clicked)
		
func _on_add_player_button_pressed() -> void:
	$Background/VBoxContainer/AddMenu.hide()
	addMenuUpdate()

func addMenuUpdate() -> void:
	var button_texture = $Background/VBoxContainer/Header/AddPlayerButton/TextureRect
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
	addPlayer()

func addPlayer() -> void:
	var error_label = $Background/VBoxContainer/AddMenu/Panel/ErrorLabel
	var input_name = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text
	var input_password = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/PasswordInput/LineEdit.text
	var input_password_confirm = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/PasswordConfirmInput/LineEdit.text

	if !input_name.is_empty() and !input_password.is_empty() and !input_password_confirm.is_empty():
		if password_regex.search(input_password):
			if input_password == input_password_confirm:
				GameBoarder.player.newPlayer(input_name, input_password, Global.current_game.values()[0], func(_code, response):
					if !response.has("errors"):
						$Background/VBoxContainer/AddMenu.hide()
						$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text = ""
						$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/PasswordInput/LineEdit.text = ""
						$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/PasswordConfirmInput/LineEdit.text = ""
						add_menu_is_open = false
						getPlayers()
					else:
						main.showError(error_label, response.errors.values()[0][0])
				)
			else:
				main.showError(error_label, tr("PASSWORD_FIELD_DONT_MATCH"))
				return
		else:
			main.showError(error_label, tr("PASSWORD_WRONG_FORMAT"))
			return
	else:
		main.showError(error_label, tr("ALL_FIELD_REQUIRED"))
		return
	
func getPlayers() -> void :
	GameBoarder.game.getPlayers(Global.current_game.values()[0], func(_code, response):
		var all_players = response
		viewAllPlayers(all_players)
	)

func viewAllPlayers(all_players: Array):
	data_table.setup({"id": "id",tr("NAME") : "name", tr("CREATED_AT") : "created_at", tr("DELETE"): null})
	data_table.hydrate(all_players)

func _on_delete_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	GameBoarder.player.delete(item.get_metadata(0), func(_code, response):
		if response.has("message"):
			getPlayers()	
	)
