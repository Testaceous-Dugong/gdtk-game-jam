extends "res://scenes/enemies/enemy.gd"

func process_attack(incoming_damage: int, incoming_direction: Vector2, inflict_damage: Callable) -> bool:
	apply_damage(incoming_damage)
	has_attacked = true
	if health == 0:
		return true

	
	attack_animator.target = incoming_direction.normalized()
	animation_player.play(&"attack")
	var finished_animation = await animation_player.animation_finished
	assert(finished_animation == &"attack")

	inflict_damage.call(get_power_level())
	return false
