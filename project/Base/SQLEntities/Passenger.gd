extends Spatial

onready var rot_tween = get_node("RotTween")
onready var pos_tween = get_node("PosTween")
onready var original_pos = translation
onready var original_rot = rotation
onready var airliner = get_parent().get_parent()

var dead = false


func _ready():
    pass

func _randomize_position():
    var target_pos = original_pos + Vector3(randf() * 0.5, randf() * 2 + 2, -2)
    pos_tween.interpolate_property(self, "translation:z", translation.z, target_pos.z, 2.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
    pos_tween.interpolate_property(self, "translation:y", translation.y, target_pos.y, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    pos_tween.start()

func _randomize_rotation():
    var target_rot = original_rot + Vector3((randf() - 0.5) * 2.4, (randf() - 0.5) * 2.4, (randf() - 0.5) * 2.4)
    rot_tween.interpolate_property(self, "rotation", rotation, target_rot, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    rot_tween.start()

func _eject():
    dead = true
    # Reparent outside plane
    #var target = get_node("../../../DeadPassengers")
    #var source = self
    #get_parent().remove_child(self)
    #target.add_child(self)
    #self.set_owner(target)
    _randomize_position()
    _randomize_rotation()
    yield(get_tree().create_timer(2), "timeout")
    get_node("BloodParticles").emitting = true
    get_node("Cube").visible = false
    get_node("Cube.001").visible = false
    get_node("Stickman").visible = false
    get_node("EjectAudio").play()

    var distance_to_end = translation.distance_to(Vector3(0, translation.y, -3))
    yield(get_tree().create_timer(sqrt(distance_to_end) / 2), "timeout")

    var paint_node
    var paint_opacity
    if translation.y > 3:
        paint_node = airliner.get_node("BloodPaintUpper")
        if airliner.upper_blood_opacity < 1.4:
            airliner.upper_blood_opacity += 0.04
        paint_opacity = airliner.upper_blood_opacity
    elif translation.y > 2:
        paint_node = airliner.get_node("BloodPaintMid")
        if airliner.mid_blood_opacity < 1.4:
            airliner.mid_blood_opacity += 0.04
        paint_opacity = airliner.mid_blood_opacity
    else:
        paint_node = airliner.get_node("BloodPaintLower")
        if airliner.lower_blood_opacity < 1.4:
            airliner.lower_blood_opacity += 0.04
        paint_opacity = airliner.lower_blood_opacity

    for blood in paint_node.get_children():
        blood.get_surface_material(0).albedo_color = Color(1, 1, 1, paint_opacity)

    paint_node.visible = true
