extends MarginContainer

@onready var continue_button = %ContinueButton as Button

func _ready() -> void:
  continue_button.grab_focus()

func _on_animation_finished(anim_name: StringName) -> void:
  match anim_name:
    &"fade_out":
      GameFlowManager.change_to_level()
