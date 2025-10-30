extends Control

var data_table

func _ready() -> void:
	if Global.current_game == {}:
		$Background/VBoxContainer/WarningLabel.show()
	else:
		$Background/VBoxContainer/WarningLabel.hide()
		$Background/VBoxContainer/Header/Label.text = str(Global.current_game.keys()[0], " ", "save")
		data_table = load("res://scenes/table.tscn").instantiate()
		$Background/VBoxContainer/Table.add_child(data_table)
		getSave()
		data_table.button_clicked.connect(_on_delete_button_clicked)

func getSave() -> void :
	GameBoarder.game.getSaves(Global.current_game.values()[0], func(_code, response):
		var all_saves = response.data
		viewAllSave(all_saves)
	)

func viewAllSave(all_saves: Array):
	data_table.setup({"id": "id",tr("NAME") : "player_pseudo", tr("SLOT") : "slot", tr("UPDATED_AT") : "updated_at", tr("FILE_SIZE") : "file_size", tr("DELETE"): null})
	data_table.hydrate(all_saves)

func _on_delete_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	GameBoarder.save.delete(item.get_metadata(0), func(_code, response):
		if response.has("message"):
			getSave()	
	)
