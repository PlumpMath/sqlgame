extends Tree

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    var root = create_item()
    root.set_text(0,"Animals")
    var children = ['Ducks', 'Bears', 'Ants'];
    
    for animal_type in children:
        var child = create_item(root)
        child.set_text(0,animal_type)
