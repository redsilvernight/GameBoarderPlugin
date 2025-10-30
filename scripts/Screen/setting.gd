extends Control

var remove_cooldown = 10
var timer: Timer

func _ready() -> void:
	$Background/MarginContainer/VBoxContainer/AllSettings/ApiSettings/Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label.text = str(Global.user.values()[0])
	$Background/MarginContainer/VBoxContainer/AllSettings/AccountSettings/Panel/MarginContainer/HBoxContainer/VBoxContainer/Username.text = Global.user.name
	$Background/MarginContainer/VBoxContainer/AllSettings/AccountSettings/Panel/MarginContainer/HBoxContainer/VBoxContainer/Email.text = Global.user.email

func _on_timer_timeout():
	$AcceptRemoveAccountDialog.ok_button_text = str(remove_cooldown)
	remove_cooldown -= 1
	
	if remove_cooldown < 0:
		timer.stop()
		
		$AcceptRemoveAccountDialog.ok_button_text = tr("DELETE_ACCOUNT")
		
func _on_empty_cache_pressed() -> void:
	$AcceptClearCacheDialog.show()

func _on_delete_account_pressed() -> void:
	if !timer:
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(_on_timer_timeout)
	else:
		timer.stop()
		
	timer.start(1.0)
	$AcceptRemoveAccountDialog.show()
	
func emptyCache() -> void:
	DirAccess.remove_absolute("user://auth.cfg")
	DirAccess.remove_absolute("user://settings.cfg")

func _on_accept_clear_cache_dialog_confirmed() -> void:
	emptyCache()

func _on_accept_remove_account_dialog_confirmed() -> void:
	if remove_cooldown < 0:
		GameBoarder.auth.deleteAccount(Global.user.id, func(_code, response):
			if response.has("message"):
				emptyCache()
				get_tree().root.get_node("Main").auth_script.logout()
		)
	else:
		$AcceptRemoveAccountDialog.show()

func _on_accept_remove_account_dialog_canceled() -> void:
	if timer:
		if !timer.is_stopped():
			timer.stop()
		
	remove_cooldown = 10
	$AcceptRemoveAccountDialog.ok_button_text = str(remove_cooldown)
	
func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(str(Global.user.values()[0]))
