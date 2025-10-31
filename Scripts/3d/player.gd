#extends CharacterBody3D
#
## 🎮 MOVIMIENTO
#@export var walk_speed := 1.8
#@export var run_speed := 3.2
#@export var acceleration := 8.0
#@export var deceleration := 10.0
#@export var mouse_sensitivity := 0.0015
#@export var gravity := 12.0
#@export var jump_force := 3.5
#@export var step_height := 0.4
#
## 🎥 CÁMARA Y HEADBOB SMOOTH
## Si tu cámara se llama "Camera3D" y es hija directa, usa esto:
#@onready var cam: Camera3D = $Camera3D
## Si tiene otro nombre, cámbialo aquí ↑
#@export_group("Headbob Walking")
#@export var walk_bob_amount := 0.012
#@export var walk_bob_frequency := 1.2
#@export_group("Headbob Running")
#@export var run_bob_amount := 0.025
#@export var run_bob_frequency := 1.8
#@export_group("Camera Smoothing")
#@export var camera_smooth_speed := 18.0
#@export var bob_smooth_speed := 10.0
#@export var tilt_amount := 0.25
#
## 🧠 ESTADO
#var vertical_velocity := 0.0
#var interactable: Node = null
#@onready var prompt_label: Label = $"../UI/InteractPrompt/Label"
#
## Suavizado de movimiento
#var velocity_smoothed := Vector3.ZERO
#
## Sistema de headbob
#var headbob_time := 0.0
#var original_cam_position: Vector3
#var current_bob_offset := Vector3.ZERO
#var camera_target_position: Vector3
#var camera_target_rotation := 0.0
#
#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#original_cam_position = cam.position
	#camera_target_position = original_cam_position
	#_update_prompt()
	#
	## Activar V-Sync
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
#
## ---------------------------------------------------
## MOUSE Y CÁMARA
## ---------------------------------------------------
#func _input(event) -> void:
	## Bloquear cámara si UI está activa
	#var ui_display = get_tree().root.get_node_or_null("casa/UI/EventDisplay")
	#if ui_display and ui_display.visible:
		#return
#
	#if event is InputEventMouseMotion:
		#rotate_y(-event.relative.x * mouse_sensitivity)
		#cam.rotate_x(-event.relative.y * mouse_sensitivity)
		#cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -85, 85)
		#
#
## ---------------------------------------------------
## MOVIMIENTO Y FÍSICA
## ---------------------------------------------------
#func _physics_process(delta: float) -> void:
	## Bloquear movimiento si EventDisplay está activo
	#var ui_display = get_tree().root.get_node_or_null("casa/UI/EventDisplay")
	#if ui_display and ui_display.visible:
		#return
#
	#var direction = Vector3.ZERO
	#
	#if Input.is_action_pressed("move_forward"):
		#direction -= transform.basis.z
	#if Input.is_action_pressed("move_backward"):
		#direction += transform.basis.z
	#if Input.is_action_pressed("move_left"):
		#direction -= transform.basis.x
	#if Input.is_action_pressed("move_right"):
		#direction += transform.basis.x
#
	#direction = direction.normalized()
#
	#var is_running = Input.is_action_pressed("run")
	#var target_speed = run_speed if is_running else walk_speed
#
	## Aceleración y desaceleración suaves
	#var target_velocity = direction * target_speed
	#var accel = acceleration if direction.length() > 0 else deceleration
	#
	#velocity_smoothed.x = lerp(velocity_smoothed.x, target_velocity.x, accel * delta)
	#velocity_smoothed.z = lerp(velocity_smoothed.z, target_velocity.z, accel * delta)
#
	## Gravedad y salto MEJORADO
	#if is_on_floor():
		## Pegado al suelo - sin rebotes
		#if vertical_velocity <= 0:
			#vertical_velocity = 0.0
		#
		#if Input.is_action_just_pressed("jump"):
			#vertical_velocity = jump_force
	#else:
		## En el aire
		#vertical_velocity -= gravity * delta
#
	## Aplicar movimiento
	#velocity.x = velocity_smoothed.x
	#velocity.z = velocity_smoothed.z
	#velocity.y = vertical_velocity
