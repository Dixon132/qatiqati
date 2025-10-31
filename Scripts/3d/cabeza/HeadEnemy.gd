extends Node3D

@export var speed := 3.5
@export var active_time := 10.0
@export var reach_screamer_sound: AudioStream
@export var float_height := 0.18
@export var float_speed := 2.0

@onready var proximity_area: Area3D = $proximity_area
@onready var audio3d: AudioStreamPlayer3D = $AudioStreamPlayer3D setget _set_audio_node

var alive_time := 0.0
var pursuing := false
var started := false
var float_time := 0.0
var player: Node3D = null

func _set_audio_node(v):
	audio3d = v

func _ready() -> void:
	if proximity_area:
		proximity_area.body_entered.connect(_on_proximity_entered)
	# buscar player en la escena (asume que tiene grupo "player")
	player = get_tree().get_first_node_in_group("player")
	print("HeadEnemy listo:", name)

func start_pursuit() -> void:
	if started:
		return
	started = true
	pursuing = true
	alive_time = 0.0
	print("HeadEnemy: comenzando persecución")

func _on_proximity_entered(body: Node) -> void:
	if not body or not body.is_in_group("player"):
		return
	if pursuing:
		# mostrar overlay de jumpscare
		var overlay = get_tree().root.get_node_or_null("3Dcasa/UI/JumpScareOverlay")
		if overlay:
			await overlay.show_once(reach_screamer_sound, 1.0)
		queue_free()

func _physics_process(delta: float) -> void:
	if pursuing and player:
		var dir = (player.global_transform.origin - global_transform.origin)
		if dir.length() > 0.05:
			dir = dir.normalized()
			global_translate(dir * speed * delta)
	# morir pasado el tiempo
	if pursuing:
		alive_time += delta
		if alive_time >= active_time:
			var tw = create_tween()
			tw.tween_property(self, "scale", Vector3.ZERO, 0.35)
			await tw.finished
			queue_free()

func _process(delta: float) -> void:
	# float idle cuando NO persigue
	if not pursuing:
		float_time += delta * float_speed
		translation.y = sin(float_time) * float_height
