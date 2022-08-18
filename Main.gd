extends Node2D

const CONFIG_FILE = "user://config.cfg"
const TOOLS_PATH = "res://tools"

var ALL_TOOLS = []

func _ready():
    randomize()
    Loading.hide()
    var temp = File.new()
    temp.open(CONFIG_FILE, File.WRITE)
    temp.store_string("first_launch true")
    #copy tool data to user:// folders here
    #set first_launch to false

    load_all_tools("res://tools")
    make_all_tool_buttons()
    show_tool(0)

    var DESKTOP = false
    if DESKTOP:
        var screen_res = OS.get_screen_size()
        var cam_height_ratio = (screen_res[1] * 3/4) / 2400
        OS.set_window_size(Vector2(1080 * cam_height_ratio, (screen_res[1] * 3/4)))

func show_tool(index):
    hide_all_tools()
    pass
    #t.set("focus/ignore_mouse", false)
    #t.show()

func hide_all_tools():
    for t in ALL_TOOLS:
        t.hide()
        t.set("focus/ignore_mouse", true)

func load_all_tools(d):
    var bad_dirs = ["", ".", ".."]
    #print(d)
    var dir = Directory.new()
    dir.open(d)
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if dir.current_is_dir():
            if not file in bad_dirs:
                #print(file)
                load_all_tools(TOOLS_PATH + "/" + file)
        else:
            if not file in bad_dirs:
                if file.get_extension() == "tscn":
                    #print(TOOLS_PATH + "/" + d + file)
                    var new_inst = load(d + "/" +  file).instance()
                    #new_inst.instance()
                    add_child(new_inst)
                    ALL_TOOLS.append(new_inst)
                    #print(file)
        file = dir.get_next()
    dir.list_dir_end()
    #print(ALL_TOOLS)


func make_all_tool_buttons():
    for t in ALL_TOOLS:
        var new_button = $ButtonToolBase.duplicate()
        new_button.show()
        $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.add_child(new_button)
        new_button.text = t.NAME

    #this is black magic to skip a frame and get updated values and presumably works for collision shit?
    yield(get_tree(), "idle_frame")
    var diff = $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_size.x - $ControlToolbox/ControlToolButtonsContainer.rect_size.x
    print($ControlToolbox.rect_size.x)
    if diff > 0:
        print(diff)
        $ControlToolbox/ScrollbarTools.max_value = diff
        $ControlToolbox/ScrollbarTools.step = float(diff) / 100.0
    else:
        $ControlToolbox/ScrollbarTools.max_value = 0
        $ControlToolbox/ScrollbarTools.step = 0


func _on_ButtonConfigure_pressed():
    pass

func _on_ScrollbarTools_value_changed(value):
    $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_position.x = -1 * value

