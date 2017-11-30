extends Control

export(NodePath) var next_scene = "res://Level1/Level1.tscn"
export(NodePath) var loading_scene = "res://Base/Loading Screen.tscn"
export(NodePath) var credits_scene = "res://Credits/Credits.tscn"
export(NodePath) var config_scene = "res://Config/Config Screen.tscn"

func _ready():
    var viewport = get_node("Viewport")
    
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    
    
    var window_size = get_viewport().get_visible_rect().size
    viewport.size.x = window_size.x
    viewport.size.y = window_size.y
    
    get_node("TextureRect").texture = viewport.get_texture()

func _exit_game():
    get_tree().quit()

func _on_Exit_button_up():
    _exit_game()

func _on_Start_Game_button_up():
    if next_scene:
        if loading_scene:
            get_node("/root/SceneSwitcher").transition_to_scene(next_scene, loading_scene)
        else:
            get_node("/root/SceneSwitcher").cut_to_scene(next_scene)

func _on_Credits_button_up():
    if credits_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(credits_scene)

func _on_Options_button_up():
    if config_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(config_scene)
