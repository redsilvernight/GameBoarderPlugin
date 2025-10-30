extends Node

signal language_changed

func _ready():
	load_language()

func change_language(lang: String):
	TranslationServer.set_locale(lang)
	save_language(lang)
	language_changed.emit()

func save_language(lang: String):
	var config = ConfigFile.new()
	config.set_value("settings", "language", lang)
	config.save("user://settings.cfg")

func load_language():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var lang = config.get_value("settings", "language", "en")
		TranslationServer.set_locale(lang)
		Global.current_language = lang
