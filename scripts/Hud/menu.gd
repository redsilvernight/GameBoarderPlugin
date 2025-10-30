extends CanvasLayer

var is_open: bool = false
@onready var main = get_node("/root/Main")
@onready var gameSelect = $Control/Menu/ArrowMenu/MenuControl/CurrentGameMenu/GameSelect

func _ready() -> void:
	ThemeManager.theme_changed.connect(_on_theme_changed)
	_on_theme_changed(ThemeManager.current_theme)
	updateCurrentGame()

func _on_theme_changed(new_theme: Theme):
	$Control.theme = new_theme
	_apply_theme_recursive(self, new_theme)

func _apply_theme_recursive(node: Node, new_theme: Theme):
	for child in node.get_children():
		if !child is AnimationPlayer:
			if child.has_method("set") and "theme" in child:
				child.theme = new_theme
			_apply_theme_recursive(child, new_theme)

func _on_button_pressed() -> void:
	updateMenu()

func updateCurrentGame():
	GameBoarder.game.getGames(Global.user.id, func(_code, response):
		var all_games = {}
		for item in response:
			all_games[item.name] = item.id
		
		gameSelect.clear()
		gameSelect.add_item(tr("SELECT_GAME"))
		gameSelect.set_item_metadata(0, null)
		for game in all_games:
			gameSelect.add_item(game)
			gameSelect.set_item_metadata(gameSelect.item_count - 1, all_games[game])
		
		if Global.current_game != {}:
			var default_game = Global.current_game.keys()[0]
			for i in range(gameSelect.item_count):
				if gameSelect.get_item_text(i) == default_game:
					gameSelect.select(i)
					break
		else:
			gameSelect.select(0)
	)
	
func updateMenu()-> void:
	match is_open:
		true:
			$Control/Menu/ArrowMenu/Button/TextureRect.flip_h = false
			$AnimationPlayer.play("close_menu")
			is_open = false
		false:
			$Control/Menu/ArrowMenu/Button/TextureRect.flip_h = true
			$AnimationPlayer.play("open_menu")
			is_open = true

func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_logout_button_pressed() -> void:
	get_tree().root.get_node("Main").auth_script.logout()
	
func _on_setting_button_pressed() -> void:
	main.updateScene("Setting")
	updateMenu()

func _on_game_button_pressed() -> void:
	main.updateScene("Game")
	updateMenu()

func _on_player_button_pressed() -> void:
	main.updateScene("Player")
	updateMenu()

func _on_leaderboard_bouton_pressed() -> void:
	main.updateScene("Leaderboard")
	updateMenu()

func _on_save_bouton_pressed() -> void:
	main.updateScene("Save")
	updateMenu()
	
func _on_home_button_pressed() -> void:
	main.updateScene("Gameboarder")
	updateMenu()

func _on_game_select_item_selected(index: int) -> void:
	if index != 0:
		var selected_game = {
			gameSelect.get_item_text(index): gameSelect.get_item_metadata(index)
		}
		
		Global.current_game = selected_game
