extends Node

signal login_completed(result)

var password_rules: String = r"^(?=.*[A-Z])(?=.*\d).{6,}$" # 6 characters && 1 Uppercase && 1 Number
var password_regex: RegEx

@onready var main_node = get_node("/root/Main")

func _ready() -> void:
	password_regex = RegEx.new()
	password_regex.compile(password_rules)
	
func register(register_form : VBoxContainer, error_label: Label):
	var input_email = register_form.get_node("Email/Input").text
	var input_username = register_form.get_node("Username/Input").text
	var input_password = register_form.get_node("Password/Input").text
	var input_password_confirmation = register_form.get_node("PasswordConfirmation/Input").text
	
	if !input_email.is_empty() and !input_username.is_empty() and !input_password.is_empty() and !input_password_confirmation.is_empty():
		if password_regex.search(input_password):
			if input_password == input_password_confirmation:
				GameBoarder.auth.register(input_email, input_username, input_password, func(_code, response):
					if !response.has("errors"):
						login(error_label, input_email, input_password, true)
					else:
						main_node.showError(error_label, response.errors.values()[0])
						return
				)
			else:
				main_node.showError(error_label, tr("PASSWORD_FIELD_DONT_MATCH"))
				return
		else:
			main_node.showError(error_label, tr("PASSWORD_WRONG_FORMAT"))
			return
	else:
		main_node.showError(error_label, tr("ALL_FIELD_REQUIRED"))
		return

func login(error_label: Label,email: String = "", password: String = "", remember_me: bool = false):
	if email == "" and password == "":
		main_node.showError(error_label, tr("ALL_FIELD_REQUIRED"))
		login_completed.emit(null)
		return
	
	GameBoarder.auth.login(email, password, func(_code, response):
		if !response.has("errors"):
			if !response.has("message"):
				if remember_me:
					saveToken(response.access_token, response.user.id)
				
				var result = {"token": response.access_token, "id": int(response.user.id), "username": str(response.user.name), "email": str(response.user.email)}
				login_completed.emit(result)
			else:
				main_node.showError(error_label, response.message)
				login_completed.emit(null)
		else:
			main_node.showError(error_label, response.errors.values()[0][0])
			login_completed.emit(null)
	)
	
func logout():
	GameBoarder.auth.logout(func(_code, response):
		if response.has("message"):
			Global.user = {}
			main_node.updateScene()	
	)

func saveToken(token: String, user_id: int):
	var config = ConfigFile.new()
	config.set_value("auth", "token", token)
	config.set_value("auth", "user_id", user_id)
	config.save("user://auth.cfg")
	
func load_token() -> Dictionary:
	var config = ConfigFile.new()
	if config.load("user://auth.cfg") == OK:
		return {"token": config.get_value("auth", "token", ""), "id": config.get_value("auth", "user_id", "")}
	return {}
