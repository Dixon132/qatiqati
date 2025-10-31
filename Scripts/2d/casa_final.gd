extends Node2D

@export var dialogo_hombre: Array[String] = [
	"¿Quién anda ahí...?",
	"¿Estás sola? Está muy tarde para andar caminando.",
	"¿Dijiste que buscas a tu amiga?...",
	"Sí, la vi. Pasó corriendo por aquí, estaba mojada por la lluvia.",
	"Si quieres, puedes entrar. Tal vez siga adentro... ven."
]

@export var nombres_dialogo: Array[String] = [
	"???",
	"???",
	"???",
	"Hombre",
	"Hombre"
]

@export var retratos_dialogo: Array[String] = [
	"res://Assets/Retratos/hombre_1.png",
	"res://Assets/Retratos/hombre_serio.png",
	"res://Assets/Retratos/hombre_serio.png",
	"res://Assets/Retratos/hombre_1.png",
	"res://Assets/Retratos/hombre_1.png"
]

var jugador_cerca = false
var dialogo_terminado = false
@onready var label_interactuar = $Label  # 👈 referencia al texto

func _on_area_interaccion_body_entered(body):
	if body.name == "Jugador":
		jugador_cerca = true
		if label_interactuar:
			label_interactuar.visible = true  # 👀 mostrar texto

func _on_area_interaccion_body_exited(body):
	if body.name == "Jugador":
		jugador_cerca = false
		if label_interactuar:
			label_interactuar.visible = false  # ❌ ocultar texto

func _process(delta):
	if jugador_cerca and Input.is_action_just_pressed("interact") and not dialogo_terminado:
		print("Iniciando diálogo con la CasaFinal...")
		get_parent().start_vn_dialog(dialogo_hombre, nombres_dialogo, retratos_dialogo, self)
		dialogo_terminado = true
		if label_interactuar:
			label_interactuar.visible = false  # ocultar cuando empieza el diálogo
