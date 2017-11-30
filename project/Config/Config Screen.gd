extends Control

export(NodePath) var main_menu_scene = "res://Main Menu/Main Menu.tscn"

func _ready():
    pass

func _on_Volume_Slider_value_changed( value ):
    get_node("/root/Config").set_volume(value)


func _on_CheckButton_toggled( pressed ):
    get_node("/root/Config").set_mute(pressed)


func _on_Fullscreen_toggled( pressed ):
    get_node("/root/Config").set_fullscreen(pressed)

func _on_Submit_button_up():
    var width = get_node('Settings/GridContainer/GridContainer/Width').text
    var height = get_node('Settings/GridContainer/GridContainer/Height').text
    get_node("/root/Config").set_resolution(width, height)

func _on_Button_button_up():
    if main_menu_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(main_menu_scene)