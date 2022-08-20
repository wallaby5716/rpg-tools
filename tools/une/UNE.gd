extends Control

const DISPLAY_NAME = "UNE"
const TOOL_TYPE = "generator"

var UNE_NPC_MODIFIERS
var UNE_NPC_NOUNS
var UNE_NPC_MOTIVATION_VERBS
var UNE_NPC_MOTIVATION_NOUNS

# Called when the node enters the scene tree for the first time.
func _ready():
    load_UNE_words()
    _on_ButtonGenerate_pressed()


func _on_ButtonGenerate_pressed():
    var npc_roll = GlobalScene.roll_dice(1,100)
    var motiv_roll = GlobalScene.roll_dice(1,100)
    generate_npc(npc_roll, motiv_roll)

func load_UNE_words():
    UNE_NPC_MODIFIERS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/une/" + "NPC_MODIFIERS.txt")
    UNE_NPC_NOUNS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/une/" + "NPC_NOUNS.txt")
    UNE_NPC_MOTIVATION_VERBS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/une/" + "NPC_MOTIV_VERBS.txt")
    UNE_NPC_MOTIVATION_NOUNS = GlobalScene.wordlist_to_array(GlobalScene.TOOLS_DATA_PATH + "/une/" + "NPC_MOTIV_NOUNS.txt")

func generate_npc(npc_roll, motiv_roll):
    var npc_mod = UNE_NPC_MODIFIERS[npc_roll[0]-1]
    var npc_noun = UNE_NPC_NOUNS[npc_roll[1]-1]
    var motivation_verb = UNE_NPC_MOTIVATION_VERBS[motiv_roll[0]-1]
    var motivation_noun = UNE_NPC_MOTIVATION_NOUNS[motiv_roll[1]-1]
    var green = "[color=#00ff00]"
    $ColorRect/LabelGeneratedCharacter.bbcode_text = "[center][b]" + "Character is a(n):\n" + green + npc_mod.capitalize() + " " + npc_noun.capitalize() +"\n[color=#ffffff]Whose goal is to:\n" + green + motivation_verb.capitalize() + " " + motivation_noun.capitalize()
