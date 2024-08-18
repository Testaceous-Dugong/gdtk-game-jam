extends Node2D

enum AIType {
	STATIONARY,
	PACE,
	RANDOM,
	CHASE_PLAYER,
}

enum MovementType {
	MANHATTAN,
	ANY
}

signal request_move(direction: Vector2i)
signal turn_finished()

@export var ai_type: AIType = AIType.STATIONARY
@export var movement_type: MovementType = MovementType.MANHATTAN

@export var max_health: int = 1:
	set(value):
		max_health = value
		if health_display:
			health_display.max_stat_value = max_health

@export var power_level: int = 1:
	set(value):
		power_level = value
		if power_level_display:
			power_level_display.stat_value = power_level

@export var experience_value: int = 1

var health: int:
	set(value):
		health = value
		health_display.stat_value = health

var players = {}

var has_attacked = false


@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var attack_animator = $AttackAnimator as AttackAnimator
@onready var move_animator = $MoveAnimator as MoveAnimator

@onready var health_display = $HealthDisplay as StatDisplay
@onready var power_level_display = $PowerDisplay as StatDisplay

func _ready() -> void:
	power_level = power_level
	max_health = max_health
	health = max_health

	GlobalMessageBus.register_player.connect(on_player_added)
	GlobalMessageBus.unregister_player.connect(on_player_removed)

	GlobalMessageBus.unpause_input.connect(reset_has_attacked)

func reset_has_attacked() -> void:
	has_attacked = false

func take_turn() -> void:
	if health == 0:
		turn_finished.emit.call_deferred()
		return
	match ai_type:
		AIType.STATIONARY:
			turn_finished.emit.call_deferred()
			return
		AIType.PACE:
			assert(false, "Pace AI not yet implemented")
			return
		AIType.RANDOM:
			assert(false, "Random AI not yet implemented")
			return
		AIType.CHASE_PLAYER:
			assert(movement_type != MovementType.MANHATTAN, "Chase player AI does not work with Manhattan movement yet")
			var tile_map = get_parent() as TileMapLayer
			assert(tile_map, "Enemy must be a child of a TileMapLayer")
			assert(players.size() == 1, "Chase player AI only works with one player")
			var player = players.keys()[0]
			if not navigate_toward(tile_map.local_to_map(player.position)):
				navigate_toward(tile_map.local_to_map(player.previous_position))

			
func navigate_toward(target_position: Vector2i) -> bool:
	var tile_map = get_parent() as TileMapLayer
	assert(tile_map, "Enemy must be a child of a TileMapLayer")

	var delta = target_position - tile_map.local_to_map(position)
	var direction = Vector2i(signi(delta.x), signi(delta.y))

	if direction.x == 0:
		request_move.emit(Vector2i(0, direction.y))
		return true
	if direction.y == 0:
		request_move.emit(Vector2i(direction.x, 0))
		return true

	var current_tile_coord = tile_map.local_to_map(position)
	var is_diagonal_clear = tile_map.get_cell_tile_data(current_tile_coord + direction) == null
	var is_vertical_clear = tile_map.get_cell_tile_data(current_tile_coord + Vector2i(0, direction.y)) == null
	var is_horizontal_clear = tile_map.get_cell_tile_data(current_tile_coord + Vector2i(direction.x, 0)) == null
	if not is_diagonal_clear:
		if (not is_vertical_clear and not is_horizontal_clear) or (is_vertical_clear and is_horizontal_clear):
			if absf(delta.x) > absf(delta.y):
				request_move.emit(Vector2i(direction.x, 0))
			elif absf(delta.y) > absf(delta.x):
				request_move.emit(Vector2i(0, direction.y))
			else:
				return false
		elif is_vertical_clear:
			request_move.emit(Vector2i(0, direction.y))
		else:
			request_move.emit(Vector2i(direction.x, 0))
		return true

	if is_vertical_clear:
		request_move.emit(direction)
		return true

	if is_horizontal_clear:
		request_move.emit(direction)
		return true

	if absf(delta.x) > absf(delta.y):
		request_move.emit(Vector2i(direction.x, 0))
	elif absf(delta.y) > absf(delta.x):
		request_move.emit(Vector2i(0, direction.y))
	else:
		return false

	return true

func get_power_level() -> int:
	return power_level

func get_experience_value() -> int:
	return experience_value

func apply_damage(damage: int) -> bool:
	assert(health > 0, "health must be greater than 0")
	health = clampi(health - damage, 0, max_health)
	if health == 0:
		animation_player.play(&"death")
		return true
	return false


func apply_power_up(power_up: PowerUp) -> void:
	var stats = EntityStats.new()
	stats.max_health = max_health
	stats.health = max_health
	stats.power_level = power_level

	var result = power_up.apply_powerup(stats)

	max_health = result.max_health
	health = result.health
	power_level = result.power_level

	power_up.queue_free()

func process_attack(incoming_damage: int, inflict_damage: Callable) -> bool:
	inflict_damage.call(get_power_level())

	apply_damage(incoming_damage)
	has_attacked = true
	if health == 0:
		return true
	return false

func on_collision(entity: Node2D) -> bool:
	if entity is PowerUp:
		apply_power_up(entity)
		return true

	if has_attacked:
		turn_finished.emit.call_deferred()
		return false

	attack_animator.target = (entity.position - position).normalized()
	animation_player.play(&"attack")
	var finished_animation = await animation_player.animation_finished
	assert(finished_animation == &"attack")

	if not entity.has_method(&"process_attack"):
		turn_finished.emit.call_deferred()
		return false
	
	var killed_entity = entity.process_attack(get_power_level(), apply_damage)

	if not killed_entity:
		turn_finished.emit.call_deferred()
		return false

	if entity.has_method("get_death_signal"):
		await entity.get_death_signal()

	return true


func on_move(new_position: Vector2) -> void:
	# position = new_position
	move_animator.start_position = position
	move_animator.target_position = new_position
	animation_player.play(&"move")
	var finished_animation = await animation_player.animation_finished
	assert(finished_animation == &"move")

	turn_finished.emit.call_deferred()

func on_attack_wall(direction: Vector2i, _destructable: bool) -> void:
	attack_animator.target = Vector2(direction).normalized()
	animation_player.play(&"attack")
	var finished_animation = await animation_player.animation_finished
	assert(finished_animation == &"attack")

	turn_finished.emit.call_deferred()


func on_player_added(player: Player) -> void:
	players[player] = true

func on_player_removed(player: Player) -> void:
	players.erase(player)

func get_death_signal() -> Signal:
	return animation_player.animation_finished

func on_animation_finished(animation_name: StringName) -> void:
	if animation_name != "death":
		return
	get_parent().remove_child(self)
