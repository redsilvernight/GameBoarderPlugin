extends Control

var add_menu_is_open: bool = false
var current_leaderboard: Dictionary = {}
var data_table

@onready var leaderboard = get_parent().get_parent()
@onready var main = get_node("/root/Main")

func _ready() -> void:
	data_table = load("res://scenes/table.tscn").instantiate()
	$Background/VBoxContainer/Table.add_child(data_table)
	getScoredLeaderboard()
	data_table.button_clicked.connect(_on_delete_button_clicked)

func setup(leaderboard_data: Dictionary):
	current_leaderboard = leaderboard_data
	$Background/VBoxContainer/Header/Label.text = str(current_leaderboard.name, " score")

func _on_return_button_pressed() -> void:
	leaderboard._clear_view(true)
	
func _on_add_score_button_pressed() -> void:
	$Background/VBoxContainer/AddMenu.hide()
	addMenuUpdate()

func addMenuUpdate() -> void:
	var button_texture = $Background/VBoxContainer/Header/AddScoreButton/TextureRect
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
	addHighscore()
	
func addHighscore():
	var error_label = $Background/VBoxContainer/AddMenu/Panel/ErrorLabel
	var input_name: String = $Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text
	var input_score: int = int($Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/ScoreInput/LineEdit.text)
	
	if !input_name.is_empty() and input_score != 0:
		GameBoarder.player.getByName(input_name, Global.current_game.values()[0], func(_code, response):
			if response.has("id"):
				GameBoarder.score.newHighscore(response.id, current_leaderboard.id, input_score, func(_new_code, new_response):
					if new_response.has("id"):
						$Background/VBoxContainer/AddMenu.hide()
						$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/NameInput/LineEdit.text = ""
						$Background/VBoxContainer/AddMenu/Panel/HBoxContainer/VBoxContainer/ScoreInput/LineEdit.text = ""
						add_menu_is_open = false
						getScoredLeaderboard()
					else:
						main.showError(error_label, new_response.message)
				)
			else:
				main.showError(error_label, response.error)
		)
	else:
		main.showError(error_label, tr("ALL_FIELD_REQUIRED"))

func getScoredLeaderboard() -> void :
	GameBoarder.leaderboard.getScoredLeaderboard(current_leaderboard.id, func(_code, response):
		var all_scores = response
		viewAllScores(all_scores)
	)
	
func viewAllScores(all_scores: Array):
	data_table.setup({"id": "id",tr("PLAYER") : "player_name", "Score" : "score", tr("CREATED_AT") : "created_at", tr("DELETE"): null})
	data_table.hydrate(all_scores)

func _on_delete_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	GameBoarder.score.delete(item.get_metadata(0), func(_code, response):
		if response.has("message"):
			getScoredLeaderboard()	
	)
