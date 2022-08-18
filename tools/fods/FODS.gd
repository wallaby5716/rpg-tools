extends Control

const NAME = "FODS"

var ACTIONS = []
var DESCRIPTIONS = []
var SUBJECTS = []


# Called when the node enters the scene tree for the first time.
func _ready():
    load_words()
    _on_ButtonRoll_pressed()


func load_words():
    ACTIONS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/fods/" + "action.txt")
    DESCRIPTIONS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/fods/" + "descriptor.txt")
    SUBJECTS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/fods/" + "subject.txt")

func _on_ButtonRoll_pressed():
    var rolls = [GlobalScene.roll_dice(1, ACTIONS.size()),
        GlobalScene.roll_dice(1, DESCRIPTIONS.size()),
        GlobalScene.roll_dice(1, SUBJECTS.size())]
    $LabelActionResult.text = ACTIONS[rolls[0][0] - 1].capitalize()
    $LabelDescriptorResult.text = DESCRIPTIONS[rolls[1][0] - 1].capitalize()
    $LabelSubjectResult.text = SUBJECTS[rolls[2][0] - 1].capitalize()
