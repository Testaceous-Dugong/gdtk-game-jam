extends Node

@export var advance_animation_name: StringName

func on_animation_finished(animation_name: StringName) -> void:
	if animation_name != advance_animation_name:
		return
	GlobalMessageBus.advance_level.emit()