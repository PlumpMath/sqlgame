extends Control

signal finished

var _time_accum = 0

func _ready():
    set_process(true)
    pass
    
func _process(delta):
    _time_accum += delta
    
func on_loading_finished():
    if _time_accum >= 3.0:
        emit_signal("finished")