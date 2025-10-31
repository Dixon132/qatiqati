# res://Scripts/UI/JumpScareOverlay.gd
extends Control

@onready var tex_rect: TextureRect = $TextureRect
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	visible = false
	tex_rect.visible = false

# ahora es awaitable: await overlay.show_once(...)
func show_once(sound: AudioStream = null, duration := 1.0) -> void:
	visible = true
	tex_rect.visible = true

	if sound:
		audio.stream = sound
		audio.play()

	# fade in/out
	if tex_rect.modulate.a != 1.0:
		tex_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(tex_rect, "modulate:a", 1.0, 0.08)
	tw.tween_property(tex_rect, "modulate:a", 0.0, 0.40).set_delay(duration)
	await tw.finished

	tex_rect.visible = false
	visible = false
