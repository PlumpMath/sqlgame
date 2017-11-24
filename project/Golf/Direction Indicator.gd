extends Node2D

var points = [Vector2()]

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    set_process(true)
    
    #call_deferred("get_ball_parameters")
    
#func _draw():
    #Sfor i in range(0, points.size() - 1):
        #draw_line(points[i], points[i+1], Color(1, 0, 0, 1), 3)
        #draw_circle(points[i], 1, Color(1, 1, 1, 1))
    #if (get_parent().get_node('Ball')):
        #var ball_pos_rel = get_parent().get_node('Ball').position
        #var ball_to_mouse = (get_parent().get_node('Ball').get_global_position() - get_viewport().get_mouse_position()).normalized()

        #draw_line(ball_pos_rel, ball_pos_rel + -50.0 * ball_to_mouse, Color(1,1,1,1), 1)

func _process(delta):
    var ball = get_parent().get_node('Ball')
    
#    if ball:
#        var _position = ball.position
#        var _linear_velocity = ball.linear_velocity
#        var _weight = ball.weight
#        var _gravity_scale = ball.gravity_scale
#
#        print(_position)
#        print(_linear_velocity)
#        print(_weight)
#        print(_gravity_scale)
#
#        _linear_velocity = Vector2(100, -100)/ball.mass
#
#        for i in range(200):
#            points.append(_position) 
#            _position += (_linear_velocity + Vector2(0, 0.5 * (_weight * _gravity_scale) * delta)) * delta
#
#        print(points)
#        print('---')
        
        
    update()
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
