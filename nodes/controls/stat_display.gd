class_name StatDisplay
extends MarginContainer

@export var stat_icon: Texture2D
@export var missing_stat_icon: Texture2D

@export var centered := true
@export var icon_separation := 0
@export var icon_scale := Vector2(1, 1)

var stat_value: int:
  set(value):
    stat_value = value
    if stat_value > max_stat_value:
      max_stat_value = stat_value
    else:
      _dirty = true
      update.call_deferred()

var max_stat_value: int:
  set(value):
    max_stat_value = value
    _dirty = true
    update.call_deferred()


var _dirty = false

var _hbox: HBoxContainer

func _ready() -> void:
  assert(stat_icon)

func update() -> void:
  if not _dirty:
    return

  _dirty = false

  if _hbox:
    remove_child(_hbox)
    _hbox.queue_free()

  _hbox = HBoxContainer.new()
  _hbox.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
  _hbox.add_theme_constant_override("separation", icon_separation * icon_scale.x)
  add_child(_hbox, false, INTERNAL_MODE_BACK)

  var icon_count = stat_value if not missing_stat_icon else max_stat_value

  for i in range(icon_count):
    var texture = stat_icon if i < stat_value else missing_stat_icon

    var margin_container = MarginContainer.new()
    @warning_ignore("narrowing_conversion")
    var margin = Vector2i(texture.get_width() * icon_scale.x / 2.0, texture.get_height() * icon_scale.y / 2.0)
    margin_container.add_theme_constant_override("margin_top", margin.y)
    margin_container.add_theme_constant_override("margin_left", margin.x)
    margin_container.add_theme_constant_override("margin_bottom", margin.y)
    margin_container.add_theme_constant_override("margin_right", margin.x)
    margin_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
    margin_container.grow_vertical = Control.GROW_DIRECTION_BOTH


    var sprite = Sprite2D.new()
    sprite.centered = false
    sprite.texture = texture
    sprite.scale = icon_scale
    margin_container.add_child(sprite)

    _hbox.add_child(margin_container)
