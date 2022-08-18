extends Control

const NAME = "DiceRoller"

var roll_number = 1
var roll_sides = 6
var roll_mod = 0
var roll_advantage = "n"
var CUSTOM_ENABLED = false
var roll_history = []

func _ready():
    $RectCustomDisable.show()
    $RectCustomEnabled.hide()
    $ButtonD10.flat = true
    $ButtonNormal.flat = true
    roll_sides = 10

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
    var new_val = $TextRollValue.text.to_int()
    if text != null:
        new_val = text.to_int()
    #print(new_val)
    if str(new_val).length() == 0 or new_val < 1:
        #print("here")
        new_val = 1
    roll_number = new_val

func leave_custom_mode():
    CUSTOM_ENABLED = false
    $ButtonCustom.flat = false
    $RectCustomDisable.show()
    $RectCustomEnabled.hide()

func _on_TextRollValue_focus_entered():
    leave_custom_mode()

func _on_TextRollValue_text_entered(new_text):
    validate_dice_number_to_roll(new_text)
    $TextRollValue.text = str(roll_number)
    OS.hide_virtual_keyboard()
    #$ButtonRollDice.grab_focus()
    leave_custom_mode()

func _on_TextRollValue_focus_exited():
    validate_dice_number_to_roll($TextRollValue.text)
    $TextRollValue.text = str(roll_number)
    OS.hide_virtual_keyboard()
    #$ButtonRollDice.grab_focus()
    leave_custom_mode()

func _on_ButtonPlusFive_pressed():
    roll_number += 5
    $TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonPlusOne_pressed():
    roll_number += 1
    $TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonMinusFive_pressed():
    roll_number -= 5
    if roll_number < 1:
        roll_number = 1
    $TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonMinusOne_pressed():
    roll_number -= 1
    if roll_number < 1:
        roll_number = 1
    $TextRollValue.text = str(roll_number)
    leave_custom_mode()

func _on_ButtonD4_pressed():
    roll_sides = 4
    leave_custom_mode()
    $ButtonD4.flat = true
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = false

func _on_ButtonD6_pressed():
    roll_sides = 6
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = true
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = false

func _on_ButtonD8_pressed():
    roll_sides = 8
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = true
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = false

func _on_ButtonD10_pressed():
    roll_sides = 10
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = true
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = false

func _on_ButtonD12_pressed():
    roll_sides = 12
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = true
    $ButtonD20.flat = false
    $ButtonD100.flat = false

func _on_ButtonD20_pressed():
    roll_sides = 20
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = true
    $ButtonD100.flat = false

func _on_ButtonD100_pressed():
    roll_sides = 100
    leave_custom_mode()
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = true

func _on_TextCustomRoll_focus_entered():
    CUSTOM_ENABLED = true
    $RectCustomDisable.hide()
    $RectCustomEnabled.show()
    $ButtonCustom.flat = true
    $ButtonD4.flat = false
    $ButtonD6.flat = false
    $ButtonD8.flat = false
    $ButtonD10.flat = false
    $ButtonD12.flat = false
    $ButtonD20.flat = false
    $ButtonD100.flat = false
    if $TextCustomRoll.text != "":
        $TextCustomRoll/ButtonClearCustom.show()

func _on_TextCustomRoll_focus_exited():
    if $TextCustomRoll.text != "":
        $TextCustomRoll/ButtonClearCustom.show()

func _on_ButtonClearCustom_pressed():
    $TextCustomRoll.text = ""
    $TextCustomRoll/ButtonClearCustom.hide()

func _on_TextCustomRoll_text_changed(new_text):
    if new_text != "":
        $TextCustomRoll/ButtonClearCustom.show()

func _on_ButtonCustom_pressed():
    if CUSTOM_ENABLED:
        CUSTOM_ENABLED = false
        $RectCustomDisable.show()
        $RectCustomEnabled.hide()
    else:
        CUSTOM_ENABLED = true
        $RectCustomDisable.hide()
        $RectCustomEnabled.show()
    if CUSTOM_ENABLED:
        $ButtonCustom.flat = true
        $ButtonD4.flat = false
        $ButtonD6.flat = false
        $ButtonD8.flat = false
        $ButtonD10.flat = false
        $ButtonD12.flat = false
        $ButtonD20.flat = false
        $ButtonD100.flat = false
    else:
        $ButtonCustom.flat = false

func _on_ButtonRollDice_pressed():
    $RollResultBanner/LabelResult.scroll_to_line(0)
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
        var result = GlobalScene.roll_dice(roll_number, roll_sides, roll_mod)
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

        $RollResultBanner/LabelResult.bbcode_text = "[center][b][color=#999999]" + roll_string + mod_string + ":\n[color=#ffffff]" + result_string + "\n" +  history_string
        var roll_info_array = get_odds(roll_number, roll_sides, roll_mod)
        $LabelRollInfoMin.bbcode_text = "[center][b]" + red + "Min\n" + str(roll_info_array[0])
        $LabelRollInfoAvg.bbcode_text = "[center][b]" + "Avg\n" +  str(roll_info_array[1])
        $LabelRollInfoMax.bbcode_text = "[center][b]" + green + "Max\n" + str(roll_info_array[2])
        latest_roll = roll_string + mod_string + ": " + str(ROLL_VALUE) + roll_adv_string
    else: #custom roll string
        var input_string = $TextCustomRoll.text
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
                    var roll = GlobalScene.roll_dice(int(die_info[0]), int(die_info[1]))
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
        $RollResultBanner/LabelResult.bbcode_text = "[center][b][color=#999999]" + roll_string.rstrip(" ") +  ":\n[color=#ffffff]" + result_string + "\n" +  history_string
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

        $LabelRollInfoMin.bbcode_text = "[center][b]" + red + "Min\n" + str(min_roll)
        $LabelRollInfoAvg.bbcode_text = "[center][b]" + "Avg\n" +  str(avg_roll)
        $LabelRollInfoMax.bbcode_text = "[center][b]" + green + "Max\n" + str(max_roll)
        latest_roll = roll_string.rstrip(" ") + ": " + str(ROLL_VALUE) + roll_adv_string
    roll_history.push_front(latest_roll)

func _on_ButtonAdvantage_pressed():
    roll_advantage = "a"
    $ButtonAdvantage.flat = true
    $ButtonNormal.flat = false
    $ButtonDisadvantage.flat = false

func _on_ButtonNormal_pressed():
    roll_advantage = "n"
    $ButtonAdvantage.flat = false
    $ButtonNormal.flat = true
    $ButtonDisadvantage.flat = false

func _on_ButtonDisadvantage_pressed():
    roll_advantage = "d"
    $ButtonAdvantage.flat = false
    $ButtonNormal.flat = false
    $ButtonDisadvantage.flat = true

