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
#enum ADVANTAGE_OPTIONS {ADVANTAGE, NORMAL, DISADVANTAGE}
var roll_number = 1
var roll_sides = 6
var roll_mod = 0
var roll_advantage = "n"
var CUSTOM_ENABLED = false
var roll_history = []

func _ready():
    randomize()
    load_UNE_words()
    generate_npc(roll_dice(1,100), roll_dice(1,100))
    $ButtonToggleDiceRoller.flat = true
    $DiceRoller/ButtonD6.flat = true
    $DiceRoller/ButtonNormal.flat = true
    $DiceRoller/RectCustomDisable.show()
    $DiceRoller/RectCustomEnabled.hide()
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
    var c = get_children()
    for child in c:
        if child.get_class() == "Control":
            child.set("focus/ignore_mouse", true)
            child.hide()

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

func get_subtotal(subtotal_array):
    #print(subtotal_array)
    var total = 0
    var total2 = 0
    match roll_advantage:
        "n":
            for r in subtotal_array:
                total += r[0]
        "d":
            for r in subtotal_array:
                r.sort()
                total += r[0]
                total2 += r[1]
        "a":
            for r in subtotal_array:
                r.sort()
                total += r[1]
                total2 += r[0]
    return [total, total2]

func get_odds(number, sides, mod):
    var result_range = [number + mod, (number * sides) + mod]
    var avg
    var ADV_ADJUST = false
    var unique_outcomes = (number * sides) - (number - 1)
    if roll_advantage != "n":
        ADV_ADJUST = true
    match sides % 2:
        1:
            if ADV_ADJUST:
                match roll_advantage:
                    "d":
                        avg = stepify(float(sides) * (1.0/3.0) + 0.5, 0.1) * number

                    "a":
                        avg = stepify(float(sides) * (2.0/3.0) + 0.5, 0.1) * number
            else:
                avg = ((sides + 1) / 2) * number
        0:
            if ADV_ADJUST:
                match roll_advantage:
                    "d":
                        avg = stepify(float(sides) * (1.0/3.0) + 0.5, 0.1) * number

                    "a":
                        avg = stepify(float(sides) * (2.0/3.0) + 0.5, 0.1) * number
            else:
                avg = (sides / 2 + 0.5) * number
    return [result_range[0] + mod, avg + mod, result_range[1] + mod]

func validate_dice_number_to_roll(text=null):
    var new_val = $DiceRoller/TextRollValue.text.to_int()
    if text != null:
        new_val = text.to_int()
    #print(new_val)
    if str(new_val).length() == 0 or new_val < 1:
        #print("here")
        new_val = 1
    roll_number = new_val

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
    $MythicGME/LabelOracleResult.bbcode_text = "[center][b]" + color + reply

func _on_ButtonRollOracle_pressed():
    mythic_get_oracle_result()

func _on_SliderLikelihood_value_changed(value):
    mythic_odds = MYTHIC_GME_ODDS[value]

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

#===================================================================================================
#===================================================================================================
##=======================================U    N    E================================================
#===================================================================================================
#===================================================================================================

func _on_ButtonGenerate_pressed():
    var npc_roll = roll_dice(1,100)
    var motiv_roll = roll_dice(1,100)
    generate_npc(npc_roll, motiv_roll)

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

#===================================================================================================
#===================================================================================================
##=======================================DICE ROLLER================================================
#==========================================BUTTONS==================================================
#===================================================================================================
func leave_custom_mode():
    CUSTOM_ENABLED = false
    $DiceRoller/ButtonCustom.flat = false
    $DiceRoller/RectCustomDisable.show()
    $DiceRoller/RectCustomEnabled.hide()

func _on_TextRollValue_focus_entered():
    leave_custom_mode()

func _on_TextRollValue_text_entered(new_text):
    validate_dice_number_to_roll(new_text)
    $DiceRoller/TextRollValue.text = str(roll_number)
    OS.hide_virtual_keyboard()
    #$DiceRoller/ButtonRollDice.grab_focus()
    leave_custom_mode()

func _on_TextRollValue_focus_exited():
    validate_dice_number_to_roll($DiceRoller/TextRollValue.text)
    $DiceRoller/TextRollValue.text = str(roll_number)
    OS.hide_virtual_keyboard()
    #$DiceRoller/ButtonRollDice.grab_focus()
    leave_custom_mode()

