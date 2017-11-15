extends "res://Base/Level.gd"

export var max_criminals = 10000
var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    # Set tables
    _add_table("Criminals")

    _preview_scene()

func _start_objective_intro():
    print("Hide scene")
    UI.tab_container.set_current_tab(0)

    var characters = {
        'Agent1' : ["left", "res://Base/Images/agent1.png"],
        'Agent154' : ["left", "res://Base/Images/agent1.png"],
        'Messenger' : ["right", "res://Base/Images/handler.png"],
        'Trainer' : ["right", "res://Base/Images/handler.png"]
    }
    var dialog = [
        ['Agent154', 'Agent154 reporting sir!', 1],
        ['Messenger', 'You are no longer agent154, you are now Agent1', 1],
        ['Agent1', 'Can I ask what happened to Agents 1 - 153', 1],
        ['Messenger', 'No', 1],
        ['Messenger', 'You now work in the SQL-Genome division', 1],
        ['Agent1', 'I haven\'t heard of it', 1],
        ['Messenger', 'Good. If you had you\'d be DELETED', 1],
        ['Agent1', 'Good to know', 1],
        ['Messenger', 'We have invented a new language: SQL - Structured Query Language', 1],
        ['Agent1', 'SQL - can I pronounce it sequal?', 1],
        ['Messenger', 'No, never say that again', 1],
        ['Messenger', 'My job is to train you in your new role', 1],
        ['Agent1', 'Okay', 1],
        ['Agent1', 'Wouldn\'t that make you a trainer not a messenger?', 1],
        ['Messenger', 'I have authority to DELETE you.', 1],
        ['Trainer', 'For your first mission....', 1]
    ]
    yield(get_tree().create_timer(2), "timeout")
    emit_signal("end_objective_intro", characters, dialog)