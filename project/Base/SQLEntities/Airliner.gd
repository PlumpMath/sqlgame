extends Spatial

onready var rot_tween = get_node("RotTween")
onready var pos_tween = get_node("PosTween")
onready var original_pos = translation
onready var original_rot = rotation
onready var rot_timer = 0
onready var pos_timer = 0
onready var lower_blood_opacity = 0
onready var mid_blood_opacity = 0
onready var upper_blood_opacity = 0

func _ready():
    set_process(true)
    _randomize_position()
    _randomize_rotation()

func _process(delta):

    rot_timer += delta
    pos_timer += delta

    if randf() < 0.2 * delta and pos_timer > 9:
        _randomize_position()
        pos_timer = 0

    if randf() < 0.2 * delta and rot_timer > 9:
        _randomize_rotation()
        rot_timer = 0

func _randomize_position():
    var target_pos = original_pos + Vector3((randf() - 0.5) * 5, (randf() - 0.5) * 5, (randf() - 0.5) * 2)
    pos_tween.interpolate_property(self, "translation", translation, target_pos, 10.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    pos_tween.start()

func _randomize_rotation():
    var target_rot = original_rot + Vector3((randf() - 0.5) * 0.4, 0, (randf() - 0.5) * 0.4)
    rot_tween.interpolate_property(self, "rotation", rotation, target_rot, 10.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    rot_tween.start()

func _eject_seat(name):
    var seat = get_node("Passengers/" + name)
    if seat:
        seat._eject()
