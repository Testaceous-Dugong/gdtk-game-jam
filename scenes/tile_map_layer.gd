extends TileMapLayer

@export var puzzle_bounds: Rect2i

# @export var empty_tile_coords: TileSetCoords
@export var player_tile_coords: TileSetCoords


@export var player_position: Vector2i
@export var player_power_level: int = 1
@export var player_health: int = 3

@onready var original_tiles: Dictionary = {}
@onready var tile_health: Dictionary = {}


func _ready() -> void:

	for x in range(puzzle_bounds.size.x):
		for y in range(puzzle_bounds.size.y):
			var tile_position = puzzle_bounds.position + Vector2i(x, y)
			var tile = get_cell_tile_data(tile_position)

			if tile == null:
				tile_health[tile_position] = 0
				continue

			var health: int = tile.get_custom_data(&"health")
			
			tile_health[tile_position] = health
			var tile_set_coords = TileSetCoords.new()
			tile_set_coords.atlas_index = get_cell_source_id(tile_position)
			tile_set_coords.coords = get_cell_atlas_coords(tile_position)

			original_tiles[tile_position] = tile_set_coords

	set_cell(player_position, player_tile_coords.atlas_index, player_tile_coords.coords)

			
func _process(_delta: float) -> void:
	var new_position: Vector2i = player_position
	if Input.is_action_just_pressed(&"move_up"):
		new_position = Vector2i(player_position.x, player_position.y - 1)
	elif Input.is_action_just_pressed(&"move_down"):
		new_position = Vector2i(player_position.x, player_position.y + 1)
	elif Input.is_action_just_pressed(&"move_left"):
		new_position = Vector2i(player_position.x - 1, player_position.y)
	elif Input.is_action_just_pressed(&"move_right"):
		new_position = Vector2i(player_position.x + 1, player_position.y)
	if new_position == player_position:
		return


	var tile_data = get_cell_tile_data(new_position)

	var is_solid: bool = false if tile_data == null else tile_data.get_custom_data(&"is_solid")

	if not is_solid:
		move_player(new_position)
		return
	
	if tile_data == null:
		return

	var is_enemy: bool = tile_data.get_custom_data(&"is_enemy")

	if not is_enemy:
		return
	
	var power_level: int = tile_data.get_custom_data(&"power_level")

	if power_level > player_health:
		end_game()
		return

	var health: int = tile_health[new_position]

	if health <= player_power_level:
		original_tiles.erase(new_position)
		tile_health[new_position] = 0
		move_player(new_position)
	else:
		tile_health[new_position] = health - player_power_level


func move_player(new_location: Vector2i) -> void:
	var original_coords = original_tiles.get(player_position) as TileSetCoords
	print(original_coords)
	if original_coords != null:
		set_cell(player_position, original_coords.atlas_index, original_coords.coords)
	else:
		erase_cell(player_position)
	player_position = new_location
	set_cell(player_position, player_tile_coords.atlas_index, player_tile_coords.coords)

func end_game() -> void:
	get_tree().reload_current_scene()
