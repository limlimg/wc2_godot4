class_name AreaTaxMap
extends Resource

const _AreaTax = preload("res://app/src/main/cpp/imported_containers/area_tax.gd")

@export
var areas: Dictionary[int, _AreaTax]
