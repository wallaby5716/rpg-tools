extends Node2D

const CONFIG_FILE = "res://config.cfg"
const DEFAULT_CONFIG = "res://default_config.cfg"
const TOOLS_PATH = "res://tools"
const LOCAL_TOOLS_PATH = "user://tools"

var config_data = []
var enabled_tools = {}
var config_exists = false
#make a list of loaded tools in the settings screen, with checkboxes to enable/disable them.
#on quit save all enabled tools to our config.cfg
var ALL_TOOLS = {}
var all_tool_buttons = {}

func _ready():
    #ProjectSettings.set_setting("global/version", "0.1.9")
    randomize()
    Loading.show()

    load_config()
#    var old_version = false
#    var local_tools_dir = Directory.new();
#    var local_tools_dir_exists = local_tools_dir.dir_exists(LOCAL_TOOLS_PATH)
#    if config_data.size() > 0:
#        #print(config_data[0])
#        old_version = !(config_data[0].split("=")[1] == ProjectSettings.get_setting("global/version"))
#    if !config_exists:
#        print("Config missing. Creating new config.")
#        var dir = Directory.new()
#        dir.open("res://")
#        dir.copy("default_config.cfg", CONFIG_FILE)
#        load_config()
#    if old_version:
#        if !local_tools_dir_exists:
#            print("Running newer version, no local files found. All tools will be copied.")
#            copy_tools_to_user_system()
#        else:
#            print("Running newer version, local files found. Not overwriting files.")
#            #TODO just copy over new files, dont overwrite any local files/changes.
#    if !local_tools_dir_exists:
#        print("Local tools directory not found, copying tools...")
#        copy_tools_to_user_system()

    load_all_tools(TOOLS_PATH)
    #we load all? tools then only enable/show the ones that are enabled in the config.
    #then we load tools from the user's files.

    #can combine make_settings with make_all_tool_buttons, but separated for clarity
    make_settings_page()
    make_all_tool_buttons()
    update_tool_buttons()
    hide_all_tools()
    Loading.hide()

    var DESKTOP = false
    if DESKTOP:
        var screen_res = OS.get_screen_size()
        var cam_height_ratio = (screen_res[1] * 3/4) / 2400
        OS.set_window_size(Vector2(1080 * cam_height_ratio, (screen_res[1] * 3/4)))

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        dump_config()
        get_tree().quit() # default behavior

func dump_config():
    var config_file = File.new()
    config_file.open(CONFIG_FILE, File.WRITE)
    config_file.store_string("version=" + ProjectSettings.get_setting("global/version") + "\n")
    var tool_settings = $MenuSettings/FuckyWuckyStopper/AllTools.get_children()
    var badnames = ["ToolSettingBase", "HeadingToolSetting"]
    for t in tool_settings:
        if !(t.name in badnames):
            config_file.store_string(ALL_TOOLS[t.name].name + "=" + str(t.get_node("CheckBox").pressed).to_lower() + "\n")
    config_file.close()

func copy_tool(t):
    var bad_extensions = ["tscn", "gd"]
    var bad_dirs = ["", ".", ".."]
    var dir = Directory.new()
    dir.open(TOOLS_PATH + "/" + t)
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if !(file in bad_dirs) and !(file.get_extension() in bad_extensions):
            dir.copy(TOOLS_PATH + "/" + t + "/" + file, LOCAL_TOOLS_PATH + "/" + t + "/" + file)
            #print(str(dir.copy(TOOLS_PATH + "/" + t + "/" + file, LOCAL_TOOLS_PATH + "/" + t + "/" + file)) + " | " + file + " | " + LOCAL_TOOLS_PATH + "/" + t + "/" + file)
        file = dir.get_next()
    dir.list_dir_end()

func copy_tools_to_user_system():
    var bad_dirs = ["", ".", ".."]
    var dir = Directory.new()
    var local_dir = Directory.new()
    local_dir.open(LOCAL_TOOLS_PATH)
    dir.open(TOOLS_PATH)
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if dir.current_is_dir():
            if !(file in bad_dirs):
                #print(file)
                local_dir.make_dir_recursive(LOCAL_TOOLS_PATH + "/" + file)
                copy_tool(file)
        file = dir.get_next()
    dir.list_dir_end()

