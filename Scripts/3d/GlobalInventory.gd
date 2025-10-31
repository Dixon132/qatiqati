extends Node

var items = {}
signal item_added(name: String)

func add_item(name: String, texture: Texture2D):
	if not items.has(name):
		items[name] = texture
		print("✅ Añadido al inventario:", name)
		emit_signal("item_added", name)
