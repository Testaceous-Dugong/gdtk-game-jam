extends Control

var ready_to_play = false

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _process(_delta: float) -> void:
	if not ready_to_play:
		return
	if Input.is_action_just_pressed(&"ui_accept"):
		animation_player.play(&"play")

func _on_play_button_pressed() -> void:
	ready_to_play = true
	animation_player.play(&"display_controls")


func play() -> void:
	GlobalMessageBus.set_level.emit(0)
