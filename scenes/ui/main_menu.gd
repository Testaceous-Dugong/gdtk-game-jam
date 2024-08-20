extends Control

const ANIMATION_SKIP_DELAY = 0.05

enum UIState {
	NONE,
	PLAY_PRESSED,
	GAME_STARTED,
}


var state = UIState.NONE

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_accept") and animation_player.is_playing() and animation_player.current_animation_position > ANIMATION_SKIP_DELAY:
		animation_player.speed_scale = 20
		await animation_player.animation_finished
		animation_player.speed_scale = 1

	match state:
		UIState.PLAY_PRESSED:
			if Input.is_action_just_pressed(&"ui_accept"):
				state = UIState.GAME_STARTED
				animation_player.play(&"play")
		_:
			pass

func _on_play_button_pressed() -> void:
	animation_player.play(&"display_controls")


func register_play_button_press() -> void:
	state = UIState.PLAY_PRESSED

func play() -> void:
	GlobalMessageBus.set_level.emit(0)
