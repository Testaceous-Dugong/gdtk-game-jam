extends Node2D

@export var current_level: int = -1: set = set_current_level

@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var levels = %Levels as Node

var _level: Node = null

func _ready() -> void:
  GlobalMessageBus.restart_level.connect(restart_level)
  GlobalMessageBus.advance_level.connect(on_advance_level)

func on_advance_level() -> void:
  animation_player.play(&"transition")

func advance_level() -> void:
  assert(levels)
  assert(levels.get_child_count() > 0)
  set_current_level((current_level + 1) % levels.get_child_count())

func restart_level() -> void:
  set_current_level(current_level)

func set_current_level(value: int) -> void:
  assert(levels)
  assert(levels.get_child_count() > 0)
  assert(value >= 0)
  assert(value < levels.get_child_count())

  if current_level != value:
    GlobalMessageBus.level_changed.emit(value)

  current_level = value
  
  if _level:
    levels.remove_child(_level)
    _level.queue_free()

  print("loading level %s" % current_level)
  var level_placeholder := levels.get_child(current_level) as InstancePlaceholder
  _level = level_placeholder.create_instance()

  animation_player.play(&"fade_in")
