extends Node

var _fader_state = null
var _stop_fading = false

func _fade_in_execute(sound, delta):
    if _fader_state == null:
        _fader_state = _fadeIn(sound, delta)
    else:
        _fader_state = _fader_state.resume()
        
        if _fader_state == null:
            _stop_fading = true

var _delay_state = null
var _stop_delaying = false

func _delay_execute(sound, delta, delay):
    if _delay_state == null:
        _delay_state = _delay(sound, delta, delay)
    else:
        _delay_state = _delay_state.resume()
        
        if _delay_state == null:
            _stop_delaying = true

func _delay(sound, delta, delay):
    var time_accum = 0
    while time_accum < delay:
        print(time_accum)
        time_accum += delta
        yield()
    sound.volume_db = -80
    _change_music(sound)

var main_music = null
var level1_music = null
var current_music = null

func _change_music(music):
    if current_music != null:
        current_music.stop()
    
    current_music = music
    current_music.connect('finished', self, '_loop')
    current_music.play()

func _loop():
    current_music.play()

func _ready():
    main_music = get_node('Main Menus')
    level1_music = get_node('Level1')
    #main_music.volume_db = -80
    #main_music.play()
    
    get_node("/root/SceneSwitcher").connect("scene_switched", self, "_new_scene")
    set_process(true)

func _process(delta):
    #pass

    if _stop_delaying == false:
        _delay_execute(main_music, delta, 1)
    else:
        if _stop_fading == false:
            _fade_in_execute(main_music, delta)
            
func _new_scene(old_scene_path, new_scene_path):
    if new_scene_path == "res://Level1/Level1.tscn":
        _change_music(level1_music)
    elif new_scene_path == "res://Main Menu/Main Menu.tscn" and old_scene_path != "res://Base/Splash Screen.tscn":
        _change_music(main_music)

func _fadeIn(sound, delta, start_db = -80, dest_db = 0):
    sound.volume_db = start_db
    while sound.volume_db < dest_db:
        sound.volume_db += 100 * delta
        print(sound.volume_db)
        if sound.volume_db > 0:
            sound.volume_db = 0
        
        yield()