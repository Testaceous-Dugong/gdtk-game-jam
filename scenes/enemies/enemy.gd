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

@export var ai_type: AIType = AIType.STATIONARY
@export var movement_type: MovementType = MovementType.MANHATTAN

@export var max_health: int = 1

@export var power_level: int = 1:
	set(value):
		power_level = value
		power_level_display.text = "⚔️".repeat(power_level)

@export var experience_value: int = 1

var health: int:
	set(value):
		health = value
		health_display.text = "❤️".repeat(health)

var players = {}

var has_attacked = false

@onready var animation_player = $AnimationPlayer

@onready var health_display = $HealthDisplayAnchor/HealthDisplay
@onready var power_level_display = $PowerDisplayAnchor/PowerDisplay

func _exit_tree() -> void:
	GlobalMessageBus.register_player.disconnect(on_player_added)
	GlobalMessageBus.unregister_player.disconnect(on_player_removed)
	GlobalMessageBus.advance_turn.disconnect(on_turn_advanced)

func _ready() -> void:
	health = max_health
	power_level = power_level

	GlobalMessageBus.register_player.connect(on_player_added)
	GlobalMessageBus.unregister_player.connect(on_player_removed)
	GlobalMessageBus.advance_turn.connect(on_turn_advanced)

func _process(_delta: float) -> void:
	has_attacked = false

func on_turn_advanced() -> void:
	match ai_type:
		AIType.STATIONARY:
			return
		AIType.PACE:
			assert(false, "Pace AI not yet implemented")
			return
		AIType.RANDOM:
			assert(false, "Random AI not yet implemented")
			return
		AIType.CHASE_PLAYER:
			assert(movement_type != MovementType.MANHATTAN, "Chase player AI does not work with Manhattan movement yet")
			assert(players.size() == 1, "Chase player AI only works with one player")
			var player = players.keys()[0]
			var direction = player.position - position

			if is_zero_approx(direction.x):
				request_move.emit(Vector2i(0, signi(direction.y)))
			elif is_zero_approx(direction.y):
				request_move.emit(Vector2i(signi(direction.x), 0))
			else:
				request_move.emit(Vector2i(signi(direction.x), signi(direction.y)))

func get_power_level() -> int:
	return power_level

func get_experience_value() -> int:
	return experience_value

func apply_damage(damage: int) -> bool:
	assert(health > 0, "health must be greater than 0")
	has_attacked = true
	health = clampi(health - damage, 0, max_health)
	if health == 0:
		animation_player.play(&"death")
		return true
	return false

func on_collision(entity: Node2D) -> void:
	if has_attacked and entity is Player:
		return
	
	if entity.has_method(&"apply_damage"):
		entity.apply_damage(power_level)
	
	if entity.has_method(&"get_power_level"):
		apply_damage(entity.get_power_level())


func on_move(old_position: Vector2i, new_position: Vector2i) -> void:
	pass


func on_player_added(player: Player) -> void:
	players[player] = true

func on_player_removed(player: Player) -> void:
	players.erase(player)
