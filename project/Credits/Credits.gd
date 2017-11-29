extends Control

export(NodePath) var main_menu_scene = "res://Main Menu/Main Menu.tscn"

func _ready():
    set_process_input(true)

func _on_Back_button_up():
    if main_menu_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(main_menu_scene)