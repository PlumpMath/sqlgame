extends Node2D

const ball_scene = preload("res://Breakout/Scenes/Ball.tscn")

var ball = null

func _ready():            
    ball = ball_scene.instance()
    ball.position =  Vector2(0, -16)
    ball.connect("hit_brick", get_parent(), "brick_hit")
    call_deferred("add_child", ball)
    
    set_process(true)
    set_process_input(true)

func _process(delta):
    pass    

func _input(event):
    if event is InputEventMouseButton and event.is_pressed():
        ball.apply_impulse(Vector2(0, 0), Vector2(100, -100))
        ball.gravity_scale = 1
        