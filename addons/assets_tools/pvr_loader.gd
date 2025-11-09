@tool
extends ImageFormatLoaderExtension

const _MAGIC = "PVR!"

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["pvr"])


func _load_image(image: Image, fileaccess: FileAccess, flags: int, scale: float) -> Error:
	if fileaccess.get_length() < 48:
		push_error(".pvr file too small")
		return ERR_PARSE_ERROR
	var header := fileaccess.get_buffer(52)
	if header.slice(44, 48).get_string_from_ascii() != _MAGIC or header.decode_u8(16) != 16:
		push_error(".pvr file invalid header")
		return ERR_PARSE_ERROR
	var width := header.decode_u32(8)
	var height := header.decode_u32(4)
	var data_size := 2 * width * height
	if fileaccess.get_length() != 52 + data_size:
		push_error(".pvr file unexpected file length: expected {0}, got {1}".format([48 + data_size, fileaccess.get_length()]))
		return ERR_PARSE_ERROR
	var data := fileaccess.get_buffer(data_size)
	image.set_data(width, height, false, Image.FORMAT_RGBA4444, data)
	return OK
