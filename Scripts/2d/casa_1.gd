extends Node2D

@export var lineas_dialogo: Array[String] = [
	"Buenas noches...",
	"No deberían estar afuera a estas horas.",
	"Dicen que él volvió a aparecer... el hombre del camino.",
	"Váyanse antes de que las vean."
]

@onready var luz = $Luz  # Asegúrate que el nodo Luz exista como hijo de Casa1

var jugador_cerca: bool = false
var dialogo_terminado: bool = false

func _on_area_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		jugador_cerca = true
		print("Jugador se acercó a Casa1")

func _on_area_body_exited(body: Node2D) -> void:
	if body.name == "Jugador":
		jugador_cerca = false
		print("Jugador se alejó de Casa1")

func _process(delta: float) -> void:
	if jugador_cerca and not dialogo_terminado \
	and Input.is_action_just_pressed("interact") \
	and not get_parent().in_dialog:
		print("🎭 Iniciando diálogo con Casa1")
		get_parent().start_dialog(lineas_dialogo, self)  # 👈 IMPORTANTE

func apagar_luz() -> void:
	dialogo_terminado = true
	if luz:
		luz.visible = false
		print("💡 Luz de Casa1 apagada")
