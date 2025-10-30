extends Control

var auth_script = preload("res://scripts/Auth/auth.gd").new()

@onready var shader_material := material as ShaderMaterial

func _ready():
	auth_script.name = "AuthScript"
	get_node("/root").add_child.call_deferred(auth_script)
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	_on_theme_changed(ThemeManager.current_theme)
	
	Global.user = auth_script.load_token()
	if Global.user != {}:
		if Global.user.token != "":
			updateScene("Gameboarder")
	else:
		updateScene("Index")
	
func _on_theme_changed(new_theme: Theme):
	get_tree().root.theme = new_theme

	if new_theme.resource_name == "light_theme":
		set_theme_colors(Color("#d1bbe0"), Color("#452e52"))
	else:
		set_theme_colors(Color("160c1cff"), Color("593d6aff"))
		
	_apply_theme_recursive(self, new_theme)

func _apply_theme_recursive(node: Node, new_theme: Theme):
	for child in node.get_children():
		if !child is AnimationPlayer:
			if child.has_method("set") and "theme" in child:
				child.theme = new_theme
			_apply_theme_recursive(child, new_theme)

func set_theme_colors(center: Color, outer: Color):
	$Background.material.set_shader_parameter("color_center", center)
	$Background.material.set_shader_parameter("color_outer", outer)
	
func showError(error_label : Label, error_message : String):
	error_label.text = error_message
	error_label.show()

func updateScene(scene: String = "Index"):
	if scene == "Index":
		var index_path = str("res://scenes/", scene, ".tscn")
		_load_scene(scene, index_path)
	else:
		GameBoarder.auth.me(func(_code,response):
			if response.has("id"):
				if !Global.user.has("name"):
					Global.user["name"] = response.name
					Global.user["email"] = response.email
				var scene_path = str("res://scenes/Screen/", scene, ".tscn")
				_load_scene(scene, scene_path)
			else:
				updateScene()
				return
		)
		
func _load_scene(scene: String, scene_path: String):
	var scene_loaded = load(scene_path)
	if scene == "Gameboarder" or scene == "Index":
		if $Background.get_node_or_null("Gameboard"):
			if $Background.get_node("Gameboard").get_children().size() > 2:
				pass
		else:
			for child in $Background.get_children():
				if child.name != "LightModSwitch":
					$Background.remove_child.call_deferred(child)
					child.queue_free()
			$Background.add_child.call_deferred(scene_loaded.instantiate())
			return
	
	if $Background.get_node_or_null("Gameboarder"):
		$Background.get_node("Gameboarder/Home").hide()
		
		for child in $Background.get_node("Gameboarder").get_children():
			if child.name != "Home" and child.name != "MenuBar":
				$Background.get_node("Gameboarder").remove_child.call_deferred(child)
				child.queue_free()
		$Background.get_node("Gameboarder").add_child.call_deferred(scene_loaded.instantiate())
	
	
