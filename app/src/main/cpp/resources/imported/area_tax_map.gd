class_name AreaTaxMap
extends Resource

const _AreaTax = preload("res://app/src/main/cpp/resources/imported/area_tax.gd")

@export
var areas: Dictionary[int, _AreaTax]
