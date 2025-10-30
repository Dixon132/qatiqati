extends Control

@onready var image_display: TextureRect = $ImageDisplay
@export var fade_time := 0.4

var tween: Tween
var showing := false
var can_close := false

func _ready() -> void:
	visible = false
	image_display.visible = false
	image_display.modulate.a = 0.0

func show_image(texture: Texture2D) -> void:
	if not texture:
		push_warning("⚠️ Sin textura asignada en show_image()")
		return

	visible = true
	image_display.texture = texture
	image_display.visible = true
	image_display.modulate.a = 0.0

	tween = create_tween()
	tween.tween_property(image_display, "modulate:a", 1.0, fade_time)
	await tween.finished

	showing = true
	can_close = true

func hide_image() -> void:
	if not showing:
		return
	can_close = false
	showing = false

	tween = create_tween()
	tween.tween_property(image_display, "modulate:a", 0.0, fade_time)
	await tween.finished

	image_display.visible = false
	visible = false

func _process(delta: float) -> void:
	if showing and can_close and Input.is_action_just_pressed("ui_cancel"):
		hide_image()
	elif showing and can_close and Input.is_action_just_pressed("interact"):
		hide_image()
