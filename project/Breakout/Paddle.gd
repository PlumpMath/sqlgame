extends KinematicBody2D

const ball_scene = preload("res://Breakout/Scenes/Ball.tscn")

func _ready():
    set_process(true)
    set_process_input(true)

func _process(delta):
    var y = position.y
    var mouse_x = get_viewport().get_mouse_position().x
    
    position = Vector2(mouse_x, y)

func _input(event):
    #if event is InputEventMouseButton and event.is_pressed():
    pass