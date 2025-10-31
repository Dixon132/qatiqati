extends "res://Scripts/3d/Interacciones/InteractionBase.gd"

@export var item_name: String = ""
@export var item_type: String = ""  # 🔹 Tipo general (rama, planta, bolsa, etc.)
@export var description_lines: Array[String] = []
@export var pickup_item: bool = false
@export var item_texture: Texture2D
@export var inspect_texture: Texture2D
@export var sound_effect: AudioStream

var picked_up := false

func _ready():
	super._ready()  # ✅ Llama al _ready() del padre para conectar el área
	print("🧠 InteractionItem3D listo:", name)
	print("🧠 GlobalInventory referencia:", GlobalInventory)

func interact(player: Node) -> void:
	if picked_up:
		return
	##### 🎵 Reproducir sonido
	if sound_effect:
		var audio = AudioStreamPlayer3D.new()
		add_child(audio)
		audio.stream = sound_effect
		audio.play()
	###### 🧠 Buscar UI global
	var ui = get_tree().root.get_node_or_null("3Dcasa/UI/ObjectViewer3D")
	if not ui:
		push_warning("⚠️ ObjectViewer3D no encontrado.")
		return
	##### Mostrar UI
	if pickup_item:
		ui.show_object(item_texture, description_lines, true, self)
		on_pickup_finished()
	else:
		ui.show_object(inspect_texture, description_lines, false, self)

func on_pickup_finished():
	if picked_up:
		return
	picked_up = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0, 0, 0), 0.4).set_ease(Tween.EASE_IN)
	await tween.finished

	if GlobalInventory.has_method("add_item"):
		print("🎯 Añadiendo al inventario:", item_name, "(", item_type, ")")
		GlobalInventory.add_item(item_name, item_texture, item_type)
	else:
		print("❌ GlobalInventory no encontrado o sin método add_item")

	var progress_ui = get_tree().root.get_node_or_null("3Dcasa/UI/InventoryProgress")
	if progress_ui and progress_ui.has_method("update_progress"):
		progress_ui.update_progress()

	queue_free()
