extends TileMapLayer


func _ready() -> void:
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

		if entity.has_method(&"on_collision") and not entity.on_collision(child):
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

	if power_level != 0 and entity.has_method(&"apply_damage") and entity.apply_damage(power_level):
		return

	match tile_data.get_custom_data(&"health"):
		1:
			set_entity_position(new_position, entity)
			entity.on_move(old_position, new_position)
		var health when health > 0:
			set_cell(
				new_position,
				get_cell_source_id(new_position),
				Vector2i(
					4 - (health - 1),
					get_cell_atlas_coords(new_position).y
				)
			)


func set_entity_position(tile_position: Vector2i, entity: Node2D) -> void:
	if get_cell_tile_data(tile_position) != null:
		erase_cell(tile_position)

	entity.position = map_to_local(tile_position)
