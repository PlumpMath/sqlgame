extends "res://Base/States.gd"

func _ready():
    level._set_state("Start", "We're looking for a criminal with a [color=#9B1C31]Royal red[/color] shirt. Find and DELETE him!")
    pass

var rat_id_indices = {}

func process_row(row, headings, clause):
    var spawn = level.get_node("SceneVp/Spatial/RatSpawn")
    var id = row[0]

    if clause == 'select':
        var rat_node = spawn.get_child(rat_id_indices[id])
        if rat_node.alive:
            rat_node._highlight()

    if clause == 'insert':
        var rat_scene = load("res://Base/SQLEntities/SQLRat.tscn")
        var rat_node = rat_scene.instance()
        rat_node.id = id
        for i in range(1,row.size()):
            rat_node._set_parameter(headings[i], row[i])
        rat_node.set_translation(Vector3(randi()%21-10, 0, randi()%21-10))
        rat_node.set_rotation(Vector3(0, randf()*PI*2, 0))
        # create individual instance for eye material
        var eyes = rat_node.get_node("Model/Armature/Skeleton/Eyes")
        eyes.set_surface_material(0, eyes.get_surface_material(0).duplicate())
        var head = rat_node.get_node("Model/Armature/Skeleton/Head")
        head.set_surface_material(0, head.get_surface_material(0).duplicate())

        spawn.add_child(rat_node)
        rat_id_indices[id] = rat_node.get_index()

    if clause == 'delete':
        var rat_node = spawn.get_child(rat_id_indices[id])
        if rat_node.alive:
            _kill_rat(rat_node, 0, "Nice, cold, clean kill")

    if clause == 'update':
        var rat_node = spawn.get_child(rat_id_indices[id])
        for i in range(1, row.size()):
            if rat_node.alive:
                rat_node._set_parameter(headings[i], row[i])

func _kill_rat(rat, delay = 0, message = ''):
    yield(get_tree().create_timer(delay), "timeout")
    rat.alive = false
    rat.get_node("Model/AnimationPlayer").stop_all()
    yield(get_tree().create_timer(0.01), "timeout")
    rat.get_node("Model/AnimationPlayer").play("Die")

    if rat.id == level.primary_rat_id:
        level._set_state("Failure", "You killed my favourite rat. You're fired!")
    elif message:
        level._set_state(null, message)

    # Check how many rats are left
    var rats = level.get_node("SceneVp/Spatial/RatSpawn").get_children()
    var rat_count = 0
    for rat in rats:
        if rat.alive:
            rat_count += 1
    if rat_count == 1:
        level._set_state("Victory", "Good work. The experiment was a success.")