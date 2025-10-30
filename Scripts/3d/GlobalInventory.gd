extends Node

var items = {}

func add_item(name: String, texture: Texture2D):
	if not items.has(name):
		items[name] = texture
		print("✅ Añadido al inventario:", name)
