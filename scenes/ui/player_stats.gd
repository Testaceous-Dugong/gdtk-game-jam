extends Control

@onready var health_display = $HealthDisplay
@onready var power_level_display = $PowerDisplay

func set_health(value: int) -> void:
	health_display.text = "❤️".repeat(value)

func set_power_level(value: int) -> void:
	power_level_display.text = "⚔️".repeat(value)
