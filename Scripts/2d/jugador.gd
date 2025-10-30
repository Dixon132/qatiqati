extends CharacterBody2D

@export var speed = 150

func _physics_process(delta):
	var input = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input.x = 1
	if Input.is_action_pressed("move_left"):
		input.x = -1

	velocity = input * speed
	move_and_slide()