func _on_ButtonPlusFive_pressed():
    roll_number += 5
    $DiceRoller/TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonPlusOne_pressed():
    roll_number += 1
    $DiceRoller/TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonMinusFive_pressed():
    roll_number -= 5
    if roll_number < 1:
        roll_number = 1
    $DiceRoller/TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonMinusOne_pressed():
    roll_number -= 1
    if roll_number < 1:
        roll_number = 1
    $DiceRoller/TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonD4_pressed():
    roll_sides = 4
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = true
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD6_pressed():
    roll_sides = 6
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = true
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD8_pressed():
    roll_sides = 8
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = true
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD10_pressed():
    roll_sides = 10
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = true
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD12_pressed():
    roll_sides = 12
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = true
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD20_pressed():
    roll_sides = 20
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = true
    $DiceRoller/ButtonD100.flat = false

func _on_ButtonD100_pressed():
    roll_sides = 100
    leave_custom_mode()
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = true

func _on_TextCustomRoll_focus_entered():
    CUSTOM_ENABLED = true
    $DiceRoller/RectCustomDisable.hide()
    $DiceRoller/RectCustomEnabled.show()
    $DiceRoller/ButtonCustom.flat = true
    $DiceRoller/ButtonD4.flat = false
    $DiceRoller/ButtonD6.flat = false
    $DiceRoller/ButtonD8.flat = false
    $DiceRoller/ButtonD10.flat = false
    $DiceRoller/ButtonD12.flat = false
    $DiceRoller/ButtonD20.flat = false
    $DiceRoller/ButtonD100.flat = false
    if $DiceRoller/TextCustomRoll.text != "":
        $DiceRoller/TextCustomRoll/ButtonClearCustom.show()

func _on_TextCustomRoll_focus_exited():
    if $DiceRoller/TextCustomRoll.text != "":
        $DiceRoller/TextCustomRoll/ButtonClearCustom.show()

func _on_ButtonClearCustom_pressed():
    $DiceRoller/TextCustomRoll.text = ""
    $DiceRoller/TextCustomRoll/ButtonClearCustom.hide()

func _on_TextCustomRoll_text_changed(new_text):
    if new_text != "":
        $DiceRoller/TextCustomRoll/ButtonClearCustom.show()

func _on_ButtonCustom_pressed():
    if CUSTOM_ENABLED:
        CUSTOM_ENABLED = false
        $DiceRoller/RectCustomDisable.show()
        $DiceRoller/RectCustomEnabled.hide()
    else:
        CUSTOM_ENABLED = true
        $DiceRoller/RectCustomDisable.hide()
        $DiceRoller/RectCustomEnabled.show()
    if CUSTOM_ENABLED:
        $DiceRoller/ButtonCustom.flat = true
        $DiceRoller/ButtonD4.flat = false
        $DiceRoller/ButtonD6.flat = false
        $DiceRoller/ButtonD8.flat = false
        $DiceRoller/ButtonD10.flat = false
        $DiceRoller/ButtonD12.flat = false
        $DiceRoller/ButtonD20.flat = false
        $DiceRoller/ButtonD100.flat = false
    else:
        $DiceRoller/ButtonCustom.flat = false

