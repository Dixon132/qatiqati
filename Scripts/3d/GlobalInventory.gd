extends Node

var items = {} # Estructura: { name = { texture, type } }
signal item_added(name: String, item_type: String)

func add_item(name: String, texture: Texture2D, item_type: String = ""):
	if not items.has(name):
		items[name] = {
			"texture": texture,
			"type": item_type
		}
		print("✅ Añadido al inventario:", name, "tipo:", item_type)
		emit_signal("item_added", name, item_type)
