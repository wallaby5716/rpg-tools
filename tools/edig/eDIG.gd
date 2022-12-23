extends Control

const DISPLAY_NAME = "eDIG"
const TOOL_TYPE = "generator"

var CONNECTORS = []
var FINISHERS = []
var button_text = [
    "I NEED ANOTHER",
    "I JUST GOT STARTED",
    "HE'S GOT A FRIEND",
    "I'M SURROUNDED"
   ]

func _ready():
    randomize()
    button_text.shuffle()
    $ButtonGenerate.text = button_text[0]
    var f = File.new()
    f.open("res://tools/edig/CONNECTORS.txt", File.READ)
    while not f.eof_reached(): # iterate through all lines until the end of file is reached
        var line = f.get_line().strip_edges()
        if line != "":
            CONNECTORS.append(line)
    f.close()
    f.open("res://tools/edig/FINISHERS.txt", File.READ)
    while not f.eof_reached(): # iterate through all lines until the end of file is reached
        var line = f.get_line().strip_edges()
        if line != "":
            FINISHERS.append(line)
    f.close()


func _on_ButtonGenerate_pressed():
    if int(round(randf())) == 1:
        button_text.shuffle()
        $ButtonGenerate.text = button_text[0]
    var odds = [1,1,2,2,2]
    var num_insults = randi() % 15 + 1
    print(num_insults)
    for i in range(6):
        odds.append(num_insults)
    odds.shuffle()
    var insult_string = "[b]"
    var copy_of_connectors = CONNECTORS.duplicate(true)
    copy_of_connectors.shuffle()
    for i in range(odds[0]):
        insult_string += "\n" + copy_of_connectors.pop_front().to_upper() + ","
    insult_string.erase(insult_string.length() - 1, 1)
    $LabelMiddle.bbcode_text = insult_string
    FINISHERS.shuffle()
    var ex_points = ""
    for i in range(randi() % 3 + 1):
        ex_points += "!"
    $LabelEnd.bbcode_text = "[b][right][color=#999999]" + FINISHERS[0].to_upper() + ex_points +"\""
    
