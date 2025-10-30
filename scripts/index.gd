extends Control

@onready var main = get_node("/root/Main")
@onready var register_form = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/REGISTER/CenterContainer/RegisterForm
@onready var login_form = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/LOGIN/CenterContainer/LoginForm
@onready var error_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Error

func _ready() -> void:
	error_label.hide()
	
func _on_login_button_pressed() -> void:
	var input_email = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/LOGIN/CenterContainer/LoginForm/Email/Input.text
	var input_password = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/LOGIN/CenterContainer/LoginForm/Password/Input.text
	var remember_me = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/LOGIN/CenterContainer/LoginForm/RememberMe.button_pressed
	
	main.auth_script.login(error_label, input_email, input_password, remember_me)
	Global.user = await main.auth_script.login_completed
	if Global.user != null:
		get_node("/root/Main").updateScene("Gameboarder")


func _on_register_button_pressed() -> void:
	main.auth_script.register(register_form, error_label)
	Global.user = await main.auth_script.login_completed
	if Global.user != null:
		get_node("/root/Main").updateScene("Gameboarder")
	
func _on_tab_container_tab_changed(_tab: int) -> void:
	if error_label and error_label.visible:
		error_label.hide()
