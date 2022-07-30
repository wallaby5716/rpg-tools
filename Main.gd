extends Node2D

#UNE VARS
var UNE_NPC_MODIFIERS
var UNE_NPC_NOUNS
var UNE_NPC_MOTIVATION_VERBS
var UNE_NPC_MOTIVATION_NOUNS

#MYTHIC GME VARS
const MYTHIC_GME_ODDS = [
    [3,15,74],
    [5,25,80],
    [7,35,86],
    [10,50,90],
    [13,65,94],
    [15,75,96],
    [16,85,97]
   ]
const MYTHIC_ORACLE_REPLIES = [
    "Strong Yes!",
    "Yes!",
    "No!",
    "Strong No!"
   ]
var mythic_odds = MYTHIC_GME_ODDS[3]

#DICE ROLLER VARS
enum ADVANTAGE_OPTIONS {ADVANTAGE, NORMAL, DISADVANTAGE}
var roll_number = 1
var roll_sides = 6
var roll_mod = 0
var roll_advantage = "n"
var CUSTOM_ENABLED = false

const TOOLS = ["diceroller", "mythicgme", "une"]

#TODO makde dict of different tools and make swapping between them less copy-pastey

func _ready():
    randomize()
    load_UNE_words()
    generate_npc(roll_dice(1,100), roll_dice(1,100))
    $ButtonToggleDiceRoller.flat = true
    show_tool("diceroller")

func show_tool(tool_name):
    hide_all_tools()
    match tool_name:
        "diceroller":
            $DiceRoller.set("focus/ignore_mouse", false)
            $DiceRoller.show()
        "mythicgme":
            $MythicGME.set("focus/ignore_mouse", false)
            $MythicGME.show()
        "une":
            $UNE.set("focus/ignore_mouse", false)
            $UNE.show()

func hide_all_tools():
    $DiceRoller.set("focus/ignore_mouse", true)
    $DiceRoller.hide()
    $MythicGME.set("focus/ignore_mouse", true)
    $MythicGME.hide()
    $UNE.set("focus/ignore_mouse", true)
    $UNE.hide()

func roll_dice(number, sides, mod=0):
    var first
    var second
    var total = 0
    for die in range(number):
        total += randi() % sides + 1
    first = total + mod
    total = 0
    for die in range(number):
        total += randi() % sides + 1
    second = total + mod
    return [first, second]

func mythic_get_oracle_result():
    var reply = ""
    var color = "[color=#00ff00]"
    var roll = roll_dice(1,100)[0]
    if roll <= mythic_odds[0]:
        reply = MYTHIC_ORACLE_REPLIES[0]
    elif roll <= mythic_odds[1]:
        reply = MYTHIC_ORACLE_REPLIES[1]
    elif roll <= mythic_odds[2]:
        color = "[color=#ff0000]"
        reply = MYTHIC_ORACLE_REPLIES[2]
    else:
        color = "[color=#ff0000]"
        reply = MYTHIC_ORACLE_REPLIES[3]
    $MythicGME/LabelOracleResult.bbcode_text = "[center][b]Rolled " + str(roll) + ":\n" + color + reply

func wordlist_to_array(file):
    var word_array = []
    var f = File.new()
    f.open(file, File.READ)
    while not f.eof_reached(): # iterate through all lines until the end of file is reached
        var line = f.get_line()
        word_array.append(line.strip_edges())
        #print(line + str(index))
    f.close()
    return word_array

func load_UNE_words():
    UNE_NPC_MODIFIERS = wordlist_to_array("res://NPC_MODIFIERS.txt")
    UNE_NPC_NOUNS = wordlist_to_array("res://NPC_NOUNS.txt")
    UNE_NPC_MOTIVATION_VERBS = wordlist_to_array("res://NPC_MOTIV_VERBS.txt")
    UNE_NPC_MOTIVATION_NOUNS = wordlist_to_array("res://NPC_MOTIV_NOUNS.txt")

func generate_npc(npc_roll, motiv_roll):
    var npc_mod = UNE_NPC_MODIFIERS[npc_roll[0]-1]
    var npc_noun = UNE_NPC_NOUNS[npc_roll[1]-1]
    var motivation_verb = UNE_NPC_MOTIVATION_VERBS[motiv_roll[0]-1]
    var motivation_noun = UNE_NPC_MOTIVATION_NOUNS[motiv_roll[1]-1]
    var green = "[color=#00ff00]"
    $UNE/ColorRect/LabelGeneratedCharacter.bbcode_text = "[center][b]" + "Character is a(n):\n" + green + npc_mod.capitalize() + " " + npc_noun.capitalize() +"\n[color=#ffffff]Whose goal is to:\n" + green + motivation_verb.capitalize() + " " + motivation_noun.capitalize()

func validate_dice_number_to_roll(text=null):
    var new_val = $DiceRoller/TextRollValue.text.to_int()
    if text != null:
        new_val = text.to_int()
    print(new_val)
    if str(new_val).length() == 0 or new_val < 1:
        print("here")
        new_val = 1
    roll_number = new_val

func _on_TextRollValue_text_entered(new_text):
    validate_dice_number_to_roll(new_text)
    $DiceRoller/TextRollValue.text = str(roll_number)
    OS.hide_virtual_keyboard()
    $DiceRoller/ButtonRollDice.grab_focus()

func _on_ButtonPlusFive_pressed():
    roll_number += 5
    $DiceRoller/TextRollValue.text = str(roll_number)

func _on_ButtonPlusOne_pressed():
    roll_number += 1
    $DiceRoller/TextRollValue.text = str(roll_number)

