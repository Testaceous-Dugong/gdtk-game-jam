extends Node2D

signal request_move(direction: Vector2i)

@export var max_health: int = 1

@export var power_level: int = 1:
	set(value):
		power_level = value
		power_level_display.text = "⚔️".repeat(power_level)

@onready var health: int:
	set(value):
		health = value
		health_display.text = "❤️".repeat(health)

@onready var animation_player = $AnimationPlayer

@onready var health_display = $HealthDisplayAnchor/HealthDisplay
@onready var power_level_display = $PowerDisplayAnchor/PowerDisplay

func _ready() -> void:
	health = max_health
	power_level = power_level

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
