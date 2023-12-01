import input
from collections import defaultdict

PROBLEM_NUMBER = 22

def execute(is_part_two):
    instructions = read_instructions(exclude_big = not is_part_two)
    return count_cubes_on(instructions)

def count_cubes_on(instructions):
    total_cubes_on = 0

    extra_instructions = defaultdict(list)
    for index, (cuboid, is_on) in enumerate(instructions):
        total_cubes_on += calculate_cubes_in_cuboid(cuboid) if is_on else 0

        # Determine the overlaps with previous cuboids (and with their overlaps) and create extra instructions with
        # the inverted value of the originals (on -> off; off -> on) to compensate for the additional cubes counted.
        all_previous_instructions = [([previous_instruction] if previous_instruction[1] else []) + extra_instructions[previous_index] for previous_index, previous_instruction in enumerate(instructions[:index])]
        for previous_instructions in all_previous_instructions:
            for previous_cuboid, previous_is_on in previous_instructions:
                overlap_cuboid = find_overlap_cuboid(previous_cuboid, cuboid)
                if overlap_cuboid != None:
                    extra_instructions[index].append((overlap_cuboid, not previous_is_on))

        for (extra_cuboid, extra_is_on) in extra_instructions[index]:
            total_cubes_on += calculate_cubes_in_cuboid(extra_cuboid) * (1 if extra_is_on else -1)

    return total_cubes_on

def find_overlap_cuboid(cuboid, cuboid2):
    overlap_cuboid = [-1, -1, -1]

    for dimension_index in [0, 1, 2]:
        cuboid_dimension_min = min(cuboid[dimension_index][0], cuboid[dimension_index][1])
        cuboid_dimension_max = max(cuboid[dimension_index][0], cuboid[dimension_index][1])
        cuboid2_dimension_min = min(cuboid2[dimension_index][0], cuboid2[dimension_index][1])
        cuboid2_dimension_max = max(cuboid2[dimension_index][0], cuboid2[dimension_index][1])
        
        if cuboid2_dimension_min <= cuboid_dimension_min and cuboid2_dimension_max >= cuboid_dimension_max:
            overlap_cuboid[dimension_index] = (cuboid_dimension_min, cuboid_dimension_max)
        elif cuboid_dimension_min <= cuboid2_dimension_min <= cuboid_dimension_max:
            overlap_cuboid[dimension_index] = (cuboid2_dimension_min, min(cuboid2_dimension_max, cuboid_dimension_max))
        elif cuboid_dimension_min <= cuboid2_dimension_max <= cuboid_dimension_max:
            overlap_cuboid[dimension_index] = (max(cuboid2_dimension_min, cuboid_dimension_min), cuboid2_dimension_max)
        else:
            break

    return (overlap_cuboid[0], overlap_cuboid[1], overlap_cuboid[2]) if -1 not in overlap_cuboid else None

def calculate_cubes_in_cuboid(cuboid):
    cubes_on_change = 1

    for dimension_index in [0, 1, 2]:
        cubes_on_change *= abs(cuboid[dimension_index][1] - cuboid[dimension_index][0]) + 1

    return cubes_on_change

def read_instructions(exclude_big):
    instructions = []

    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    for line in lines:
        on = 'on ' in line
        x = list(map(int, line.split('=')[1].replace(',y', '').split('..')))
        y = list(map(int, line.split('=')[2].replace(',z', '').split('..')))
        z = list(map(int, line.split('=')[3].split('..')))
        cuboid = ((min(x[0], x[1]), max(x[0], x[1])), (min(y[0], y[1]), max(y[0], y[1])), (min(z[0], z[1]), max(z[0], z[1])))
        if exclude_big and (cuboid[0][0] < -50 or cuboid[0][1] > 50 or cuboid[1][0] < -50 or cuboid[1][1] > 50 or cuboid[2][0] < -50 or cuboid[2][1] > 50):
            continue
        instructions.append((cuboid, on)) # cuboid coordinates; on/off

    return instructions

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))