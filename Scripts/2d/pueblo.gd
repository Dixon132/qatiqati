extends Node2D

@onready var dialog_box = $UI/DialogBox
@onready var dialog_text = $UI/DialogBox/DialogText

@onready var vn_ui = $UI_DialogoVN
@onready var vn_nombre = $UI_DialogoVN/Nombre
@onready var vn_texto = $UI_DialogoVN/Texto
@onready var vn_imagen = $UI_DialogoVN/Portrait

var dialogo_hombre: Array[String] = []
var nombres_dialogo: Array[String] = []
var retratos_dialogo: Array[String] = []

var vn_activo: bool = false
var vn_dialogo: Array[String] = []
var vn_nombres: Array[String] = []
var vn_retratos: Array[String] = []
var vn_linea: int = 0
var vn_casa_origen = null

# ----------------------------
# 🔹 Variables de diálogo
# ----------------------------
var dialog_lines: Array[String] = []
var current_line: int = 0
var in_dialog: bool = false

# ----------------------------
# 🔹 Progreso en el pueblo
# ----------------------------
var casas_habladas: int = 0
var evento_amiga_activado: bool = false
var dialogo_amiga_mostrado: bool = false
var casa_actual = null

# ----------------------------
# 🔹 Referencias de personajes
# ----------------------------
@onready var amiga = $Amiga

# ================================================================
# 📜 SISTEMA DE DIÁLOGOS
# ================================================================
func start_dialog(lines: Array[String], casa_origen = null, nombres: Array[String] = [], retratos: Array[String] = []) -> void:
	casa_actual = casa_origen

	# Si tiene retratos o nombres, usamos la interfaz VN
	if retratos.size() > 0 or nombres.size() > 0:
		vn_activo = true
		vn_dialogo = lines
		vn_nombres = nombres
		vn_retratos = retratos
		vn_linea = 0
		vn_casa_origen = casa_origen
		vn_ui.visible = true
		mostrar_vn_linea()
	else:
		# Diálogo clásico (sin retratos)
		dialog_lines = lines
		current_line = 0
		in_dialog = true
		dialog_box.visible = true
		show_line()

func show_line() -> void:
	if current_line >= 0 and current_line < dialog_lines.size():
		dialog_text.text = str(dialog_lines[current_line])
		print('cambiando el texto')
	else:
		dialog_text.text = ""

func _process(delta):
	if vn_activo:
		if Input.is_action_just_pressed("ui_accept"):
			avanzar_vn()
			print('VN MAS 1')
		return
	
	if in_dialog:
		if Input.is_action_just_pressed("ui_accept"):
			avanzarDialog()
		return

func avanzarDialog() -> void:
	current_line += 1
	print('DIALOG MAS 1')
	print(current_line)
	if current_line < dialog_lines.size():
		show_line()
	else:
		end_dialog()

func end_dialog() -> void:
	dialog_box.visible = false
	in_dialog = false
	
	# Si es el diálogo de la amiga, la desaparecemos
	if dialogo_amiga_mostrado and not evento_amiga_activado:
		desaparecer_amiga()
		return
	
	# Si es una casa normal, apagamos luz y contamos
	if casa_actual != null and casa_actual.has_method("apagar_luz"):
		casa_actual.apagar_luz()
		casas_habladas += 1
		casa_actual = null
		verificar_evento_amiga()

# ================================================================
# 🧍‍♀️ EVENTO DE LA AMIGA
# ================================================================
func verificar_evento_amiga() -> void:
	if casas_habladas >= 3 and not evento_amiga_activado and not dialogo_amiga_mostrado:
		var dialogo_amiga: Array[String] = [
			"Eva... no nos van a abrir en ninguna casa.",
			"Voy a caminar un poco más arriba del pueblo a ver si alguien nos recibe.",
			"Espérame aquí, ¿sí?"
		]
		print("Iniciando diálogo de amiga")
		dialogo_amiga_mostrado = true
		start_dialog(dialogo_amiga, null)

func desaparecer_amiga() -> void:
	print("👭 La amiga se fue... y no volvió.")
	evento_amiga_activado = true
	if amiga != null:
		amiga.queue_free()

# ================================================================
# 📜 SISTEMA VN (Visual Novel)
# ================================================================
func start_vn_dialog(lines, nombres, retratos, vn_casa):
	vn_activo = true
	vn_dialogo = lines
	vn_nombres = nombres
	vn_retratos = retratos
	vn_linea = 0
	vn_casa_origen = vn_casa
	vn_ui.visible = true
	mostrar_vn_linea()

func mostrar_vn_linea():
	vn_nombre.text = vn_nombres[vn_linea]
	vn_texto.text = vn_dialogo[vn_linea]
	print('MOSTRANDO EN LINEA')
	vn_imagen.texture = load(vn_retratos[vn_linea])

func avanzar_vn():
	vn_linea += 1
	print('AVANZANDO')
	if vn_linea < vn_dialogo.size():
		mostrar_vn_linea()
	else:
		finalizar_vn()

func finalizar_vn():
	vn_ui.visible = false
	print('FINALIZANDO')
	vn_activo = false
	if vn_casa_origen and vn_casa_origen.has_method("abrir_puerta"):
		vn_casa_origen.abrir_puerta()
