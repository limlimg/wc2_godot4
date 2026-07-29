extends GUIElement

var _selected_card := -1
var _targeting := false
var _targeting_army := false

@onready var _tabs := [
	$GUICardList,
	$GUICardList2,
	$GUICardList3,
	$GUICardList4,
	$GUICardList5
]

func _sel_card(tab: int, index: int) -> void:
	_selected_card = -1
	if tab >= 0 and index >= 0:
		_selected_card = _tabs[tab].get_card(index).def.type
	if _selected_card >= 0:
		_set_sel_card_intro()
	if _get_sel_card() == null:
		$ButtonOk.enable = false
	$ButtonOk.enable = _can_buy_sel_card()


func _set_sel_card_intro() -> void:
	if _selected_card >= 0:
		var card := _get_sel_card()
		if card != null:
			$Name/ecText.text = card.name
			$Intro/Font5/Label.text = card.intro


func _get_sel_card() -> CardDef:
	return CObjectDef.instance().get_card_def(_selected_card)


func _can_buy_sel_card() -> bool:
	if _selected_card < 0:
		return false
	var country := g_GameManager.get_cur_country()
	if country == null:
		return false
	return country.can_buy_card(CObjectDef.instance().get_card_def(_selected_card))


func reset_card_state() -> void:
	var country := g_GameManager.get_cur_country()
	if country == null or country.ai:
		return
	for i in _tabs:
		var j := 0
		var card = i.get_card(j)
		while card != null:
			var should_enable := true
			if country.is_enough_money(card.def):
				card.set_price_color(Color8(0x0F, 0x26, 0x32))
			else:
				card.set_price_color(Color8(0x00, 0x00, 0x80))
				should_enable = false
			if country.is_enough_industry(card.def):
				card.set_industry_color(Color8(0x0F, 0x26, 0x32))
			else:
				card.set_industry_color(Color8(0x00, 0x00, 0x80))
				should_enable = false
			if country.tech_level < card.def.tech:
				card.tech_request = card.def.tech
				should_enable = false
			else:
				card.tech_request = 1
			if card.def.id == 21: # research
				if country.tech_level >= 5:
					should_enable = false
					card.set_price(0)
					card.set_industry(0)
				else:
					card.set_price(country.get_card_price(card.def))
					card.set_industry(country.get_card_industry(card.def))
				card.time = country.research_round
				card.research = country.tech_level
			elif card.def.id == 25: # commander
				if country.can_use_commander():
					card.time = 0
				elif country.commander_alive:
					card.time = 0
					should_enable = false
				else:
					card.time = country.commander_round
			else:
				var time := country.get_card_rounds(card.def.id)
				if time > 0:
					should_enable = false
				card.enable = should_enable
				card.time = time
			card.enable = should_enable
			j += 1
	$ButtonOk.enable = _get_sel_card() != null and _can_buy_sel_card()


func reset_card_target() -> void:
	var country := g_GameManager.get_cur_country()
	if country != null and _targeting and _selected_card >= 0:
		AppDelegate.g_Scene.clear_targets()
		country.set_card_targets(CObjectDef.instance().get_card_def(_selected_card))


func release_target() -> void:
	_targeting = false
	_targeting_army = false
	AppDelegate.g_Scene.reset_target()


func _on_gui_card_tab_tab_selected(tab: int) -> void:
	for i in _tabs:
		i.hide()
	_tabs[tab].show()
	_tabs[tab].re_select()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()


func _on_gui_button_ok_pressed() -> void:
	var card := _get_sel_card()
	if card != null and _can_buy_sel_card():
		var country := g_GameManager.get_cur_country()
		var target := CObjectDef.instance().get_card_target_type(card)
		if target == 1 or target == 5:
			_targeting = true
			_targeting_army = target == 5
			if not country.ai:
				AppDelegate.g_Scene.clear_targets()
				country.set_card_targets(card)
		else:
			var action := CountryAction.new()
			action.type = 5
			action.card_id = card.id
			action.start_area = -1
			action.target_area = -1
			country.action(action)
			if g_GameManager.game_mode == 4:
				# TODO: send multiplayer data
				pass
		if card.id == 21: # research
			reset_card_state()
		else:
			hide()


func _on_gui_card_list_card_selected(tab: int, index: int) -> void:
	_sel_card(tab, index)
