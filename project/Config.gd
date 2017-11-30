extends Node

var _config_file_path = "user://settings.cfg"
onready var _root = get_tree().get_root()
var _config = null

func _ready():
    _config = ConfigFile.new()
    var err = _config.load(_config_file_path)

    if err == OK:
        var screen_width = _config.get_value("display", "width", 1024)
        var screen_height = _config.get_value("display", "height", 768)
        var screen_fullscreen = _config.get_value("display", "fullscreen", false)

        set_resolution(screen_width, screen_height)
        set_fullscreen(screen_fullscreen)
        
        var mute = _config.get_value("audio", "mute", false)
        var vol = _config.get_value("audio", "vol", 100)

        set_mute(mute)
        set_volume(vol)
    else:
        var new_config_file = File.new()
        new_config_file.open(_config_file_path, File.WRITE)
        
        new_config_file.store_line("[display]")
        new_config_file.store_line("width=1024")
        new_config_file.store_line("height=768")
        new_config_file.store_line("fullscreen=false")
        
        new_config_file.store_line("[audio]")
        new_config_file.store_line("mute=false")
        new_config_file.store_line("vol=100")
        
        new_config_file.close()
        
        err = _config.load(_config_file_path)
        if err != OK:
            print("Failed to load config")

func set_resolution(width, height):
    OS.set_window_size(Vector2(width, height))

    if _config:
        _config.set_value("display", "width", width)
        _config.set_value("display", "height", height)
        _config.save(_config_file_path)

func get_resolution():
    return OS.get_window_size()

func set_fullscreen(fullscreen):
    OS.set_window_fullscreen(fullscreen)

    if _config:
        _config.set_value("display", "fullscreen", fullscreen)
        _config.save(_config_file_path)

func get_fullscreen():
    return OS.is_window_fullscreen()

func set_mute(should_mute):
    AudioServer.set_bus_mute(0, should_mute)
    
    if _config:
        _config.set_value("audio", "mute", should_mute)
        _config.save(_config_file_path)

func get_mute():
    return AudioServer.is_bus_mute(0)

func set_volume(vol):
    # Map 0 - 100 volume range to -40db to 0db volume range (I know, it shouldn't be linear)
    var vol_db = ((vol/100.0) - 1) * 40

    AudioServer.set_bus_volume_db(0, vol_db)
    
    if _config:
        _config.set_value("audio", "vol", vol)
        _config.save(_config_file_path)

func get_volume():
    var vol_db = AudioServer.get_bus_volume_db(0)
    
    var vol = ((vol_db / 40.0) + 1) * 100.0
    
    return vol

func os_open_data_dir():
    OS.shell_open(str("file://", OS.get_data_dir()))