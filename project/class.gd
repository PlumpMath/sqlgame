extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    print("Initialized")
    pass

func _button_pressed(which):
    print("Button was pressed: ", which.get_name())