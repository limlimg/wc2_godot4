extends "res://app/src/main/cpp/native-lib.gd"

## The .fnt files are imported as FontFile. Reimport if the coresponding image
## changes (including when an @2x variant is added).
##
## GetCharImage is not implemented. In the original game code, it is only used
## by ecText to draw text. In this port, it looks like its implementation will
## either be complicated or put constraint on the type of Font to use.

var font: Font
var font_size: int

func init(file_name: String, hd: bool) -> void:
	var old_font = font
	font = load(get_path(file_name, "")) as FontFile
	if font == null:
		font = old_font
		return
	if old_font != null:
		font.fallbacks.append(old_font)# Theoretically, in the orignal game code, Init can be called multiple times to get a combined font.
	var file_name_hd = file_name.substr(file_name.rfind('.') - 3, 3) == "_hd"
	if hd or (not file_name_hd and font.get_meta("hd", false)):
		font_size = font.fixed_size / 2
	else:
		font_size = font.fixed_size


func release() -> void:
	font = null
