extends Node2D

signal request_move(direction: Vector2i)

@export var max_health: int = 3
@export var power_level: int = 1

@onready var health: int = max_health

@onready var animation_player = $AnimationPlayer

var allow_input = true

func _ready() -> void:
	GlobalMessageBus.pause_input.connect(set_allow_input.bind(false))
	GlobalMessageBus.unpause_input.connect(set_allow_input.bind(true))


func _process(_delta: float) -> void:
	if not allow_input:
		return
	if Input.is_action_just_pressed(&"move_up"):
		request_move.emit(Vector2i.UP)
	elif Input.is_action_just_pressed(&"move_down"):
		request_move.emit(Vector2i.DOWN)
	elif Input.is_action_just_pressed(&"move_left"):
		request_move.emit(Vector2i.LEFT)
	elif Input.is_action_just_pressed(&"move_right"):
		request_move.emit(Vector2i.RIGHT)

func set_allow_input(value: bool) -> void:
	allow_input = value

func apply_power_up(power_up: PowerUp) -> void:
	var stats = EntityStats.new()
	stats.health = health
	stats.max_health = max_health
	stats.power_level = power_level

	var result = power_up.apply_powerup(stats)

	health = result.health
	max_health = result.max_health
	power_level = result.power_level

	power_up.queue_free()


func get_power_level() -> int:
	return power_level

func apply_damage(damage: int) -> bool:
	if health == 0:
		return true
	health = clampi(health - damage, 0, max_health)
	if health == 0:
		animation_player.play(&"death")
		return true
	return false

func on_collision(entity: Node2D) -> bool:
	if entity is PowerUp:
		apply_power_up(entity)
		return true
	
	if entity.has_method(&"get_power_level") and apply_damage(entity.get_power_level()):
		return false
	
	if entity.has_method(&"apply_damage"):
		entity.apply_damage(power_level)
	return false


func on_move(old_position: Vector2i, new_position: Vector2i) -> void:
	pass

func end_game() -> void:
	get_tree().reload_current_scene()
