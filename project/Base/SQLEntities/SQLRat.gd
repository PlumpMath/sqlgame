extends Spatial

onready var level = get_tree().get_root().get_node("Level1")
onready var camera = level.get_node("SceneVp/Spatial/Camera")

onready var target_rot = get_transform().basis

var id = 1
var nickname = ""
var colour = ""
var adrenaline = 1
var size = 1

func _ready():
    set_physics_process(true)

func _physics_process(delta):
    var forward = get_transform().basis[2]

    var move_vector = Vector3(forward.x, 0, forward.z) * adrenaline * 2;
    move_and_slide(move_vector)

    var current_rot = Quat(get_transform().basis)

    #var angle_diff = (target_rot.get_euler() - Basis(current_rot).get_euler())
    #if abs(angle_diff.y) > 0.1:
    var smooth_rot = current_rot.slerp(target_rot, delta * adrenaline)
    var origin = get_transform().origin
    origin.y = 0
    set_transform(Transform(smooth_rot, origin))

    var t = get_transform()

    var look_at
    if t.origin.x > 11 and forward.x > 0:
        look_at = Vector3(randf() * 10 + 100, 0, randf() * 100 - 50)
        target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
    if t.origin.x < -11 and forward.x < 0:
        look_at = Vector3(randf() * -10 - 100, 0, randf() * 100 - 50)
        target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
    if t.origin.z > 11 and forward.z > 0:
        look_at = Vector3(randf() * 100 - 50, 0, randf() * 100 + 100)
        target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
    if t.origin.z < -11 and forward.z < 0:
        look_at = Vector3(randf() * 100 - 50, 0, randf() * -100 - 100)
        target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis

        #if t.origin.x > 11 or t.origin.z > 11 or t.origin.x < -11 or t.origin.z < -11:
        #    var look_x = forward.x * 10#randf() * 20 - 10#position.x * 20 + (randi() % 30) - 15
        #    var look_z = forward.z * 10#randf() * 20 - 10#position.z * 20 + (randi() % 30) - 15
        #    look_at(Vector3(look_x, 0, look_z), Vector3(0,1,0))
        #    #var look_at = Vector3()
        #look_at(look_at, Vector3(0,1,0))
        #set_translation(look_at)
        #target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
        #print(target_rot.get_euler())
        #set_rotation(target_rot.get_euler())

func _set_parameter(param, value):
    if param == 'size':
        size = value
        set_scale(Vector3(value, value, value))
    elif param == 'adrenaline':
        adrenaline = value
        if adrenaline == 0:
            get_player().play("Idle.00" + str(randi()%3))
            get_player().seek(randf()*30)
        elif adrenaline < 1.5:
            get_player().play("Walk", -1, adrenaline)
            get_player().seek(randf())
        else:
            get_player().play("Run", -1, adrenaline * 0.5)
            get_player().seek(randf())

    elif param == 'nickname':
        get_player().play("Run", -1, adrenaline * 0.5)
        nickname = value
    elif param == 'eye_colour':
        colour = value
        var colour_rgbs = {
            "Red" : [0.901,0.098,0.294],
            "Green" : [0.235,0.705,0.294],
            "Yellow" : [1,0.882,0.098],
            "Blue" : [0,0.509,0.784],
            "Orange" : [0.960,0.509,0.188],
            "Purple" : [0.568,0.117,0.705],
            "Cyan" : [0.274,0.941,0.941],
            "Magenta" : [0.941,0.196,0.901],
            "Lime" : [0.823,0.960,0.235],
            "Pink" : [0.980,0.745,0.745],
            "Teal" : [0,0.501,0.501],
            "Lavender" : [0.901,0.745,1],
            "Brown" : [0.666,0.431,0.156],
            "Beige" : [1,0.980,0.784],
            "Maroon" : [0.501,0,0],
            "Mint" : [0.666,1,0.764],
            "Olive" : [0.501,0.501,0],
            "Coral" : [1,0.843,0.705],
            "Navy" : [0,0,0.501],
            "Grey" : [0.501,0.501,0.501],
            "White" : [1,1,1],
            "Black" : [0,0,0]            
        }
        var rgb = colour_rgbs[colour]
        var body = get_node("Scene Root2/Armature/Skeleton/Eyes")
        var material = body.get_surface_material(0)
        #material.set_albedo(Color(rgb[0], rgb[1], rgb[2]))
        material.set_emission(Color(rgb[0], rgb[1], rgb[2]))
        material.set_emission_energy(10)
        material.set_feature(material.FEATURE_EMISSION, true)
    elif param == 'id':
        id = value
        
func get_player():
    return get_node("Scene Root2/AnimationPlayer")