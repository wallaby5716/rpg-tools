extends Node2D

const CONFIG_FILE = "user://config.cfg"
const TOOLS_PATH = "res://tools"

#make a list of loaded tools in the settings screen, with checkboxes to enable/disable them.
#on quit save all enabled tools to our config.cfg
var ALL_TOOLS = {}

func _ready():
    randomize()
    Loading.show()
    var temp = File.new()
    temp.open(CONFIG_FILE, File.WRITE)
    temp.store_string("first_launch true")
    #copy tool data to user:// folders here
    #set first_launch to false
    #copy_all_tool_data()
    #load_enabled_tools()
    load_all_tools("res://tools")
    #can combine make_settings with make_all_tool_buttons, but separated for clarity
    make_settings_page()
    make_all_tool_buttons()
    hide_all_tools()
    Loading.hide()

    var DESKTOP = false
    if DESKTOP:
        var screen_res = OS.get_screen_size()
        var cam_height_ratio = (screen_res[1] * 3/4) / 2400
        OS.set_window_size(Vector2(1080 * cam_height_ratio, (screen_res[1] * 3/4)))

func open_settings():
    hide_all_tools()
    $MenuSettings.show()
    $MenuSettings.set("focus/ignore_mouse", false)

func close_settings():
    $MenuSettings.hide()
    $MenuSettings.set("focus/ignore_mouse", true)

func show_tool(t):
    close_settings()
    hide_all_tools()
    ALL_TOOLS[t].set("focus/ignore_mouse", false)
    ALL_TOOLS[t].show()

func hide_all_tools():
    for t in ALL_TOOLS.keys():
        ALL_TOOLS[t].hide()
        ALL_TOOLS[t].set("focus/ignore_mouse", true)

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
                    ALL_TOOLS[new_inst.DISPLAY_NAME] = new_inst
                    #print(file)
        file = dir.get_next()
    dir.list_dir_end()

func make_settings_page():
    var current_y = 0
    var ENTRY_HEIGHT = 94

    for t in ALL_TOOLS.keys():
        var new_entry = $MenuSettings/FuckyWuckyStopper/AllTools/ToolSettingBase.duplicate()
        $MenuSettings/FuckyWuckyStopper/AllTools.add_child(new_entry)
        new_entry.show()
        new_entry.get_node("Label").text = ALL_TOOLS[t].DISPLAY_NAME
        new_entry.rect_position.y = current_y
        var cb = new_entry.get_node("CheckBox")
        cb.connect("toggled", self, "_on_tool_enabled_toggle", [ALL_TOOLS[t].DISPLAY_NAME])
        current_y += ENTRY_HEIGHT

    var container_size = $MenuSettings/FuckyWuckyStopper/AllTools.rect_size.y
    var off_screen = current_y - container_size
    if off_screen <= 0:
        $MenuSettings/ScrollbarToolSettings.max_value = 0
        $MenuSettings/ScrollbarToolSettings.step = 0
    elif off_screen > 0:
        $MenuSettings/ScrollbarToolSettings.max_value = off_screen
        $MenuSettings/ScrollbarToolSettings.step = float(off_screen) / 100.0

func make_all_tool_buttons():
    for t in ALL_TOOLS.keys():
        #print(t)
        var new_button = $ButtonToolBase.duplicate()
        new_button.show()
        $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.add_child(new_button)
        new_button.text = ALL_TOOLS[t].DISPLAY_NAME
        new_button.name = ALL_TOOLS[t].DISPLAY_NAME + "_Button"
        new_button.add_to_group("tools")
        #new_button.connect("pressed", self, "_on_swap_tool_pressed")

    #this is black magic to skip a frame and get updated values and presumably works for collision shit?
    yield(get_tree(), "idle_frame")
    var diff = $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_size.x - $ControlToolbox/ControlToolButtonsContainer.rect_size.x
    #print($ControlToolbox.rect_size.x)
    if diff > 0:
        #print(diff)
        $ControlToolbox/ScrollbarTools.max_value = diff
        $ControlToolbox/ScrollbarTools.step = float(diff) / 100.0
    else:
        $ControlToolbox/ScrollbarTools.max_value = 0
        $ControlToolbox/ScrollbarTools.step = 0
    for butterino in $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.get_tree().get_nodes_in_group("tools"):
        #print(butterino)
        butterino.connect("pressed", self, "_on_swap_tool_pressed", [butterino])

func _on_ButtonConfigure_pressed():
    open_settings()

func _on_swap_tool_pressed(button):
    #print(button.name)
    var n = button.name.split("_")
    show_tool(n[0])

func _on_tool_enabled_toggle(button_pressed, test):
    print(button_pressed)
    print(test)

func _on_ScrollbarToolSettings_value_changed(value):
    $MenuSettings/FuckyWuckyStopper/AllTools.rect_position.y = -1 * value

func _on_ScrollbarTools_value_changed(value):
    $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_position.x = -1 * value
