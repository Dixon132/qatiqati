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

func _on_area_interaccion_body_entered(body):
	if body.name == "Jugador":
		jugador_cerca = true

func _on_area_interaccion_body_exited(body):
	if body.name == "Jugador":
		jugador_cerca = false

func _process(delta):
	if jugador_cerca and Input.is_action_just_pressed("interact") and not dialogo_terminado:
		print("Iniciando diálogo con la CasaFinal...")
		get_parent().start_vn_dialog(dialogo_hombre, nombres_dialogo, retratos_dialogo, self)
		dialogo_terminado = true

# Este lo llamará Pueblo.gd cuando termine el diálogo VN
func abrir_puerta():
	print("La puerta de la casa final se ha abierto...")
	# Aquí podrías cambiar escena:
	get_tree().change_scene_to_file("res://Scenes/CasaInterior3D.tscn")
