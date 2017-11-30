extends HSlider

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    value = get_node("/root/Config").get_volume()
