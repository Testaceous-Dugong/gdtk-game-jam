extends "res://scenes/enemies/enemy.gd"

func process_attack(incoming_damage: int, inflict_damage: Callable) -> bool:
	apply_damage(incoming_damage)
	has_attacked = true
	if health == 0:
		return true
	inflict_damage.call(get_power_level())
	return false