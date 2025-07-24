@tool
extends ImageFormatLoaderExtension

# Reference code for loading etc1 header: https://android.googlesource.com/platform/frameworks/native/+/master/opengl/libs/ETC1/etc1.cpp

const magic = "PKM 10"

const ETC1_PKM_FORMAT_OFFSET = 6;
const ETC1_PKM_ENCODED_WIDTH_OFFSET = 8;
const ETC1_PKM_ENCODED_HEIGHT_OFFSET = 10;
const ETC1_PKM_WIDTH_OFFSET = 12;
const ETC1_PKM_HEIGHT_OFFSET = 14;

const ETC1_RGB_NO_MIPMAPS = 0;

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["pkm"])


func _load_image(image: Image, fileaccess: FileAccess, flags: int, scale: float) -> Error:
	if fileaccess.get_length() < 16:
		push_error(".pkm file too small")
		return ERR_PARSE_ERROR
	var header := fileaccess.get_buffer(16)
	if not etc1_pkm_is_valid(header):
		push_error(".pkm file invalid header")
		return ERR_PARSE_ERROR
	var width := etc1_pkm_get_width(header)
	var height := etc1_pkm_get_height(header)
	var data_size := etc1_get_encoded_data_size(width, height)
	if fileaccess.get_length() != 16 + data_size:
		push_error(".pkm file unexpected file length: expected {0}, got {1}".format([16 + data_size, fileaccess.get_length()]))
		return ERR_PARSE_ERROR
	var data := fileaccess.get_buffer(data_size)
	image.set_data(width, height, false, Image.FORMAT_ETC, data)
	image.decompress()
	return OK


## Check if a PKM header is correctly formatted.
func etc1_pkm_is_valid(header: PackedByteArray) -> bool:
	if header.slice(0, magic.length()).get_string_from_ascii() != magic:
		return false
	var format := _read_be_uint16(header, ETC1_PKM_FORMAT_OFFSET)
	var encoded_width := _read_be_uint16(header, ETC1_PKM_ENCODED_WIDTH_OFFSET)
	var encoded_height := _read_be_uint16(header, ETC1_PKM_ENCODED_HEIGHT_OFFSET)
	var width := _read_be_uint16(header, ETC1_PKM_WIDTH_OFFSET)
	var height := _read_be_uint16(header, ETC1_PKM_HEIGHT_OFFSET)
	return format == ETC1_RGB_NO_MIPMAPS\
			and encoded_width >= width and encoded_width - width < 4\
			and encoded_height >= height and encoded_height - height < 4;


## Read the image width from a PKM header
func etc1_pkm_get_width(header: PackedByteArray) -> int:
	return _read_be_uint16(header, ETC1_PKM_WIDTH_OFFSET)


## Read the image height from a PKM header
func etc1_pkm_get_height(header: PackedByteArray) -> int:
	return _read_be_uint16(header, ETC1_PKM_HEIGHT_OFFSET)


## Return the size of the encoded image data (does not include size of PKM header).
func etc1_get_encoded_data_size(width: int, height: int) -> int:
	return (((width + 3) & ~3) * ((height + 3) & ~3)) >> 1


func _read_be_uint16(header: PackedByteArray, offset: int) -> int:
	return header.decode_u8(offset) * 256 + header.decode_u8(offset + 1)
