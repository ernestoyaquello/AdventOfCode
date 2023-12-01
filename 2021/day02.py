import input

PROBLEM_NUMBER = 2

def execute(is_part_two):
    return part_1() if not is_part_two else part_2()

def part_1():
    moves = {
        'forward': ('y', +1),
        'up':      ('z', -1),
        'down':    ('z', +1),
    }
    position = { 'x': 0, 'y': 0, 'z': 0 }
    for instruction in input.read_lists(problem_number = PROBLEM_NUMBER):
        move = moves[instruction[0]]
        position[move[0]] = position[move[0]] + (move[1] * int(instruction[1]))
    return position['y'] * position['z']

def part_2():
    aim = 0
    position = { 'x': 0, 'y': 0, 'z': 0 }
    for instruction in input.read_lists(problem_number = PROBLEM_NUMBER):
        if instruction[0] == 'up':
            aim -= int(instruction[1])
        elif instruction[0] == 'down':
            aim += int(instruction[1])
        elif instruction[0] == 'forward':
            position['y'] += int(instruction[1])
            position['z'] += int(instruction[1]) * aim
    return position['y'] * position['z']

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))