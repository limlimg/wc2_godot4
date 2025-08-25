@tool
extends EditorPlugin

var IMPORTERS = [
	preload("res://addons/assets_tools/fnt_importer.gd"),
	preload("res://addons/assets_tools/raw_importer.gd"),
	preload("res://addons/assets_tools/xml_importer.gd"),
	preload("res://addons/assets_tools/xml_translation_importer.gd"),
	preload("res://addons/assets_tools/xml_armies_importer.gd"),
	preload("res://addons/assets_tools/xml_cards_importer.gd"),
	preload("res://addons/assets_tools/xml_units_motions_importer.gd"),
]

var LOADERS = [
	preload("res://addons/assets_tools/bin_loader.gd")
]

var IMAGE_LOADERS = [
	preload("res://addons/assets_tools/pvr_loader.gd"),
	preload("res://addons/assets_tools/pkm_loader.gd")
]

var loaded_importers: Array[EditorImportPlugin]
var loaded_loaders: Array[ResourceFormatLoader]
var loader_image_loaders: Array[ImageFormatLoaderExtension]

func _enter_tree() -> void:
	for cls in IMPORTERS:
		var importer = cls.new()
		add_import_plugin(importer)
		loaded_importers.push_back(importer)
	for cls in LOADERS:
		var loader = cls.new()
		ResourceLoader.add_resource_format_loader(loader)
		loaded_loaders.push_back(loader)
	for cls in IMAGE_LOADERS:
		var loader = cls.new()
		loader.add_format_loader()
		loader_image_loaders.append(loader)


func _exit_tree() -> void:
	for importer in loaded_importers:
		remove_import_plugin(importer)
	for loader in loaded_loaders:
		ResourceLoader.remove_resource_format_loader(loader)
	for loader in loader_image_loaders:
		loader.remove_format_loader()
	loaded_importers.clear()
	loaded_loaders.clear()
	loader_image_loaders.clear()
