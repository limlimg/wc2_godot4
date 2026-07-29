@tool
extends GUISaveItem

## GUISaveItem for auto save slot is made into a different scene due to
## different layout.

func _set_info() -> void:
	super()
	if not empty:
		$Name/ecText/AutoSave/ecText.text = "AutoSave"
	else:
		$Name/ecText/AutoSave/ecText.text = ""


func _make_time_string() -> String:
	return "%02d:%02d\n%04d/%02d/%02d"%[hour, minute, year, month, day]
