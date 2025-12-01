@tool
extends EditorPlugin

var _IMPORTERS = [
	preload("res://addons/assets_tools/fnt_importer.gd"),
	preload("res://addons/assets_tools/raw_importer.gd"),
	preload("res://addons/assets_tools/xml_importer.gd"),
	preload("res://addons/assets_tools/xml_translation_importer.gd"),
	preload("res://addons/assets_tools/xml_armies_importer.gd"),
	preload("res://addons/assets_tools/xml_cards_importer.gd"),
	preload("res://addons/assets_tools/xml_unit_motions_importer.gd"),
	preload("res://addons/assets_tools/xml_unit_positions_importer.gd"),
	preload("res://addons/assets_tools/xml_commanders_importer.gd"),
	preload("res://addons/assets_tools/xml_generals_importer.gd"),
	preload("res://addons/assets_tools/xml_battlelist_importer.gd"),
	preload("res://addons/assets_tools/xml_conquestlist_importer.gd"),
	preload("res://addons/assets_tools/xml_texture_importer.gd"),
]

var _LOADERS = [
	preload("res://addons/assets_tools/bin_loader.gd")
]

var _IMAGE_LOADERS = [
	preload("res://addons/assets_tools/pvr_loader.gd"),
	preload("res://addons/assets_tools/pkm_loader.gd")
]

var _loaded_importers: Array[EditorImportPlugin]
var _loaded_loaders: Array[ResourceFormatLoader]
var _loader_image_loaders: Array[ImageFormatLoaderExtension]

func _enter_tree() -> void:
	for cls in _IMPORTERS:
		var importer = cls.new()
		add_import_plugin(importer)
		_loaded_importers.push_back(importer)
	for cls in _LOADERS:
		var loader = cls.new()
		ResourceLoader.add_resource_format_loader(loader)
		_loaded_loaders.push_back(loader)
	for cls in _IMAGE_LOADERS:
		var loader = cls.new()
		loader.add_format_loader()
		_loader_image_loaders.append(loader)


func _exit_tree() -> void:
	for importer in _loaded_importers:
		remove_import_plugin(importer)
	for loader in _loaded_loaders:
		ResourceLoader.remove_resource_format_loader(loader)
	for loader in _loader_image_loaders:
		loader.remove_format_loader()
	_loaded_importers.clear()
	_loaded_loaders.clear()
	_loader_image_loaders.clear()
