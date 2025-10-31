extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $AnimatedSprite2D  # nombre exacto de tu nodo

func _ready():
	if sprite:
		sprite.play("default")  # animación siempre activa
	else:
		print("No se encontró AnimatedSprite2D")

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += 400 * delta  # ajusta tu gravedad

	# Movimiento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED  # se mueve si hay input
	else:
		velocity.x = 0  # se queda quieto si no hay input

	# Aplicar movimiento
	move_and_slide()
