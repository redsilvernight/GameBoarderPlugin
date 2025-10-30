extends Control

var add_menu_is_open: bool = false
var max_size_name: int = 54
var data_table

@onready var main = get_node("/root/Main")
@onready var menu = get_node("/root/Main/Background/Gameboarder/MenuBar")

func _ready() -> void:
	data_table = load("res://scenes/table.tscn").instantiate()
	$Background/VBoxContainer/Table.add_child(data_table)
	getGames()
	data_table.button_clicked.connect(_on_delete_button_clicked)
	
func _on_add_game_button_pressed() -> void:
	$Background/VBoxContainer/AddMenu/Panel/ErrorLabel.hide()
	addMenuUpdate()

func addMenuUpdate() -> void:
	var button_texture = $Background/VBoxContainer/Header/AddGameButton/TextureRect
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
	addGame()

func addGame() -> void:
	var error_label = $Background/VBoxContainer/AddMenu/Panel/ErrorLabel
	var input_game = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit.text.capitalize()
	var input_save_mode = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.selected
	var save_mode: String
	var max_save_slot: int
	
	if input_game.length() > 0:
		if input_game.length() < max_size_name:
			save_mode = "single" if input_save_mode == 0 else "multiple"
			if save_mode == "multiple":
				max_save_slot = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/MaxSaveSlotInput/SpinBox.value
			else:
				max_save_slot = 1
			GameBoarder.game.newGame(input_game, save_mode, max_save_slot, func(_code, response):
				if response.has("id"):
					$Background/VBoxContainer/AddMenu.hide()
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit.text = ""
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/MaxSaveSlotInput.hide()
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/MaxSaveSlotInput/SpinBox.value = 3
					$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.selected = 0
					
					add_menu_is_open = false
					menu.updateCurrentGame()
					getGames()
				else:
					main.showError(error_label, response.errors.values()[0][0])
			)
		else:
			main.showError(error_label, str(tr("GAME_TO_LONG"), max_size_name, tr("CHARS")))
	else:
		main.showError(error_label, tr("ALL_FIELD_REQUIRED"))
		
func getGames() -> void:
	GameBoarder.game.getGames(Global.user.id, func(_code, response):
		print(response)
		var all_games = response
		viewAllGame(all_games)
	)

func viewAllGame(all_games: Array) -> void:
	data_table.setup({"id" : "id", tr("NAME") : "name",tr("SAVE_MODE") : "save_mode", tr("MAX_SAVE_SLOT") : "max_save_slots", tr("CREATED_AT") : "created_at", tr("DELETE"): null})
	data_table.hydrate(all_games)
	
func _on_delete_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	var item_id = item.get_metadata(0)
	GameBoarder.game.delete(item_id, func(_code, response):
		if response.has("message"):
			if Global.current_game != {}:
				if item_id == Global.current_game.values()[0]:
					Global.current_game = {}
			menu.updateCurrentGame()
			getGames()	
	)

func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/MaxSaveSlotInput.hide()
	else:
		$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/MaxSaveSlotInput.show()
