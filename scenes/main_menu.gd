extends Control

const ANIMATION_SKIP_DELAY = 0.05

enum UIState {
  NONE,
  LEVEL_SELECT
}


var state = UIState.NONE

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _input(event: InputEvent) -> void:
  if event.is_action_released(&"ui_accept") and animation_player.is_playing() and animation_player.current_animation_position > ANIMATION_SKIP_DELAY:
    animation_player.speed_scale = 20
    await animation_player.animation_finished
    animation_player.speed_scale = 1


func _on_animation_finished(anim_name: StringName) -> void:
  match anim_name:
    &"fade_out":
      GameFlowManager.change_to_controls_tutorial()
