extends CanvasLayer

@onready var text_label = $Container/Label

func _on_check_button_toggled(toggled_on: bool) -> void:
	match toggled_on:
		false:
			text_label.text = tr("LIGHT_MODE")
			
		true:
			text_label.text = tr("DARK_MODE")
	
	ThemeManager.set_theme(toggled_on)
