extends Control

export(float) var time_before_main_menu = 3
export(NodePath) var next_scene = "res://Base/Main Menu.tscn"

var _time_accum = 0

func _ready():
    set_process(true)
    set_process_input(true)

func _process(delta):
    _time_accum += delta
    
    if _time_accum >= time_before_main_menu:
        goto_next_scene()
        
func _input(ev):
    if ev is InputEventKey:
        goto_next_scene()
        
func goto_next_scene():
    if next_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(next_scene)