#
	## CRÍTICO: Configurar parámetros de slide
	#set_floor_stop_on_slope_enabled(true)
	#set_floor_max_angle(deg_to_rad(45))
	#set_floor_snap_length(0.1)
	#
	#move_and_slide()
#
	## Subir escalones SOLO si hay colisión frontal
	#if is_on_floor() and direction.length() > 0 and is_on_wall():
		#_step_up()
	#
	## Aplicar headbob smooth
	#_apply_headbob(delta, is_running, direction)
#
## ---------------------------------------------------
## SUBIDA DE ESCALONES (MEJORADO - SIN REBOTES)
## ---------------------------------------------------
#func _step_up():
	#var space_state = get_world_3d().direct_space_state
	#
	## Raycast hacia adelante y arriba
	#var forward = -transform.basis.z.normalized()
	#var from = global_position + Vector3(0, 0.1, 0)
	#var to = from + forward * 0.3
	#
	#var query = PhysicsRayQueryParameters3D.new()
	#query.from = from
	#query.to = to
	#query.collide_with_areas = false
	#query.collide_with_bodies = true
	#query.exclude = [self]
	#
	#var hit = space_state.intersect_ray(query)
	#
	#if hit:
		## Hay obstáculo, intentar subir
		#var step_check = from + Vector3(0, step_height, 0)
		#query.from = step_check
		#query.to = step_check + forward * 0.3
		#
		#var step_hit = space_state.intersect_ray(query)
		#
		#if not step_hit:
			## Puede subir el escalón
			#position.y += step_height * 0.7
#
## ---------------------------------------------------
## HEADBOB ULTRA SMOOTH
## ---------------------------------------------------
#func _apply_headbob(delta: float, running: bool, direction: Vector3):
	## Calcular velocidad real del personaje
	#var actual_speed = Vector2(velocity.x, velocity.z).length()
	#var speed_threshold = 0.15
	#
	#if actual_speed > speed_threshold and is_on_floor():
		## Seleccionar parámetros según velocidad
		#var bob_amount = run_bob_amount if running else walk_bob_amount
		#var bob_freq = run_bob_frequency if running else walk_bob_frequency
		#
		## Avanzar tiempo del headbob basado en velocidad real
		#var speed_factor = actual_speed / walk_speed
		#headbob_time += delta * bob_freq * speed_factor
		#
		## PATRÓN NATURAL de caminata
		## Vertical: doble frecuencia simula dos pasos por ciclo
		#var vertical_bob = sin(headbob_time * 2.0) * bob_amount
		#
		## Horizontal: balanceo lateral suave
		#var horizontal_bob = sin(headbob_time) * bob_amount * 0.35
		#
		## Inclinación sutil al moverte lateralmente
		#var tilt = 0.0
		#if direction.length() > 0:
			#var strafe = Input.get_axis("move_left", "move_right")
			#tilt = strafe * tilt_amount * speed_factor
		#
		## Calcular offset objetivo
		#var target_offset = Vector3(horizontal_bob, vertical_bob, 0.0)
		#
		## Suavizado progresivo del offset
		#current_bob_offset = current_bob_offset.lerp(target_offset, delta * bob_smooth_speed)
		#
		#camera_target_position = original_cam_position + current_bob_offset
		#camera_target_rotation = -tilt
	#else:
		## Volver a reposo suavemente
		#current_bob_offset = current_bob_offset.lerp(Vector3.ZERO, delta * bob_smooth_speed)
		#camera_target_position = original_cam_position + current_bob_offset
		#camera_target_rotation = lerp(camera_target_rotation, 0.0, delta * bob_smooth_speed)
		#
		## Resetear tiempo gradualmente
		#headbob_time = lerp(headbob_time, 0.0, delta * 2.5)
	#
	## Aplicar interpolación final (triple suavizado)
	#cam.position = cam.position.lerp(camera_target_position, delta * camera_smooth_speed)
	#cam.rotation_degrees.z = lerp(cam.rotation_degrees.z, camera_target_rotation, delta * camera_smooth_speed)
