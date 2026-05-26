extends AnimationPlayer

func advance_level() -> void:
	GlobalMessageBus.advance_level.emit()