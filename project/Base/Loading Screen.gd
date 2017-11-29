extends Control

signal finished

var _time_accum = 0
var _scene_switcher_finished = false
var _signal_sent = false
var _user_wants_to_continue = false

func _ready():
    set_process(true)
    set_process_input(true)

func _ready_to_switch():
    return _time_accum >= 3.0 and _scene_switcher_finished

var called = false
func _process(delta):
    _time_accum += delta

    if _ready_to_switch() and called == false:
        called = true
        get_node("AnimationLoading").play("AnimationLoading")

    if _ready_to_switch() and _signal_sent == false and _user_wants_to_continue:
        emit_signal("finished")
        _signal_sent = true

func _input(ev):
    if ev is InputEventKey and ev.pressed == false and _ready_to_switch():
        _user_wants_to_continue = true

func on_loading_finished():
    _scene_switcher_finished = true