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

func _ready():
	visible = true
	update_progress()

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
	for key in inv.keys():
		if key.begins_with(type_name):
			count += 1
	return count

# Verifica si todos están completos
func _check_completion(branches: int, plants: int, bags: int):
	if branches >= REQUIRED_ITEMS["rama"] and plants >= REQUIRED_ITEMS["planta"] and bags >= REQUIRED_ITEMS["bolsa"]:
		print("✅ Todos los objetos recolectados")
		emit_signal("all_items_collected")

# Señal para triggers
signal all_items_collected
