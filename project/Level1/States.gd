extends "res://Base/States.gd"

func _ready():
    level._set_state("Start", "We're looking for a criminal with a [color=#9B1C31]Royal red[/color] shirt. Find and DELETE him!")
    pass

var rat_id_indices = {}

func process_row(row, headings, clause):
    var spawn = level.get_node("SceneVp/Spatial/RatSpawn")
    var id = row[0]

    if clause == 'insert':
        var rat_scene = load("res://Base/SQLEntities/SQLRat.tscn")
        var rat_node = rat_scene.instance()
        rat_node.id = id
        for i in range(1,row.size()):
            rat_node._set_parameter(headings[i], row[i])
        rat_node.set_translation(Vector3(randi()%21-10, 0, randi()%21-10))
        rat_node.set_rotation(Vector3(0, randf()*PI*2, 0))

        spawn.add_child(rat_node)
        rat_id_indices[id] = rat_node.get_index()
    if clause == 'update':
        var rat_node = spawn.get_child(rat_id_indices[id])
        for i in range(1, row.size()):
            rat_node._set_parameter(headings[i], row[i])

func _state_update(message):
    if level._is_state("Victory"):
        level.get_node("SceneVp/Spatial/MeshInstance").scale = Vector3(0.2,0.2,0.2)
    if level._is_state("Failure"):
        pass
        #level.UI.viewport_texture.modulate.r = 1
        #level.UI.viewport_texture.modulate.g = 0.5
        #level.UI.viewport_texture.modulate.b = 0.5