extends CheckButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    pressed = get_node("/root/Config").get_mute()