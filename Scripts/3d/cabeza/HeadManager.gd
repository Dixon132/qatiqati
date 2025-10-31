# res://Scripts/HeadManager.gd
extends Node

@export var head_scene: PackedScene
@export var spawn_parent_path: NodePath = "HeadSpawner"
@export var camera_path: NodePath = "CasaInterior3D/Player/Camera3D"
@export var zoom_fov: float = 30.0
@export var zoom_time: float = 0.45
@export var focus_hold_time: float = 0.4  # tiempo para mostrar overlay en zoom
@export var max_active_heads := 3

@onready var spawn_parent: Node3D = null
@onready var cam: Camera3D = null
var collected_count: int = 0
var active_heads := []

func _ready() -> void:
	spawn_parent = get_node_or_null(spawn_parent_path)
	cam = get_node_or_null(camera_path)
	if GlobalInventory and GlobalInventory.has_signal("item_added"):
		GlobalInventory.connect("item_added", Callable(self, "_on_item_added"))

func _on_item_added(name: String, item_type: String) -> void:
	collected_count += 1
	print("[HeadManager] total recogidos:", collected_count)
	if collected_count % 2 == 0:
		spawn_head()

func spawn_head() -> void:
	if not head_scene or not spawn_parent:
		return
	# limitador simple
	if active_heads.size() >= max_active_heads:
		print("[HeadManager] max heads alive, no spawn")
		return

	var spawns := spawn_parent.get_children()
	if spawns.is_empty():
		return
	var p = spawns[randi() % spawns.size()]
	var head: Node3D = head_scene.instantiate()
	head.global_transform = p.global_transform
	# añadir a la escena principal (no como child del manager para tener transform global correcto)
	get_tree().current_scene.add_child(head)
	active_heads.append(head)

	# focus sequence: zoom -> overlay -> start_pursuit
	# 1) Guardar fov actual
	var original_fov = cam.fov
	# 2) Tween fov down (zoom)
	var tw = create_tween()
	tw.tween_property(cam, "fov", zoom_fov, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tw.finished

	# 3) mostrar jump-scare overlay en zoom por focus_hold_time
	var overlay = get_tree().root.get_node_or_null("CasaInterior3D/UI/JumpScareOverlay")
	if overlay:
		# suponemos que head tiene un "close_trigger_sound" o definimos uno genérico
		var sound = null
		if head.has_meta("close_sound"): # alternativa
			sound = head.get_meta("close_sound")
		# mostrar y esperar
		await overlay.show_once(sound, focus_hold_time)

	# 4) Restaurar FOV de la cam
	var tw2 = create_tween()
	tw2.tween_property(cam, "fov", original_fov, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw2.finished

	# 5) Iniciar persecución en la cabeza
	if head and head.has_method("start_pursuit"):
		head.start_pursuit()
	# opcional: limpiar lista cuando muera (head se elimina auto; escuchá señales o limpiala en _process)
