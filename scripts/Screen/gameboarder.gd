extends Control

@onready var main = get_node("/root/Main")

func _ready() -> void:
	$Home/MarginContainer/VBoxContainer/VBoxContainer2/Title.text = str(tr("WELCOME_BACK"), " ", Global.user.name)
	GameBoarder.game.getGames(Global.user.id, func(_code, response):
		if response.size() > 0:
			if response[0].has("id"):
				$Home/MarginContainer/VBoxContainer/VBoxContainer/ProjetSummary/HBoxContainer/TotalGame/VBoxContainer/Label.text = str(response.size())
				$Home/MarginContainer/VBoxContainer/VBoxContainer/ProjetSummary/HBoxContainer/LastAdded/VBoxContainer/Label2.text = getMostRecentGame(response)
				$Home/MarginContainer/VBoxContainer/VBoxContainer/ProjetSummary/HBoxContainer/LastUpdated/VBoxContainer/Label.text = getMostRecentUpdate(response)
		else:
			$Home/MarginContainer/VBoxContainer/VBoxContainer/ProjetSummary/HBoxContainer/TotalGame/VBoxContainer/Label.text = "0"
	)

func getMostRecentGame(array: Array) -> String:
	if array.is_empty():
		return ""
	
	var most_recent = array[0]
	var most_recent_unix = get_unix_from_french_date(most_recent.created_at)
	
	for item in array:
		var item_unix = get_unix_from_french_date(item.created_at)
		if item_unix > most_recent_unix:
			most_recent = item
			most_recent_unix = item_unix
	
	return most_recent.created_at

func getMostRecentUpdate(array: Array) -> String:
	if array.is_empty():
		return ""
	
	var most_recent = array[0]
	var most_recent_unix = get_unix_from_french_date(most_recent.updated_at)
	
	for item in array:
		var item_unix = get_unix_from_french_date(item.updated_at)
		if item_unix > most_recent_unix:
			most_recent = item
			most_recent_unix = item_unix
	
	return most_recent.updated_at

func get_unix_from_french_date(french_date: String) -> int:
	# Format: "27/10/2025 à 21:31"
	var parts = french_date.split(" à ")
	var date_parts = parts[0].split("/")
	var time_parts = parts[1].split(":")
	
	var datetime_dict = {
		"year": int(date_parts[2]),
		"month": int(date_parts[1]),
		"day": int(date_parts[0]),
		"hour": int(time_parts[0]),
		"minute": int(time_parts[1]),
		"second": 0
	}
	
	return Time.get_unix_time_from_datetime_dict(datetime_dict)
	
func _on_game_button_pressed() -> void:
	main.updateScene("Game")

func _on_player_button_pressed() -> void:
	main.updateScene("Player")

func _on_leaderboard_button_pressed() -> void:
	main.updateScene("Leaderboard")

func _on_settings_button_pressed() -> void:
	main.updateScene("Setting")

func _on_my_games_pressed() -> void:
	main.updateScene("Game")

func _on_save_button_pressed() -> void:
	main.updateScene("Save")
