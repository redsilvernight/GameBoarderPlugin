extends Tree

var table_columns: Dictionary
var _is_selectable: bool = false

func setup(all_columns: Dictionary, selectable: bool = false, theme_variation: String = ""):
	clear()
	theme_type_variation = theme_variation
	column_titles_visible = true
	_is_selectable = selectable
	select_mode = Tree.SELECT_ROW
	table_columns = all_columns
	columns = all_columns.size()
	var id_column: int = 0
	
	for column in all_columns:
		set_column_title(id_column, column)
		id_column += 1

func hydrate(data: Array):
	var root = create_item()
	for row in data:
		var item = create_item(root)
		item.set_metadata(0, int(row["id"]))
		
		if not _is_selectable:
			for i in range(columns):
				item.set_selectable(i, false)
			
		for i in range(columns):
			var column_name = get_column_title(i)
			
			if column_name.to_lower() == tr("DELETE").to_lower() :
				var delete_icon = getResizedIcon("res://assets/trash.png", 24)
				item.add_button(i, delete_icon)
			elif table_columns[column_name]:
				item.set_text(i, str(row[table_columns[column_name]]))

func getResizedIcon(path: String, new_size: int = 24) -> ImageTexture:
	var texture = load(path)
	var image = texture.get_image()
	image.resize(new_size, new_size, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)
