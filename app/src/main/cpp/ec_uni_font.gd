extends "res://app/src/main/cpp/native-lib.gd"

## The .fnt files are imported as FontFile and the importer does not use
## ecGraphics::LoadTexture, which means the font images cannot have @2x suffix.
##
## GetCharImage is not implemented. In the original game code, it is only used
## by ecText to draw text. In this port, it looks like its implementation will
## either be complicated or put constraint on the type of Font to use.
##
## Theoretically, in the orignal game code, Init can be called multiple times to
## get a combined font, which is not possible here.

var _font: Font
var _font_size: int

func init(file_name: String, hd: bool) -> void:
	_font = load(get_path(file_name, "")) as FontFile
	if _font == null:
		return
	if hd:
		_font_size = _font.fixed_size / 2
	else:
		_font_size = _font.fixed_size


func release() -> void:
	_font = null
