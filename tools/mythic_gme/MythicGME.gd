extends Control

const NAME = "MythicGME"

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

func mythic_get_oracle_result():
    var reply = ""
    var color = "[color=#00ff00]"
    var roll = GlobalScene.roll_dice(1,100)[0]
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
    $MythicResultBanner/LabelOracleResult.bbcode_text = "[center][b]" + color + reply

func _on_ButtonRollOracle_pressed():
    mythic_get_oracle_result()

func _on_SliderLikelihood_value_changed(value):
    mythic_odds = MYTHIC_GME_ODDS[value]
