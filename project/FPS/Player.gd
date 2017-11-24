extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    set_process(true)
    pass

func _process(delta):
    move_and_slide( Vector3(0, -9.8, 0.0))
    print(translation)