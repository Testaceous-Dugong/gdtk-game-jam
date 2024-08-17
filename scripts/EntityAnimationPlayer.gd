extends AnimationPlayer


func _ready() -> void:
	animation_started.connect(start_animation)
	animation_finished.connect(finish_animation)

func start_animation(_animation_name: StringName) -> void:
	GlobalMessageBus.pause_input.emit()


func finish_animation(_animation_name: StringName) -> void:
	GlobalMessageBus.unpause_input.emit()