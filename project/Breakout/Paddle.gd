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
    if event is InputEventMouseButton and event.is_pressed():
        var ball = ball_scene.instance()
        ball.position += Vector2(0, 16)
        ball.connect("hit_brick", get_parent(), "brick_hit")
        get_parent().add_child(ball)