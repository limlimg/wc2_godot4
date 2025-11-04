extends Node

const _MAGIC = "EASY"
const _DOCUMENT_SIZE = 0x20
const _ecFile = preload("res://app/src/main/cpp/ec_file.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

var speed := 2
var music_volume := 50
var se_volume := 50
var battle_animation := true
var full_screen := true

func load_settings() -> void:
	var file := _ecFile.new()
	if file.open(_native.get_document_path("settings.cfg"), FileAccess.READ):
		var buffer := PackedByteArray()
		if file.read(buffer, _DOCUMENT_SIZE):
			file.close()
			if buffer.slice(0, 4).get_string_from_ascii().reverse() == _MAGIC and buffer.decode_u32(4) == 1:
				music_volume = clampi(buffer.decode_u32(8), 0, 100)
				se_volume = clampi(buffer.decode_u32(12), 0, 100)
				speed = clampi(buffer.decode_u32(16), 0, 5)
				battle_animation = buffer.decode_u32(20) != 0
				full_screen = buffer.decode_u32(28) != 0
		else:
			file.close()


func save_settings() -> void:
	var buffer := PackedByteArray()
	buffer.append_array(_MAGIC.reverse().to_ascii_buffer())
	buffer.resize(_DOCUMENT_SIZE)
	buffer.encode_u32(4, 1)
	buffer.encode_u32(8, music_volume)
	buffer.encode_u32(12, se_volume)
	buffer.encode_u32(16, speed)
	buffer.encode_u32(20, 1 if battle_animation else 0)
	buffer.encode_u32(28, 1 if full_screen else 0)
	var file := _ecFile.new()
	if file.open(_native.get_document_path("settings.cfg"), FileAccess.WRITE):
		file.write(buffer, _DOCUMENT_SIZE)
		file.close()
