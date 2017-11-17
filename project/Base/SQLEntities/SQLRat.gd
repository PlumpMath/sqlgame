extends Spatial

onready var level = get_tree().get_root().get_node("Level1")
onready var camera = level.get_node("SceneVp/Spatial/Camera")

onready var target_rot = get_transform().basis
var rotation_speed = 1
var translation_speed = 2

func _ready():
    set_physics_process(true)
    

func _physics_process(delta):
    var forward = get_transform().basis[2]

    var move_vector = Vector3(forward.x, 0, forward.z) * translation_speed;
    move_and_collide(move_vector * delta)

    var current_rot = Quat(get_transform().basis)

    var angle_diff = (target_rot.get_euler() - Basis(current_rot).get_euler())
    if abs(angle_diff.y) > 0.1:
        var smooth_rot = current_rot.slerp(target_rot, delta * rotation_speed)
        set_transform(Transform(smooth_rot, get_transform().origin))

    var t = get_transform()
    t.origin.y = 0
    set_transform(t)
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





func _on_Area_body_shape_exited( body_id, body, body_shape, area_shape ):
    print("HELP")


func _on_Area_area_exited( area ):
    print("HELP")


func _on_Area_body_exited( body ):
    print("HELP")
