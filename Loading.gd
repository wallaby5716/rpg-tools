extends Control


const BASE_STRING = "L O A D I N G"
var dot_counter = 0
var dot_string = " ."


func _on_Timer_timeout():
    var dots = ""
    for i in range(dot_counter):
        dots += dot_string
    dot_counter += 1
    if dot_counter > 3:
        dot_counter = 0
    $Label.text = BASE_STRING + dots
