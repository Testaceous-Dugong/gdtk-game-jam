class_name Player
extends Node2D

signal request_move(direction: Vector2i)

signal health_changed(health: int)
signal power_level_changed(power_level: int)

@export var max_health: int = 3
@export var power_level: int = 0:
	set(value):
		power_level = value
		power_level_changed.emit(power_level)

@onready var animation_player = $AnimationPlayer

var health: int:
	set(value):
		health = value
		health_changed.emit(health)

var level: int = 1
var experience: int:
	set(value):
		experience = value
		if experience >= level + 1:
			level += 1
			experience %= level

var allow_input = true

func _enter_tree() -> void:
	GlobalMessageBus.register_player.emit.call_deferred(self)

func _exit_tree() -> void:
	GlobalMessageBus.unregister_player.emit.call_deferred(self)

func _ready() -> void:
	health = max_health
	power_level = power_level

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


func get_power_level() -> int:
	return power_level + level

func set_allow_input(value: bool) -> void:
	allow_input = value

func apply_power_up(power_up: PowerUp) -> void:
	var stats = EntityStats.new()
	stats.health = health
	stats.max_health = max_health
	stats.power_level = get_power_level()
	stats.experience = experience

	var result = power_up.apply_powerup(stats)

	health = result.health
	max_health = result.max_health
	power_level = result.power_level - level
	experience = result.experience

	power_up.queue_free()

func apply_damage(damage: int) -> bool:
	assert(health > 0, "health must be greater than 0")
	health = clampi(health - damage, 0, max_health)
	if health == 0:
		animation_player.play(&"death")
		return true
	return false

func on_collision(entity: Node2D) -> bool:
	if entity is PowerUp:
		apply_power_up(entity)
		return true
	
	var was_killed = entity.has_method(&"get_power_level") and apply_damage(entity.get_power_level())
	if was_killed:
		return false
	
	var killed_entity = entity.has_method(&"apply_damage") and entity.apply_damage(get_power_level())
	if killed_entity and entity.has_method(&"get_experience_value"):
		experience += entity.get_experience_value()
	return false


func on_move(_old_position: Vector2i, _new_position: Vector2i) -> void:
	GlobalMessageBus.advance_turn.emit()

func end_game() -> void:
	get_tree().reload_current_scene()
