extends Particles

onready var tween_node = get_node("Tween")
onready var original_pos = translation
onready var target_pos = original_pos

func _ready():
    #tween_node.follow_property(self, "translation", translation, self, "target_pos", 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
    set_process(true)
    _randomize_target()

func _process(delta):

    if randf() < 0.1 * delta:
        _randomize_target()

func _randomize_target():
    target_pos = original_pos + Vector3(0, (randf() - 0.5) * 100, 0)
    tween_node.interpolate_property(self, "translation", translation, target_pos, 10.0, Tween.TRANS_SINE, Tween.EASE_OUT_IN)
    tween_node.start()
    print(target_pos)