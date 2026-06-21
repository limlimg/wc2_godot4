extends "res://app/src/main/cpp/gui_sel_item.gd"

const _MULTIPLAY_BATTLE = [
	"text_axis_01.png",
	"text_axis_02.png",
	"text_allies_02.png",
	"text_axis_04.png",
	"text_allies_07.png",
	"text_axis_05.png",
	"text_allies_09.png",
	"text_axis_03.png",
	"text_allies_04.png",
	"text_allies_05.png",
	"text_axis_06.png",
	"text_allies_08.png"
]

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			init()


@export
var battle: int:
	set(value):
		if value != battle:
			battle = value
			init()


func init() -> void:
	super()
	if texture_res == null:
		return
	var res := texture_res.get_res()
	var attr
	match campaign:
		0:
			attr = res.get_image("button_axis_%02d.png"%(battle + 1))
			if attr != null:
				_button_image = _ecImage.new(attr)
			attr = res.get_image("text_axis_%02d.png"%(battle + 1))
			if attr != null:
				_text_image = _ecImage.new(attr)
		1:
			attr = res.get_image("button_allies_%02d.png"%(battle + 1))
			if attr != null:
				_button_image = _ecImage.new(attr)
			attr = res.get_image("text_allies_%02d.png"%(battle + 1))
			if attr != null:
				_text_image = _ecImage.new(attr)
		2:
			attr = res.get_image("button_wto_%02d.png"%(battle + 1))
			if attr != null:
				_button_image = _ecImage.new(attr)
			attr = res.get_image("text_wto_%02d.png"%(battle + 1))
			if attr != null:
				_text_image = _ecImage.new(attr)
		3:
			attr = res.get_image("button_nato_%02d.png"%(battle + 1))
			if attr != null:
				_button_image = _ecImage.new(attr)
			attr = res.get_image("text_nato_%02d.png"%(battle + 1))
			if attr != null:
				_text_image = _ecImage.new(attr)
		4:
			attr = res.get_image("button_multiplay_%02d.png"%(battle + 1))
			if attr != null:
				_button_image = _ecImage.new(attr)
			attr = res.get_image(_MULTIPLAY_BATTLE[battle + 1])
			if attr != null:
				_text_image = _ecImage.new(attr)