func _on_ButtonRollDice_pressed():
    $DiceRoller/RollResultBanner/LabelResult.scroll_to_line(0)
    var roll_adv_string
    match roll_advantage:
        "n":
            roll_adv_string = ""
        "a":
            roll_adv_string = "(" + roll_advantage.capitalize() + ")"
        "d":
            roll_adv_string = "(" + roll_advantage.capitalize() + ")"
    var history_string = ""
    var history_color_fade = ["[color=#666666]","[color=#606060]","[color=#555555]"]
    if roll_history.size() > 50:
        roll_history.pop_back()
    for i in range(roll_history.size()):
        if i < 3:
            history_string += history_color_fade[i] + roll_history[i]
        else:
            history_string += history_color_fade[2] + roll_history[i]
        if i != roll_history.size()-1:
            history_string += "\n"

    var latest_roll
    #print("ROLLING")
    var green = "[color=#00ff00]"
    var red = "[color=#ff0000]"
    if !CUSTOM_ENABLED:
        #print(get_odds(roll_number, roll_sides, roll_mod))
        var result = roll_dice(roll_number, roll_sides, roll_mod)
        var roll_string = str(roll_number) + "d" + str(roll_sides)
        var mod_string = ""
        if roll_mod != 0:
            if roll_mod > 0:
                mod_string = " + " + str(roll_mod)
            else:
                mod_string = " - " + str(int(abs(roll_mod)))
        var result_string
        var ROLL_VALUE
        if roll_advantage != "n":
            result.sort()
            if roll_advantage == "a":
                ROLL_VALUE = result[1]
                result_string = green + str(result[1]) + "[color=#ffffff] (" + str(result[0]) + ")"
            elif roll_advantage == "d":
                ROLL_VALUE = result[0]
                result_string = red + str(result[0]) + "[color=#ffffff] (" + str(result[1]) + ")"
        else:
            ROLL_VALUE = result[0]
            result_string = str(result[0])

        $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b][color=#999999]" + roll_string + mod_string + ":\n[color=#ffffff]" + result_string + "\n" +  history_string
        var roll_info_array = get_odds(roll_number, roll_sides, roll_mod)
        $DiceRoller/RollInfoBanner/LabelRollInfoMin.bbcode_text = "[center][b]" + red + "Min\n" + str(roll_info_array[0])
        $DiceRoller/RollInfoBanner/LabelRollInfoAvg.bbcode_text = "[center][b]" + "Avg\n" +  str(roll_info_array[1])
        $DiceRoller/RollInfoBanner/LabelRollInfoMax.bbcode_text = "[center][b]" + green + "Max\n" + str(roll_info_array[2])
        latest_roll = roll_string + mod_string + ": " + str(ROLL_VALUE) + roll_adv_string
    else: #custom roll string
        var input_string = $DiceRoller/TextCustomRoll.text
        var OPERATORS = "+-"

        input_string = input_string.replace("+", " + ").replace("-", " - ")

        var substrs = input_string.split(" ")
        var roll_odds = []
        var probabilities = []
        var subtotal = []
        var custom_total = 0
        var roll_string = ""
        var mods = 0

        var pos_neg = 1
        #print("AAAA: ",substrs)

        for subs in substrs:
            if subs.strip_edges() == "":
                continue
            if "+" in subs:
                pos_neg = 1
            elif "-" in subs:
                pos_neg = -1
            elif "d" in subs:
                var die_info = subs.split("d")
                if die_info.size() > 1:
                    probabilities.append([pos_neg, get_odds(int(die_info[0]), int(die_info[1]), 0)])
                    var roll = roll_dice(int(die_info[0]), int(die_info[1]))
                    roll[0] *= pos_neg
                    roll[1] *= pos_neg
                    subtotal.append(roll)
            else:
                mods += pos_neg * int(subs)
            roll_string += subs.strip_edges()
            roll_string += " "

        #print(probabilities, "\n", subtotal, "\n", mods)
        custom_total = get_subtotal(subtotal)
        var result_string = ""
        var ROLL_VALUE
        match roll_advantage:
            "a":
                ROLL_VALUE = custom_total[0] + mods
                result_string += green + str(custom_total[0] + mods) + "[color=#ffffff] (" + str(custom_total[1] + mods) + ")"
            "n":
                ROLL_VALUE = custom_total[0] + mods
                result_string = str(custom_total[0] + mods)
            "d":
                ROLL_VALUE = custom_total[0] + mods
                result_string += red + str(custom_total[0] + mods) + "[color=#ffffff] (" + str(custom_total[1] + mods) + ")"
        #print("subtotal: ", subtotal, "\nSubtotal Added: ", custom_total)
        $DiceRoller/RollResultBanner/LabelResult.bbcode_text = "[center][b][color=#999999]" + roll_string.rstrip(" ") +  ":\n[color=#ffffff]" + result_string + "\n" +  history_string
        var min_roll = mods
        var avg_roll = mods
        var max_roll = mods

        for die in probabilities:
            #print(die)
            if die[0] > 0:
                min_roll += die[0] * die[1][0]
                avg_roll += die[0] * die[1][1]
                max_roll += die[0] * die[1][2]
            if die[0] < 0:
                min_roll += die[0] * die[1][2]
                avg_roll += die[0] * die[1][1]
                max_roll += die[0] * die[1][0]

        $DiceRoller/RollInfoBanner/LabelRollInfoMin.bbcode_text = "[center][b]" + red + "Min\n" + str(min_roll)
        $DiceRoller/RollInfoBanner/LabelRollInfoAvg.bbcode_text = "[center][b]" + "Avg\n" +  str(avg_roll)
        $DiceRoller/RollInfoBanner/LabelRollInfoMax.bbcode_text = "[center][b]" + green + "Max\n" + str(max_roll)
        latest_roll = roll_string.rstrip(" ") + ": " + str(ROLL_VALUE) + roll_adv_string
    roll_history.push_front(latest_roll)

func _on_ButtonAdvantage_pressed():
    roll_advantage = "a"
    $DiceRoller/ButtonAdvantage.flat = true
    $DiceRoller/ButtonNormal.flat = false
    $DiceRoller/ButtonDisadvantage.flat = false

func _on_ButtonNormal_pressed():
    roll_advantage = "n"
    $DiceRoller/ButtonAdvantage.flat = false
    $DiceRoller/ButtonNormal.flat = true
    $DiceRoller/ButtonDisadvantage.flat = false

func _on_ButtonDisadvantage_pressed():
    roll_advantage = "d"
    $DiceRoller/ButtonAdvantage.flat = false
    $DiceRoller/ButtonNormal.flat = false
    $DiceRoller/ButtonDisadvantage.flat = true