func load_config():
    var directory = Directory.new();
    var exists = directory.file_exists(CONFIG_FILE)
    if !exists:
        return false
    var config_file = File.new()
    config_file.open(CONFIG_FILE, File.READ)
    var index = 1
    while not config_file.eof_reached(): # iterate through all lines until the end of file is reached
        var line = config_file.get_line().strip_edges()
        if line != "":
            config_data.append(line)
        index += 1
    config_file.close()
    #print(config_data.size(), "AAAAA")
    for i in range(config_data.size()):
        if i == 0:
            pass
        else:
            pass
            #print(config_data[i])
            var data = config_data[i].split("=")
            enabled_tools[data[0]] = data[1]
    return true

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
    #print(d)
    var bad_dirs = ["", ".", ".."]
    #print(d)
    var dir = Directory.new()
    dir.open(d)
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        #print(file)
        if dir.current_is_dir():
            if not file in bad_dirs:
                #print(file)
                load_all_tools(TOOLS_PATH + "/" + file)
        else:
            if not file in bad_dirs:
                #print(d, file)
                if file.get_extension() == "tscn":
                    #print(TOOLS_PATH + "/" + d + file)
                    var new_inst = load(d + "/" +  file).instance()
                    #new_inst.instance()
                    add_child(new_inst)
                    ALL_TOOLS[new_inst.name] = new_inst
                    #print(file)
        file = dir.get_next()
    dir.list_dir_end()

func make_settings_page():
    #print(enabled_tools)
    var current_y = 0
    var ENTRY_HEIGHT = 94

    for t in ALL_TOOLS.keys():
        var new_entry = $MenuSettings/FuckyWuckyStopper/AllTools/ToolSettingBase.duplicate()
        $MenuSettings/FuckyWuckyStopper/AllTools.add_child(new_entry)
        new_entry.show()
        new_entry.get_node("Label").text = ALL_TOOLS[t].DISPLAY_NAME
        new_entry.name = ALL_TOOLS[t].name
        new_entry.rect_position.y = current_y
        var cb = new_entry.get_node("CheckBox")
        if enabled_tools[t] == "true":
            cb.pressed = true
        else:
            cb.pressed = false
        cb.connect("toggled", self, "_on_tool_enabled_toggle", [ALL_TOOLS[t].name])
        current_y += ENTRY_HEIGHT

    var container_size = $MenuSettings/FuckyWuckyStopper/AllTools.rect_size.y
    var off_screen = current_y - container_size
    if off_screen <= 0:
        $MenuSettings/ScrollbarToolSettings.max_value = 0
        $MenuSettings/ScrollbarToolSettings.step = 0
    elif off_screen > 0:
        $MenuSettings/ScrollbarToolSettings.max_value = off_screen
        $MenuSettings/ScrollbarToolSettings.step = float(off_screen) / 100.0

func update_tool_buttons():
    $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_size = Vector2.ZERO
    #print($AllToolButtons.get_children())
    for t in ALL_TOOLS.keys():
        #print(t, " ", enabled_tools[t])
        if enabled_tools[t] == "true":
            var butt = $AllToolButtons.get_node(t + "_Button")
            #print(butt)
            $AllToolButtons.remove_child(butt)
            $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.add_child(butt)
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

func make_all_tool_buttons():
    for t in ALL_TOOLS.keys():
        #print(t)
        var new_button = $ButtonToolBase.duplicate()
        new_button.show()
        $AllToolButtons.add_child(new_button)
        new_button.text = ALL_TOOLS[t].DISPLAY_NAME
        new_button.name = ALL_TOOLS[t].name + "_Button"
        new_button.add_to_group("tools")
        #new_button.connect("pressed", self, "_on_swap_tool_pressed")

    #this is black magic to skip a frame and get updated values and presumably works for collision shit?
    for butterino in $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.get_tree().get_nodes_in_group("tools"):
        #print(butterino)
        butterino.connect("pressed", self, "_on_swap_tool_pressed", [butterino])

func _on_ButtonConfigure_pressed():
    open_settings()

func _on_swap_tool_pressed(button):
    #print(button.name)
    var n = button.name.split("_")
    show_tool(n[0])

func _on_tool_enabled_toggle(button_pressed, tool_name):
    if !button_pressed:
        enabled_tools[tool_name] = str(button_pressed).to_lower()
        var b = $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.get_node(tool_name + "_Button")
        $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.remove_child(b)
        $AllToolButtons.add_child(b)

    else:
        print("enabled something")
        enabled_tools[tool_name] = str(button_pressed).to_lower()
    update_tool_buttons()

func _on_ScrollbarToolSettings_value_changed(value):
    $MenuSettings/FuckyWuckyStopper/AllTools.rect_position.y = -1 * value

func _on_ScrollbarTools_value_changed(value):
    $ControlToolbox/ControlToolButtonsContainer/ButtonDrawer.rect_position.x = -1 * value
