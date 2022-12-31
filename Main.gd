extends ColorRect

const TOOLS_PATH = "res://tools"
const LOCAL_TOOLS_PATH = "user://tools"

var config_data = []
var tool_settings = {}
var ALL_TOOLS = []
var current_tool = 0

func _ready():
    randomize()
    Loading.show()

    load_config()
    load_all_tools(TOOLS_PATH)
   # hide_all_tools()
    show_tool(0)
    label_next_prev()
   # TabContainer
    Loading.hide()

#    var DESKTOP = false
#    if DESKTOP:
#        var screen_res = OS.get_screen_size()
#        var cam_height_ratio = (screen_res[1] * 3/4) / 2400
#        OS.set_window_size(Vector2(1080 * cam_height_ratio, (screen_res[1] * 3/4)))

func _process(delta):
    pass#print($TabContainer.get_children())

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        dump_config()
        get_tree().quit() # default behavior

func dump_config():
    var config_file = File.new()
    config_file.open("user://config.json", File.WRITE)

#TODO if config exists and we are a different version, merge settings with new version tools
func load_config():
    var directory = Directory.new();
    var exists = directory.file_exists("user://config.json")
    if exists:
        var config_file = File.new()
        config_file.open("user://config.json", File.READ)
        tool_settings = JSON.parse(config_file.get_as_text()).get_result()
        print(tool_settings)
        config_file.close()
    else: 
        var user_dir = Directory.new()
        user_dir.open("user://")
        user_dir.copy("res://config.json", "user://config.json")

func hide_all_tools():
    for t in ALL_TOOLS:
        t.hide()

func show_tool(index):
    hide_all_tools()
    ALL_TOOLS[index].show()

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
                    new_inst.name = new_inst.DISPLAY_NAME
                    #new_inst.instance()
                    add_child(new_inst)
                    ALL_TOOLS.append(new_inst)
#        $TabInfo/ButtonPrevTab/LabelTabPrevious.text = $TabContainer.get_tab_title(current_tab-1)
#        print($TabContainer.get_tab_title(current_tab-1))
#        $TabInfo/ButtonNextTab/LabelTabNext.text = $TabContainer.get_tab_title(current_tab + 1)
                    #print(file)
        file = dir.get_next()
    dir.list_dir_end()

func label_next_prev():
    var next_tool = current_tool + 1
    if next_tool > ALL_TOOLS.size() - 1:
        next_tool = 0
    $TabInfo/ButtonNextTab.text = ALL_TOOLS[next_tool].DISPLAY_NAME + " ->"
    next_tool = current_tool - 1
    if next_tool < 0:
        next_tool = ALL_TOOLS.size() - 1
    $TabInfo/ButtonPrevTab.text = "<- " + ALL_TOOLS[next_tool].DISPLAY_NAME

func _on_ButtonNextTab_pressed():
    current_tool += 1
    if current_tool > ALL_TOOLS.size() - 1:
        current_tool = 0
    show_tool(current_tool)
    label_next_prev()

func _on_ButtonPrevTab_pressed():
    current_tool -= 1
    if current_tool < 0:
        current_tool = ALL_TOOLS.size() -1
    show_tool(current_tool)
    label_next_prev()
