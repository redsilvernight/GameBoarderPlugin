extends OptionButton

var all_locale = { "en" : 0, "fr" : 1}

func _ready() -> void:
	if Global.current_language == "":
		var new_language = all_locale["en"]
		if all_locale.has(OS.get_locale().split("_")[0]):
			new_language = all_locale[OS.get_locale().split("_")[0]]
			
		_on_language_selected(new_language)
	selected = all_locale[Global.current_language]
		
	item_selected.connect(_on_language_selected)

func _on_language_selected(index: int):
	match index:
		0:
			LanguageManager.change_language("en")
			Global.current_language = "en"
		1:
			LanguageManager.change_language("fr")
			Global.current_language = "fr"
