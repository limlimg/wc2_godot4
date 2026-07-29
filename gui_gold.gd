extends GUIElement

@export
var money := 0:
	set = set_money

@export
var industry := 0:
	set = set_industry

func set_money(value: int) -> void:
	if value != money:
		money = value
		$Money.text = "{0}".format([value])


func set_industry(value: int) -> void:
	if value != industry:
		industry = value
		$Industry.text = "{0}".format([value])


func _process(_delta: float) -> void:
	var country = g_GameManager.get_cur_country()
	if country != null:
		set_money(country.money)
		set_industry(country.industry)
