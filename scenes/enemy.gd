extends Node2D

signal request_move(direction: Vector2i)

@export var max_health: int = 1
@export var power_level: int = 1

@onready var health: int = max_health

@onready var animation_player = $AnimationPlayer

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

func on_collision(entity: Node2D) -> void:
	pass


func on_move(old_position: Vector2i, new_position: Vector2i) -> void:
	pass