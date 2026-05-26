extends Node

@onready var main_menu := %MainMenu as InstancePlaceholder
@onready var controls_tutorial := %ControlsTutorial as InstancePlaceholder
@onready var gameplay := %Game as InstancePlaceholder


func change_to_main_menu() -> void:
  get_tree().change_scene_to_file.call_deferred(main_menu.get_instance_path())

func change_to_controls_tutorial() -> void:
  get_tree().change_scene_to_file.call_deferred(controls_tutorial.get_instance_path())

func change_to_level(level_num := 0) -> void:
  get_tree().change_scene_to_file.call_deferred(gameplay.get_instance_path())
  await get_tree().process_frame
  get_tree().current_scene.set_current_level(level_num)
