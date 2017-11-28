extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    set_process(true)
    pass

func _process(delta):
    #rotation_degrees += Vector3(100*delta, 0, 0)
    rotate_y(0.35*delta)
    pass