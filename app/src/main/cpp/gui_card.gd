extends "res://app/src/main/cpp/gui_element.gd"

const _CardDef = preload("res://app/src/main/cpp/card_def.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

@export
var texture_res: _ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			init()


@export
var def: _CardDef:
	set(value):
		if value != def:
			def = value
			init()


@export
var enable: bool:
	set(value):
		if value != enable:
			enable = value
			_on_render()


@export
var selected: bool:
	get():
		return $CardShadow.visible
	set(value):
		$CardShadow.visible = value


@export
var card_alpha: float:
	set(value):
		if value != card_alpha:
			card_alpha = value
			_on_render()


@export
var price: int:
	set=set_price

@export
var industry: int:
	set=set_industry

@export
var price_color: Color:
	get=get_price_color,
	set=set_price_color

@export
var industry_color: Color:
	get=get_industry_color,
	set=set_industry_color

@export
var research: int:
	set(value):
		if value != research:
			research = value
			_on_render()


@export
var time: int:
	set(value):
		if value != time:
			time = value
			_on_render()


@export
var tech_request: int:
	set(value):
		if value != tech_request:
			tech_request = value
			init()


signal pressed

func _ready() -> void:
	init()


func init() -> void:
	if def == null:
		return
	if texture_res != null:
		$Card.texture = texture_res.get_image(def.image)
		$TechRequest.texture = texture_res.get_image("technology_{0}.png".format([tech_request]))
	else:
		$Card.texture = null
	set_price(def.price)
	set_industry(def.industry)
	if def.type <= 1:
		var country := g_GameManager.get_local_player_country()
		if country != null:
			var army := _CObjectDef.instance().get_army_def(def.id, country.name)
			var atk := "{0}-{1}".format([army.minatk, army.maxatk])
			$Attack.spacing.x = -2 if atk.length() > 3 else -1
			$Attack.text = atk
			@warning_ignore("integer_division")
			var strength := "{0}".format([army.strength / 10])
			$Strength.spacing.x = -2 if strength.length() > 3 else -1
			$Strength.text = strength
			$Movement.text = "{0}".format([army.movement])
	_on_render()


func set_price(value: int) -> void:
	$Price.text = "{0}".format([value])


func set_industry(value: int) -> void:
	$Industry.text = "{0}".format([value])


func get_price_color() -> Color:
	return $Price.color


func set_price_color(color: Color) -> void:
	$Price.color = color


func get_industry_color() -> Color:
	return $Industry.color


func set_industry_color(color: Color) -> void:
	$Industry.color = color


func _on_button_pressed() -> void:
	_CSoundBox.get_instance().play_se("btn.wav")
	pressed.emit()


func _on_render() -> void:
	$CardShadow.self_modulate = Color(Color.WHITE, card_alpha)
	var color: Color
	if enable:
		if $Button.button_pressed:
			color = Color(Color8(0xD2, 0xD2, 0xD2), card_alpha)
		else:
			color = Color(Color.WHITE, card_alpha)
	else:
		color = Color(Color8(0x80, 0x80, 0x80), card_alpha)
	$CardCommon.self_modulate = color
	$Card.self_modulate = color
	if research > 0:
		$Research.texture = g_GameRes.card_d_research[research]
		$Research.self_modulate = color
		$Research.visible = true
	else:
		$Research.visible = false
	if time > 0:
		$MarkTime.visible = true
		$Time.text = "{0}".format([time])
		$Time.visible = true
	else:
		$MarkTime.visible = false
		$Time.visible = false
	if tech_request > 1:
		$MarkTechRequest.visible = true
		$TechRequest.visible = true
	else:
		$MarkTechRequest.visible = false
		$TechRequest.visible = false
	if def.type <= 1:
		var stat_color: Color
		if enable:
			stat_color = Color8(0x4B, 0xA8, 0xE4)
		else:
			stat_color = Color8(0x25, 0x54, 0x72)
		$Attack.color = stat_color
		$Strength.color = stat_color
		$Movement.color = stat_color
		$Attack.visible = true
		$Strength.visible = true
		$Movement.visible = true
	else:
		$Attack.visible = false
		$Strength.visible = false
		$Movement.visible = false
