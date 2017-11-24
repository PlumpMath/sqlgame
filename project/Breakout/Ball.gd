extends RigidBody2D

export var SPEEDUP = 8
export var MAXSPEED = 300

signal hit_brick

func _ready():
    set_process(true)
    linear_velocity = Vector2(0, 0)

func _process(delta):
    var bodies = get_colliding_bodies()
    
    for body in bodies:
        if body.is_in_group("Bricks"):
            body.queue_free()
            emit_signal("hit_brick")
            print('emit')
#        if body.is_in_group("Paddles"):
#            var speed = linear_velocity.length()
#            var direction = position - body.get_node("Anchor").get_global_position()
#            var velocity = direction.normalized() * min(speed + SPEEDUP, MAXSPEED)
#            linear_velocity = velocity
    
    if position.y > get_viewport_rect().end.y:
        queue_free()