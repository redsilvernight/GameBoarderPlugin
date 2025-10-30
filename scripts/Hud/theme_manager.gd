extends Node

signal theme_changed(new_theme: Theme)

@onready var light_theme: Theme = load("res://themes/light_theme.tres")
@onready var dark_theme: Theme = load("res://themes/dark_theme.tres")

var current_theme: Theme
var is_dark_mode :bool


func _ready():
	set_theme(false)

func set_theme(is_dark: bool):
	is_dark_mode = is_dark
	current_theme = dark_theme if is_dark else light_theme

	# Notifie les UI actives
	emit_signal("theme_changed", current_theme)
