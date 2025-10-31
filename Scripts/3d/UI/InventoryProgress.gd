extends Control

@onready var label_branches: Label = $VBoxContainer/LabelBranches
@onready var label_plants: Label = $VBoxContainer/LabelPlants
@onready var label_bag: Label = $VBoxContainer/LabelBag

# Cuántos necesitas de cada tipo
const REQUIRED_ITEMS = {
	"rama": 4,
	"planta": 4,
	"bolsa": 1
}

signal all_items_collected

func _ready():
	visible = true
	update_progress()

	if GlobalInventory:
		GlobalInventory.connect("item_added", Callable(self, "_on_item_added"))


# Cuando se agrega un objeto nuevo
func _on_item_added(name: String) -> void:
	print("🔥 Señal recibida desde GlobalInventory:", name)
	update_progress()
#
	## Mostrar un pequeño aviso (efecto +1)
	#_show_pickup_feedback(name)

# ✅ Llamar cada vez que recojas un objeto
func update_progress():
	var inv = GlobalInventory.items
	
	var branches = _count_type(inv, "rama")
	var plants = _count_type(inv, "planta")
	var bags = _count_type(inv, "bolsa")

	label_branches.text = "🌿 Ramas: %d / %d" % [branches, REQUIRED_ITEMS["rama"]]
	label_plants.text = "🌸 Plantas: %d / %d" % [plants, REQUIRED_ITEMS["planta"]]
	label_bag.text = "👜 Bolsas: %d / %d" % [bags, REQUIRED_ITEMS["bolsa"]]

	_check_completion(branches, plants, bags)

# Contar los objetos de cierto tipo
func _count_type(inv: Dictionary, type_name: String) -> int:
	var count = 0
	for data in inv.values():
		if data.has("type") and data["type"] == type_name:
			count += 1
	return count


# Verifica si todos están completos
func _check_completion(branches: int, plants: int, bags: int):
	if branches >= REQUIRED_ITEMS["rama"] and plants >= REQUIRED_ITEMS["planta"] and bags >= REQUIRED_ITEMS["bolsa"]:
		print("✅ Todos los objetos recolectados")
		emit_signal("all_items_collected")

# 🌟 Pequeño feedback visual al recoger algo
func _show_pickup_feedback(item_name: String):
	var label := Label.new()
	label.text = "+1 " + item_name.capitalize()
	label.modulate = Color(1, 1, 1, 0.0)
	label.scale = Vector2(1.2, 1.2)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(label)

	# Posiciona el texto cerca del HUD (arriba a la derecha)
	label.global_position = label_branches.global_position + Vector2(20, -30)

	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_property(label, "global_position:y", label.global_position.y - 40, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.5)
	await tween.finished
	label.queue_free()
