extends TileMapLayer

@onready var tile_health: Dictionary = {}


func _ready() -> void:
	for tile_position in get_used_cells():
		var tile_data = get_cell_tile_data(tile_position)
		if tile_data == null:
			continue
		tile_health[tile_position] = tile_data.get_custom_data(&"health")
	connect_signals.call_deferred()

func connect_signals() -> void:
	for child in get_children():
		if child.has_signal(&"request_move"):
			child.request_move.connect(move_entity.bind(child))

func move_entity(direction: Vector2i, entity: Node2D) -> void:
	assert(entity != null, "entity must not be null")
	assert(
		entity.has_method(&"on_move"),
		"entity must have on_move method"
	)
	assert(direction != Vector2i.ZERO, "direction must not be zero")

	var old_position = local_to_map(entity.position)
	var new_position = old_position + direction

	for child in get_children():
		if child == entity:
			continue
		if local_to_map(child.position) != new_position:
			continue

		if entity.has_method(&"on_collision"):
			entity.on_collision(child)
		else:
			return

	var tile_data = get_cell_tile_data(new_position)

	var is_solid: bool = false if tile_data == null else tile_data.get_custom_data(&"is_solid")

	if not is_solid:
		set_entity_position(new_position, entity)
		entity.on_move(old_position, new_position)
		return
	
	if tile_data == null:
		return
	
	var power_level: int = tile_data.get_custom_data(&"power_level")
	var health: int = tile_health.get(new_position, 0)

	if health == 0 and power_level == 0:
		return

	if entity.has_method(&"apply_damage") and entity.apply_damage(power_level):
		return

	if not entity.has_method(&"get_power_level"):
		return
	
	var entity_power_level: int = entity.get_power_level()

	if health <= entity_power_level:
		set_entity_position(new_position, entity)
		entity.on_move(old_position, new_position)
	else:
		tile_health[new_position] = health - entity_power_level


func set_entity_position(tile_position: Vector2i, entity: Node2D) -> void:
	tile_health.erase(tile_position)
	if get_cell_tile_data(tile_position) != null:
		erase_cell(tile_position)

	entity.position = map_to_local(tile_position)
