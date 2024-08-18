extends TileMapLayer

var running = true

func _ready() -> void:
	connect_signals.call_deferred()

	GlobalMessageBus.advance_turn.connect(advance_turn)
	GlobalMessageBus.advance_level.connect(set_is_running.bind(false))
	GlobalMessageBus.restart_level.connect(set_is_running.bind(false))
	GlobalMessageBus.set_level.connect(set_is_running.bind(false))

func connect_signals() -> void:
	for child in get_children():
		if child.has_signal(&"request_move"):
			child.request_move.connect(move_entity.bind(child))

func get_sorted_children() -> Array[Node]:
	var children = get_children()

	children.sort_custom(func(a: Node, b: Node):
		if a is Player and b is Player:
			return true
		return a.process_priority < b.process_priority
	)

	return children

func set_is_running(value: bool) -> void:
	running = value

func advance_turn() -> void:
	if not running:
		return
	const TURN_DURATION = 0.05
	await get_tree().create_timer(TURN_DURATION).timeout
	for child in get_sorted_children():
		if not child.has_method(&"take_turn"):
			continue
		child.take_turn()
		assert(child.has_signal(&"turn_finished"), "entity must have turn_finished signal")
		await child.turn_finished
	GlobalMessageBus.unpause_input.emit()

func move_entity(direction: Vector2i, entity: Node2D) -> void:
	assert(entity != null, "entity must not be null")
	assert(
		entity.has_method(&"on_move"),
		"entity must have on_move method"
	)
	assert(direction != Vector2i.ZERO, "direction must not be zero")

	var old_position = local_to_map(entity.position)
	var new_position = old_position + direction


	for child in get_sorted_children():
		if child == entity:
			continue
		if local_to_map(child.position) != new_position:
			continue

		if entity.has_method(&"on_collision") and not await entity.on_collision(child):
			return

	var tile_data = get_cell_tile_data(new_position)

	var is_solid: bool = false if tile_data == null else tile_data.get_custom_data(&"is_solid")

	if not is_solid:
		clear_cell(new_position)
		await entity.on_move(map_to_local(new_position))
		return
	
	if tile_data == null:
		return

	if entity.has_method(&"on_attack_wall"):
		await entity.on_attack_wall(direction)
	match tile_data.get_custom_data(&"health"):
		1:
			clear_cell(new_position)
			await entity.on_move(map_to_local(new_position))
		var health when health > 0:
			set_cell(
				new_position,
				get_cell_source_id(new_position),
				Vector2i(
					4 - (health - 1),
					get_cell_atlas_coords(new_position).y
				)
			)


func clear_cell(tile_position: Vector2i) -> void:
	if get_cell_tile_data(tile_position) == null:
		return
	erase_cell(tile_position)
