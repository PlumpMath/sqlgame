extends Control

var score = 0 setget set_score
export var score_brick = 5

func set_score(value):
    score = value
    get_node("Score").set_text("Score: " + str(score))
    
func brick_hit():
    self.score += score_brick

func _ready():
    pass

func _process(delta):
    pass
