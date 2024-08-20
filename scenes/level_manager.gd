extends Node2D

@export var levels: LevelSequence
@export var current_level: int = -1:
	set(value):
		assert(levels)
		assert(levels.scenes)
		assert(value >= 0)
		assert(value < levels.scenes.size())

		if current_level != value:
			GlobalMessageBus.level_changed.emit.call_deferred(value)

		current_level = value
		for child in get_children():
			remove_child(child)
			child.queue_free()
		

		assert(levels.scenes[current_level])
		add_child(levels.scenes[current_level].instantiate())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMessageBus.advance_level.connect(advance_level)
	GlobalMessageBus.restart_level.connect(restart_level)
	GlobalMessageBus.set_level.connect(set_level)

func advance_level() -> void:
	assert(levels)
	assert(levels.scenes)
	current_level = (current_level + 1) % levels.scenes.size()

func restart_level() -> void:
	current_level = current_level

func set_level(value: int) -> void:
	current_level = value
