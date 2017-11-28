extends Spatial

onready var level = get_tree().get_root().get_node("Level1")
onready var camera = level.get_node("SceneVp/Spatial/Camera")
onready var target_rot = get_transform().basis

var id = 1
var nickname = ""
var color = ""
var adrenaline = 1
var size = 1
var alive = true

func _ready():
    set_physics_process(true)

func _physics_process(delta):
    if alive:
        var t = get_transform()
        var forward = get_global_transform().basis.xform(Vector3(0, 0, adrenaline * 2 * size))
        var target_forward = target_rot.xform(Vector3(0, 0, 1))
        var current_rot = Quat(t.basis)
        var look_at
        if t.origin.x + size > 12 and target_forward.x > 0:
            look_at = Vector3(randf() * 10 + 100, 0, randf() * 300 - 150)
            target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
        if t.origin.x - size < -12 and target_forward.x < 0:
            look_at = Vector3(randf() * -10 - 100, 0, randf() * 300 - 150)
            target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
        if t.origin.z + size > 12 and target_forward.z > 0:
            look_at = Vector3(randf() * 300 - 150, 0, randf() * 100 + 100)
            target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
        if t.origin.z - size < -12 and target_forward.z < 0:
            look_at = Vector3(randf() * 300 - 150, 0, randf() * -100 - 100)
            target_rot = t.looking_at(look_at, Vector3(0,1,0)).basis
    
        var smooth_rot = current_rot.slerp(target_rot, delta * adrenaline)
        var origin = t.origin
        origin.y = 0
        set_transform(Transform(smooth_rot, origin))
        move_and_collide(forward * delta)

func _set_parameter(param, value):
    if !alive:
        return
    if param == 'size':
        size = min(value, 2.0)
        if value > 2:
            level.states._kill_rat(self, 0.5, "Oops. I don't think they're meant to get that size")

        var col_box = get_node("CollisionBox")
        col_box.shape.set_extents(Vector3(0.3 * size, 0.3 * size, 1.2 * size))
        var model = get_node("Model")
        model.scale.x = size
        model.scale.y = size
        model.scale.z = size
        var size_category = int(size * 4)
        set_collision_layer(0)
        set_collision_layer_bit(size_category, 1)
        set_collision_mask(0)
        set_collision_mask_bit(size_category, 1)
        set_collision_mask_bit(size_category + 1, 1)
        if size_category != 0:
            set_collision_mask_bit(size_category - 1, 1)

        #set_scale(Vector3(value, value, value))
    elif param == 'adrenaline':
        adrenaline = min(value, 5.0)
        if value > 5:
            level.states._kill_rat(self, 5, "Heart attack I guess")
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
    elif param == 'eye_color':
        color = value
        var color_rgbs = {
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
        var rgb
        if color in color_rgbs:
            rgb = color_rgbs[color]
        else:
            rgb = [1,1,1]
        var body = get_node("Model/Armature/Skeleton/Eyes")
        var material = body.get_surface_material(0)
        #material.set_albedo(Color(rgb[0], rgb[1], rgb[2]))
        material.set_albedo(Color(rgb[0], rgb[1], rgb[2]))
        material.set_emission(Color(rgb[0], rgb[1], rgb[2]))
        material.set_emission_energy(1)
        material.set_feature(material.FEATURE_EMISSION, true)
    elif param == 'id':
        id = value

func _highlight():
    get_node("Model/Highlighter").play("Highlight")

    #var head_material = get_node("Model/Armature/Skeleton/Head").get_surface_material(0)
    #head_material.set_emission(Color(1,1,1))
    #head_material.set_emission_energy(0.2)
    #head_material.set_feature(head_material.FEATURE_EMISSION, true)
    #head_material.set_feature(head_material.FEATURE_EMISSION, false)

func get_player():
    return get_node("Model/AnimationPlayer")