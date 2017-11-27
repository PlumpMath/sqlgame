extends "res://Base/Level.gd"

export var max_rats = 20
onready var primary_rat_id = (randi() % max_rats) + 1

onready var rat_spawner = get_node("SceneVp/Spatial/RatSpawn")

func _ready():
    # Set tables
    _add_table("LabRats")
    _preview_scene()
    var rat_node = rat_spawner.get_child(states.rat_id_indices[primary_rat_id])
    var body = rat_node.get_node("Model/Armature/Skeleton/Body")
    var body_mat = body.get_surface_material(0).duplicate()
    body_mat.albedo_color = Color(0, 0, 0)
    body.set_surface_material(0, body_mat)

func _start_objective_intro():
    characters = {
        'Agent1' : ["left", "res://Base/Images/agent1.png"],
        'Agent154' : ["left", "res://Base/Images/agent1.png"],
        'Director' : ["right", "res://Base/Images/handler.png"],
        'Trainer' : ["right", "res://Base/Images/handler.png"]
    }
    dialog = [
        ['Agent154', 'Agent154 reporting, sir!', 1],
        ['Director', 'Welcome to the ORDER division. You will report directly to me', 1],
        ['Agent154', 'Yes, sir.\nWhat\'s with the rats?', 1],
        ['Director', 'Have you heard of SQL, Structured Query Language?', 1],
        ['Agent154', 'Yes, I believe it was invented earlier this year', 1],
        ['Agent154', 'Can I pronounce it "sequel"?', 1],
        ['Director', 'No, never say that again', 1],
        ['Director', 'SQL allows us to quickly manipulate data', 1],
        ['Director', 'We can DELETE huge sets of data with one small command', 1],
        ['Agent154', 'Interesting. I wish we could manipulate people like that', 1],
        ['Director', 'As did I..', 1],
        ['Director', 'Which is precisely why I started the SQLGenome project', 1],
        ['Agent154', 'Okay...', 1],
        ['Director', 'It\'s basically a wrapper between SQL and Human DNA' , 1],
        ['Agent154', 'Is that.. safe?' , 1],
        ['Director', 'Not sure. Hence the Rats. We need you to learn SQL, and fast', 1],
        ['Agent154', 'How should I train?' , 1],
        ['Director', 'You\'ll figure it out' , 1],
        ['Director', 'Just one more thing - don\'t kill the black rat' , 1],
        ['Director', 'I\'ve grown rather fond of it' , 1],
        ['Director', 'Now go show those rats the power of SQL' , 4]
    ]

    print("Hide scene")
    UI.tab_container.set_current_tab(0)

    yield(get_tree().create_timer(2), "timeout")
    emit_signal("end_objective_intro", characters, dialog)
