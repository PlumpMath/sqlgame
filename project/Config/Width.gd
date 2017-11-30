extends TextEdit

func _ready():
    text = String(get_node("/root/Config").get_resolution().x)