#
## ---------------------------------------------------
## INTERACCIÓN
## ---------------------------------------------------
#func set_interactable(node: Node) -> void:
	#interactable = node
	#_update_prompt()
#
#func _update_prompt() -> void:
	#if not prompt_label:
		#return
	#if interactable:
		#prompt_label.visible = true
		#prompt_label.text = interactable.prompt_text
	#else:
		#prompt_label.visible = false
#
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("interact") and interactable:
		#if interactable.has_method("interact"):
			#interactable.interact(self)
			#
			#




extends CharacterBody3D

# --- Variables principales ---
@export var walk_speed := 1.8
@export var run_speed := 3.2
@export var acceleration := 8.0
@export var deceleration := 10.0
@export var mouse_sensitivity := 0.0015
@export var gravity := 12.0
@export var jump_force := 3.5
@export var step_height := 0.4

@onready var cam: Camera3D = $Camera3D
@onready var interact_prompt = $"../UI/InteractPrompt"

var vertical_velocity := 0.0
var velocity_smoothed := Vector3.ZERO
var headbob_time := 0.0
var original_cam_position: Vector3
var current_bob_offset := Vector3.ZERO
var camera_target_position: Vector3
var camera_target_rotation := 0.0
var interactable: Node = null

# --- Headbob configs ---
@export var walk_bob_amount := 0.012
@export var walk_bob_frequency := 1.2
@export var run_bob_amount := 0.025
@export var run_bob_frequency := 1.8
@export var camera_smooth_speed := 18.0
@export var bob_smooth_speed := 10.0
@export var tilt_amount := 0.25

# --- Inicio ---
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_cam_position = cam.position
	camera_target_position = original_cam_position
	_update_prompt()

# --- Movimiento principal ---
func _input(event):
	if event is InputEventMouseMotion and not get_tree().paused:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -85, 85)

func _physics_process(delta):
	if get_tree().paused:
		return

	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"): direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"): direction += transform.basis.z
	if Input.is_action_pressed("move_left"): direction -= transform.basis.x
	if Input.is_action_pressed("move_right"): direction += transform.basis.x

	direction = direction.normalized()
	var is_running = Input.is_action_pressed("run")
	var target_speed = run_speed if is_running else walk_speed

	var target_velocity = direction * target_speed
	var accel = acceleration if direction.length() > 0 else deceleration
	velocity_smoothed.x = lerp(velocity_smoothed.x, target_velocity.x, accel * delta)
	velocity_smoothed.z = lerp(velocity_smoothed.z, target_velocity.z, accel * delta)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vertical_velocity = jump_force
		else:
			vertical_velocity = 0.0
	else:
		vertical_velocity -= gravity * delta

	velocity.x = velocity_smoothed.x
	velocity.z = velocity_smoothed.z
	velocity.y = vertical_velocity
	move_and_slide()

	_apply_headbob(delta, is_running, direction)

# --- Headbob ---
func _apply_headbob(delta, running, direction):
	var actual_speed = Vector2(velocity.x, velocity.z).length()
	if actual_speed < 0.1 or not is_on_floor():
		current_bob_offset = current_bob_offset.lerp(Vector3.ZERO, delta * bob_smooth_speed)
	else:
		var bob_amount = run_bob_amount if running else walk_bob_amount
		var bob_freq = run_bob_frequency if running else walk_bob_frequency
		headbob_time += delta * bob_freq
		var v_bob = sin(headbob_time * 2.0) * bob_amount
		var h_bob = sin(headbob_time) * bob_amount * 0.4
		current_bob_offset = current_bob_offset.lerp(Vector3(h_bob, v_bob, 0), delta * bob_smooth_speed)

	cam.position = cam.position.lerp(original_cam_position + current_bob_offset, delta * camera_smooth_speed)

# --- Interacción ---
func set_interactable(node: Node) -> void:
	interactable = node
	_update_prompt()

func _update_prompt() -> void:
	if not interact_prompt:
		return
	if interactable:
		interact_prompt.show_prompt(interactable.prompt_text)
	else:
		interact_prompt.hide_prompt()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and interactable:
		if interactable.has_method("interact"):
			interactable.interact(self)
