extends Node2D

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	GlobalMessageBus.set_level.connect(set_level)

func set_level(_level: int) -> void:
	animation_player.play(&"fade_in")