func _on_ButtonMinusFive_pressed():
    roll_number -= 5
    if roll_number < 1:
        roll_number = 1
    $DiceRoller/TextRollValue.text = str(roll_number)

func _on_ButtonMinusOne_pressed():
    roll_number -= 1
    if roll_number < 1:
        roll_number = 1
    $DiceRoller/TextRollValue.text = str(roll_number)

func _on_ButtonD4_pressed():
    roll_sides = 4
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = true
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD6_pressed():
    roll_sides = 6
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = true
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD8_pressed():
    roll_sides = 8
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = true
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD10_pressed():
    roll_sides = 10
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = true
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD12_pressed():
    roll_sides = 12
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = true
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD20_pressed():
    roll_sides = 20
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = true
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD100_pressed():
    roll_sides = 100
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = true

func _on_ButtonCustom_pressed():
    CUSTOM_ENABLED = true
    $DiceRoller/ButtonCustom.flat = true
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonRollDice_pressed():
    print("ROLLING")
    var green = "[color=#00ff00]"
    var red = "[color=#ff0000]"
    if !CUSTOM_ENABLED:
        var result = roll_dice(roll_number, roll_sides, roll_mod)
        var roll_string = str(roll_number) + "d" + str(roll_sides)
        var mod_string = ""
        if roll_mod != 0:
            if roll_mod > 0:
                mod_string = " + " + str(roll_mod)
            else:
                mod_string = " - " + str(int(abs(roll_mod)))
        var result_string
        if roll_advantage != "n":
            result.sort()
            if roll_advantage == "a":
                result_string = green + str(result[1]) + "[color=#ffffff] (" + str(result[0]) + ")"
            elif roll_advantage == "d":
                result_string = red + str(result[0]) + "[color=#ffffff] (" + str(result[1]) + ")"
        else:
            result_string = str(result[0])

        $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b]" + roll_string + mod_string + ":\n" + result_string
    else: #custom roll string
        var custom_number = 1
        var custom_sides = 2
        var custom_mod = 0
        var dice_string
        var input_string = $DiceRoller/TextCustomRoll.text
        var plus_found = input_string.count("+")
        var minus_found = input_string.count("-")
        if plus_found > 0 and minus_found > 0:
            $DiceRoller/TextCustomRoll.text = "Bad String"
            $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b]Bad Custom String."
            return
        elif plus_found == 1:
            input_string = input_string.split("+")
            custom_mod = input_string[1].to_int()
            dice_string = input_string[0].split("d")
        elif minus_found == 1:
            input_string = input_string.split("-")
            custom_mod = input_string[1].to_int() * -1
            dice_string = input_string[0].split("d")
        elif plus_found == 0 and minus_found == 0:
            dice_string = input_string.split("d")
        else:
            $DiceRoller/TextCustomRoll.text = "Bad String"
            $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b]Bad Custom String."
            return

        custom_number = dice_string[0].to_int()
        custom_sides = dice_string[1].to_int()
        var result = roll_dice(custom_number, custom_sides, custom_mod)
        var roll_string = str(custom_number) + "d" + str(custom_sides)
        var mod_string = ""
        if custom_mod != 0:
            if custom_mod > 0:
                mod_string = " + " + str(custom_mod)
            else:
                mod_string = " - " + str(int(abs(custom_mod)))
        var result_string
        if roll_advantage != "n":
            result.sort()
            if roll_advantage == "a":
                result_string = green + str(result[1]) + "[color=#ffffff] (" + str(result[0]) + ")"
            elif roll_advantage == "d":
                result_string = red + str(result[0]) + "[color=#ffffff] (" + str(result[1]) + ")"
        else:
            result_string = str(result[0])

        $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b]" + roll_string + mod_string + ":\n" + result_string

func _on_ButtonRollOracle_pressed():
    mythic_get_oracle_result()

func _on_ButtonGenerate_pressed():
    var npc_roll = roll_dice(1,100)
    var motiv_roll = roll_dice(1,100)
    generate_npc(npc_roll, motiv_roll)

func _on_OptionAdvantage_pressed():
    if roll_advantage == "a":
        roll_advantage = "n"
        $DiceRoller/OptionAdvantage.text = "Adv [Norm] Dis"
    elif roll_advantage == "n":
        roll_advantage = "d"
        $DiceRoller/OptionAdvantage.text = "Adv Norm [Dis]"
    elif roll_advantage == "d":
        roll_advantage = "a"
        $DiceRoller/OptionAdvantage.text = "[Adv] Norm Dis"
    else:
        roll_advantage = "n"
        $DiceRoller/OptionAdvantage.text = "Adv [Norm] Dis"

func _on_SliderLikelihood_value_changed(value):
    mythic_odds = MYTHIC_GME_ODDS[value]
    #print(mythic_odds)

func _on_ButtonToggleDiceRoller_pressed():
    $ButtonToggleDiceRoller.flat = true
    $ButtonToggleMythicOracle.flat = false
    $ButtonToggleUNE.flat = false
    show_tool("diceroller")

func _on_ButtonToggleMythicOracle_pressed():
    $ButtonToggleMythicOracle.flat = true
    $ButtonToggleDiceRoller.flat = false
    $ButtonToggleUNE.flat = false
    show_tool("mythicgme")

func _on_ButtonToggleUNE_pressed():
    $ButtonToggleUNE.flat = true
    $ButtonToggleMythicOracle.flat = false
    $ButtonToggleDiceRoller.flat = false
    show_tool("une")
