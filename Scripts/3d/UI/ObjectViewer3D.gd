extends Control

@onready var dim_bg: ColorRect = $DimBackground
@onready var img: TextureRect = $ObjectSprite
@onready var text_label: Label = $ObjectText

var tween: Tween
var showing := false
var lines: Array[String] = []
var current_line := 0
var can_close := false
var is_pickup := false
var target_object: Node = null
var player: Node = null

func _ready():
	visible = false
	dim_bg.modulate.a = 0.0
	img.visible = false
	text_label.visible = false

func show_object(texture: Texture2D, dialog_lines: Array[String], pickup := false, obj: Node = null) -> void:
	if showing:
		return
	showing = true
	visible = true
	
	# 🔹 Buscar jugador (solo lo pausamos a él)
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 🔹 Guardar datos
	img.texture = texture
	lines = dialog_lines
	current_line = 0
	is_pickup = pickup
	target_object = obj
	
	# 🔹 Mostrar
	img.visible = true
	text_label.visible = true
	text_label.text = lines[current_line] if lines.size() > 0 else ""
	
	# 🔹 Fondo oscuro con fade
	if tween: 
		tween.kill()
	tween = create_tween()
	tween.tween_property(dim_bg, "modulate:a", 0.7, 0.4)
	
	await get_tree().create_timer(0.3).timeout
	can_close = true

func _input(event):
	if not showing or not can_close:
		return
	
	if event.is_action_pressed("ui_accept"):  # E o Enter → siguiente texto
		if lines.size() > 0:
			current_line += 1
			if current_line < lines.size():
				text_label.text = lines[current_line]
			else:
				close_view()
		else:
			close_view()
	elif event.is_action_pressed("ui_cancel"):  # ESC → cerrar
		close_view()

func close_view():
	if not showing:
		return
	
	showing = false
	can_close = false
	
	if tween: 
		tween.kill()
	tween = create_tween()
	tween.tween_property(dim_bg, "modulate:a", 0.0, 0.3)
	
	img.visible = false
	text_label.visible = false
	
	await get_tree().create_timer(0.3).timeout
	visible = false
	
	# 🔹 Si era un ítem pickup → eliminarlo y agregar al inventario
	if is_pickup and target_object:
		target_object.queue_free()
	
	# 🔹 Desbloquear jugador
	if player:
		player.set_process(true)
		player.set_physics_process(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
