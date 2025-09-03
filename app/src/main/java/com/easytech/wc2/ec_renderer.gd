
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

static var is_app_running := false

var _m_game_view_width := _Wc2Activity.get_view_width()
var _m_game_view_height := _Wc2Activity.get_view_height()

func on_surface_created() -> void:
	_native_init(_m_game_view_width, _m_game_view_height, 1, 0)


func on_surface_changed(width: int, height: int) -> void:
	_native_resize(width, height)


func on_draw_frame() -> void:
	if is_app_running:
		_native_render()


func on_touch(touch_type: int, x: float, y: float, reset: int) -> void:
	_native_touch(touch_type, x, y, reset)


static func _native_init(game_view_width: int, game_view_height: int, _a3, _a4) -> void:
	_native.Java_com_easytech_wc2_ecRenderer_nativeInit(game_view_width, game_view_height, _a3, _a4)


static func _native_render() -> void:
	_native.Java_com_easytech_wc2_ecRenderer_nativeRender()


static func _native_resize(game_view_width: float, game_view_height: float) -> void:
	_native.Java_com_easytech_wc2_ecRenderer_nativeResize(game_view_width, game_view_height)


static func _native_touch(touch_type: int, x: float, y: float, reset: int) -> void:
	_native.Java_com_easytech_wc2_ecRenderer_nativeTouch(touch_type, x, y, reset)
