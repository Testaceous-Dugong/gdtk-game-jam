extends Label

func _ready() -> void:
	GlobalMessageBus.level_changed.connect(on_level_changed)


func on_level_changed(level: int) -> void:
	text = str(level + 1)
