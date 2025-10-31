extends "res://Scripts/3d/Interacciones/InteractionBase.gd"

@export var item_name: String = ""
@export var item_type: String = ""  # 🔹 Tipo general (rama, planta, bolsa, etc.)
@export var description_lines: Array[String] = []
@export var pickup_item: bool = false
@export var item_texture: Texture2D
@export var inspect_texture: Texture2D
@export var sound_effect: AudioStream

var picked_up := false

func interact(player: Node) -> void:
	if picked_up:
		return

	# 🎵 Reproducir sonido
	if sound_effect:
		var audio = AudioStreamPlayer3D.new()
		add_child(audio)
		audio.stream = sound_effect
		audio.play()

	# 🧠 Buscar UI
	var ui = get_tree().root.get_node_or_null("3Dcasa/UI/ObjectViewer3D")
	if not ui:
		push_warning("⚠️ ObjectViewer3D no encontrado.")
		return

	# Mostrar UI con imagen y texto
	if pickup_item:
		ui.show_object(item_texture, description_lines, true, self)
	else:
		ui.show_object(inspect_texture, description_lines, false, self)

func on_pickup_finished():
	if picked_up:
		return
	picked_up = true

	# ✨ Pequeño efecto antes de desaparecer
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0, 0, 0), 0.4).set_ease(Tween.EASE_IN)
	await tween.finished

	# 🪶 Agregar al inventario global
	if GlobalInventory.has_method("add_item"):
		GlobalInventory.add_item(item_name, item_texture)
	
	# 🔁 Intentar actualizar la UI del contador (si existe)
	var progress_ui = get_tree().root.get_node_or_null("3Dcasa/UI/InventoryProgress")
	if progress_ui and progress_ui.has_method("update_progress"):
		progress_ui.update_progress()

	queue_free() # finalmente se elimina del mundo
