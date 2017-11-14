# SceneSwitcher
#
# Add SceneSwitcher to Autoload under a name (<name>) then use as:
#     get_node("/root/<name>").transition_to_scene(path_to_dest_scene, path_to_loading_scene)
# or as:
#     get_node("/root/<name>").cut_to_scene(path_to_dest_scene)
#
# A cut will simply move from the current scene to another, blocking while
# loading.
#
# A transition will load the loading scene first in a blocking manner, and then
# begin loading the destination scene in a non-blocking manner. Loading progress
# is passed via a "on_loading_progress" function on the loading scene and a
# "on_loading_finished" function on the loading scene is called when loading is
# done. The SceneSwitcher will then wait for the loading_scene to emit a
# "finished" signal (if one exists) before it moves to the next scene.
extends Node

signal scene_loaded
signal scene_progress(progress)

var current_scene = null
var loading_scene = null
var destination_scene = null
var time_max = 100 # milliseconds

var loader_non_blocking = null

var _should_transition = false

func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)
    set_process(false)

func cut_to_scene(dest_scene_path):
    call_deferred("_deferred_cut_to_scene", dest_scene_path)

func transition_to_scene(dest_scene_path, loading_scene_path):
    call_deferred("_deferred_transition_to_scene", dest_scene_path, loading_scene_path)

func _deferred_cut_to_scene(dest_scene_path):
    # Load destination scene
    var r = ResourceLoader.load(dest_scene_path)

    # Instantiate destination scene
    destination_scene = r.instance()

    # Free current scene (deferred call therefore safe)
    current_scene.free()

    # Add destination scene to scene tree
    get_tree().get_root().add_child(destination_scene)
    get_tree().set_current_scene(destination_scene)
    current_scene = destination_scene

func _deferred_transition_to_scene(scene_path, loading_scene_path):
    # Prepare interactive loader for next scene
    loader_non_blocking = ResourceLoader.load_interactive(scene_path)
    if loader_non_blocking == null:
        show_error()
        return
    set_process(true)

    # Load loading scene
    var r = ResourceLoader.load(loading_scene_path)

    # Instantiate loading scene
    loading_scene = r.instance()

    # Free current scene (deferred call therefore safe)
    current_scene.free()

    # Add loading scene to scene tree
    get_tree().get_root().add_child(loading_scene)
    get_tree().set_current_scene(loading_scene)
    current_scene = loading_scene

    # Let the loading_scene tell us when it's ready to transition to next scene

    # Check for signal!!
    loading_scene.connect("finished", self, "_callback_loading_scene_finished")

    # Let us tell the loading_scene when we're done loading
    if loading_scene.has_method("on_loading_finished"):
        self.connect("scene_loaded", loading_scene, "on_loading_finished")
    # And how we are progressing
    if loading_scene.has_method("on_loading_progress"):
        self.connect("scene_progress", loading_scene, "on_loading_progress")

func _callback_loading_scene_finished():
    # Remove loading scene
    call_deferred("_free_loading_scene")

    # Add next scene
    get_tree().get_root().add_child(destination_scene)
    get_tree().set_current_scene(destination_scene)

    current_scene = destination_scene

    # Stop processing
    set_process(false)

func _process(delta):
    # For time_max msec a frame
    var t = OS.get_ticks_msec()
    while OS.get_ticks_msec() < t + time_max:
        # Load a little of the resource
        var err = loader_non_blocking.poll()

        if err == ERR_FILE_EOF: # Loading finished
            _on_loading_finished()
            break
        elif err == OK:
            _on_loading_progress()
            break
        else:
            show_error()
            loader_non_blocking = null
            break

func _on_loading_finished():
    # Instance destination scene
    destination_scene = loader_non_blocking.get_resource().instance()

    # Send 'scene_loaded' signal (to loading_scene)
    emit_signal("scene_loaded")

func _on_loading_progress():
    # Send 'scene_progress' signal (to loading_scene)
    var progress = float(loader_non_blocking.get_stage()) / loader_non_blocking.get_stage_count()
    emit_signal("scene_progress",  progress)

func _free_loading_scene():
    if loading_scene != null:
        loading_scene.free()