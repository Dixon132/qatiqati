# Scripts/InteractionSprite.gd
extends TextureButton

@export var item_name: String = ""
@export var description: String = ""
@export var pickup_item: bool = false
@export var item_texture: Texture2D
@export var sound_effect: AudioStream

var picked_up := false

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if picked_up:
		return
	
	if sound_effect:
		var audio = AudioStreamPlayer.new()
		add_child(audio)
		audio.stream = sound_effect
		audio.play()

	if pickup_item:
		_pickup_item()
	else:
		_show_description()

func _pickup_item():
	picked_up = true
	hide()
	print("🔑 Objeto obtenido:", item_name)
	# Guardar variable global
	GlobalInventory.add_item(item_name, item_texture)

func _show_description():
	print("📝 Observando:", item_name)
	# Si más adelante querés mostrar texto en pantalla:
	var ui = get_tree().root.get_node_or_null("casa/UI/EventDisplay")
	if ui and ui.has_method("show_text"):
		ui.show_text(description)
