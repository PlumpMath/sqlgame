extends Control

export(float) var time_before_main_menu = 3
export(NodePath) var next_scene = "res://Main Menu/Main Menu.tscn"

var _time_accum = 0
var _anim_end = false

func _ready():
    set_process(true)
    set_process_input(true)
    get_node("Fade In").connect("animation_finished", self, "on_anim_finished")

func _process(delta):
    _time_accum += delta

    if _time_accum >= time_before_main_menu:
        goto_next_scene()

func _input(ev):
    if ev is InputEventKey and ev.pressed == false and _anim_end:
        goto_next_scene()
    elif ev is InputEventKey and ev.pressed == false:
        # Goto end of animation
        var anim = get_node("Fade In")
        anim.seek(anim.get_current_animation_length(), true)
        _anim_end = true

func goto_next_scene():
    if next_scene:
        get_node("/root/SceneSwitcher").cut_to_scene(next_scene)

func on_anim_finished(name):
    if name == "Fade In":
        _anim_end = true