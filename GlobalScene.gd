extends Node2D

const TOOLS_DATA_PATH = "res://tools"

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

func wordlist_to_array(file):
    var word_array = []
    var f = File.new()
    f.open(file, File.READ)
    while not f.eof_reached(): # iterate through all lines until the end of file is reached
        var line = f.get_line()
        if line != "":
            word_array.append(line.strip_edges())
        #print(line + str(index))
    f.close()
    return word_array
