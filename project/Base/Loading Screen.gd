extends Control

signal finished

var _time_accum = 0
var _scene_switcher_finished = false
var _signal_sent = false

func _ready():
    set_process(true)
    pass
    
func _process(delta):
    _time_accum += delta
    
    if _time_accum >= 3.0 and _scene_switcher_finished and _signal_sent == false:
        emit_signal("finished")
        _signal_sent = true
    
func on_loading_finished():
    _scene_switcher_finished = true