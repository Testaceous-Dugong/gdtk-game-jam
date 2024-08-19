extends Control

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _on_play_button_pressed() -> void:
	animation_player.play(&"play")


func play() -> void:
	GlobalMessageBus.set_level.emit(0)
