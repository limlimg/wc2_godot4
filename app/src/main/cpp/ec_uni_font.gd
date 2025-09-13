extends "res://app/src/main/cpp/native-lib.gd"

## The .fnt files are imported as FontFile. Reimport if the coresponding image
## changes.
##
## GetCharImage is not implemented. In the original game code, it is only used
## by ecText to draw text. In this port, it looks like its implementation will
## either be complicated or put constraint on the type of Font to use.
##
## Theoretically, in the orignal game code, Init can be called multiple times to
## get a combined font, which is not possible here.

var font: Font
var font_size: int

func init(file_name: String, hd: bool) -> void:
	font = load(get_path(file_name, "")) as FontFile
	if font == null:
		return
	if hd:
		font_size = font.fixed_size / 2
	else:
		font_size = font.fixed_size


func release() -> void:
	font = null
