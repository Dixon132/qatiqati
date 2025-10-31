extends Node2D

@export var dialogo_hombre: Array[String] = [
	"Que bueno que llegaron",
	"Gracias por recibirnos en su casa!!",
	"Cualquier cosa por ayudarlas",
	"Gracias, solo seran 3 dias"
]

@export var nombres_dialogo: Array[String] = [
	"Eugenio",
	"Maria",
	"Eugenio",
	"Eva"
]

@export var retratos_dialogo: Array[String] = [
	"res://Assets/Retratos/abuelo.png",
	"res://Assets/Retratos/maria.png",
	"res://Assets/Retratos/abuelo.png",
	"res://Assets/Retratos/eva.png"
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

# Este lo llamará Pueblo.gd cuando termine el diálogo VN
func abrir_puerta():
	print("La puerta de la casa final se ha abierto...")
	get_tree().change_scene_to_file("res://Escenas/2d/dia2.tscn")
