extends Node

const save_location = "user://elude_data.json"

var content_to_save: Dictionary = {
	"progress_bar_value": 0.0
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(content_to_save.duplicate())
	file.close()
	
func _load():
	if FileAccess.file_exists(save_location):
		var file = FileAccess.open(save_location, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		content_to_save = save_data
