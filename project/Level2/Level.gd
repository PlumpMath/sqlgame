extends "res://Base/Level.gd"

export var max_seats = 88
export var max_scientists = 10
export var max_passports = 100001
var primary_passport_ids = []
var primary_plane_part_names = []

onready var airliner = get_node('SceneVp/Spatial/Airliner')

func _ready():
    # Set tables
    _add_table("PlaneParts")
    _add_table("Tickets")
    _add_table("Passports")
    UI.objectives.get_node("Intro").set_bbcode("[b]Level 2: Loose Ends[/b]\n\n[i]The science of fireworks[/i]")
    UI.objectives.get_node("Out").set_bbcode("No hand holding this time Agent, you're on your own. Go make those passengers fly!")

    for i in range(max_scientists):
        var id
        while (1):
            id = (randi() % max_passports) + 1
            if !(id in primary_passport_ids):
                break
        primary_passport_ids.push_back(id)
    _preview_scene()
    sql_seeder._seed()

func _start_objective_intro():
    characters = {
        'Agent154' : ["left", "res://Base/Images/agent1.png"],
        'Director' : ["right", "res://Base/Images/handler.png"],
    }
    dialog = [
        ['Director', 'Good news Agent, the SQL Genome project is complete', 1],
        ['Agent154', 'So can we start controlling human DNA?', 1],
        ['Director', 'Not yet. We need to deploy a virus to install the DNA wrapper', 1],
        ['Director', 'But before we do that, we need to clean up', 1],
        ['Agent154', 'Well, true, I have rat blood on my hands', 1],
        ['Director', 'No, clean up some loose ends. To many people know about this project', 1],
        ['Director', 'There are 10 scientists who created the SQL genome wrapper', 1],
        ['Director', 'They escaped on a plane before I could erase them', 1],
        ['Agent154', 'Do we know which plane they\'re on?', 1],
        ['Director', 'Even better, we know they boarded a plane we manufactured', 1],
        ['Director', 'Various parts of this plane have been installed with an SQL wrapper', 1],
        ['Agent154', 'Excellent, lets bring down the plane with SQL...', 1],
        ['Director', 'Not so fast, we need to be inconspicuous', 1],
        ['Director', 'Taking down the whole plane will raise too many questions', 1],
        ['Agent154', 'Hmm... do we know where they\'re seated in the plane?', 1],
        ['Director', 'No, we know very little' , 1],
        ['Director', 'They hacked the national passport database to create fake identities' , 1],
        ['Agent154', 'So do we have anything?' , 1],
        ['Director', 'Nothing, except that one of the scientist created all 10 passports at once', 1],
        ['Director', 'Good luck' , 1],
        ['Director', 'Oh, one more thing - there are over 100,000 passports in that database' , 1],
        ['Agent154', 'Great...' , 1]
    ]

    print("Hide scene")
    UI.tab_container.set_current_tab(0)

    yield(get_tree().create_timer(2), "timeout")
    emit_signal("end_objective_intro", characters, dialog)
