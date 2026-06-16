extends "res://app/src/main/cpp/gui_save_item.gd"

## GUISaveItem for auto save slot is made into a different scene due to
## different layout.

func _set_info() -> void:
	super()
	if not empty:
		$Name/AutoSave/ecText.text = _native.g_string_table.get_string("AutoSave")
	else:
		$Name/AutoSave/ecText.text = ""


func _make_time_string() -> String:
	return "%02d:%02d\n%04d/%02d/%02d"%[hour, minute, year, month, day]
