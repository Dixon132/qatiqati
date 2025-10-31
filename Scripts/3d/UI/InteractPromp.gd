extends Control

@onready var label: Label = $Label
var tween: Tween
var showing := false

func _ready():
	label.visible = false
	label.modulate.a = 0.0

func show_prompt(text: String = "E - Interactuar"):
	label.text = text
	if showing: return
	showing = true
	label.visible = true
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.25)

func hide_prompt():
	if not showing: return
	showing = false
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.25)
	await tween.finished
	label.visible = false
