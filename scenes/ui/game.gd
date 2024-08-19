extends CanvasLayer

func _ready() -> void:
	GlobalMessageBus.set_level.connect(set_level)
	GlobalMessageBus.advance_level.connect(set_visible.bind(true))
	GlobalMessageBus.restart_level.connect(set_visible.bind(true))

func set_level(_level: int) -> void:
	visible = true