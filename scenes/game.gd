extends Node2D

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	GlobalMessageBus.set_level.connect(on_set_level)
	GlobalMessageBus.advance_level.connect(on_advance_level)

func on_set_level(_level: int) -> void:
	animation_player.play(&"fade_in")

func on_advance_level() -> void:
	animation_player.play(&"transition")
