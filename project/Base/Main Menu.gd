extends Control

export(NodePath) var next_scene = "res://Level1/Level1.tscn"
export(NodePath) var loading_scene = "res://Base/Loading Screen.tscn"

func _ready():
    var viewport = get_node("Viewport")
    
    var window_size = OS.get_window_size()
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