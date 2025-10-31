extends MeshInstance3D

@export var prompt_text: String = "E - Interactuar"
@onready var area: Area3D = $Area3D

var player_in_range: Node = null
var is_being_looked_at: bool = false

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		body.call_deferred("set_interactable", self)
		print('dentro')

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = null
		body.call_deferred("set_interactable", null)
		print('fuera')

func interact(player: Node) -> void:	
	print("✅ Interacción ejecutada en:", name)
