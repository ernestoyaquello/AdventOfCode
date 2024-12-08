import input
from collections import defaultdict

PROBLEM_NUMBER = 8

def count_antinode_locations(create_antinodes_correctly):
    return len(get_antinode_locations(create_antinodes_correctly))

def get_antinode_locations(create_antinodes_correctly):
    antinode_locations = set()

    # Read the map symbol by symbol, creating antinode locations as we go
    map = input.read_lines(problem_number = PROBLEM_NUMBER)
    symbol_to_antenna_locations = defaultdict(list)
    max_x = len(map[0]) - 1
    max_y = len(map) - 1
    for y in range(0, max_y + 1):
        for x in range(0, max_x + 1):
            symbol = map[y][x]
            if symbol != ".":
                # Look for previous occurrences of the same symbol and, if any, create the appropriate antinode locations
                if symbol in symbol_to_antenna_locations:
                    for other_x, other_y in symbol_to_antenna_locations[symbol]:
                        if not create_antinodes_correctly:
                            create_and_add_antinode_locations_incorrectly(antinode_locations, max_x, max_y, y, x, other_x, other_y)
                        else:
                            create_and_add_antinode_locations_correctly(antinode_locations, max_x, max_y, y, x, other_x, other_y)
                symbol_to_antenna_locations[symbol].append((x, y))

    return antinode_locations

def create_and_add_antinode_locations_incorrectly(antinode_locations, max_x, max_y, y, x, other_x, other_y):
    first_antinode_position = (x + (x - other_x), y + (y - other_y))
    second_antinode_position = (other_x + (other_x - x), other_y + (other_y - y))
    try_add_antinode_location(antinode_locations, first_antinode_position, max_x, max_y)
    try_add_antinode_location(antinode_locations, second_antinode_position, max_x, max_y)

def create_and_add_antinode_locations_correctly(antinode_locations, max_x, max_y, y, x, other_x, other_y):
    first_antinode_position = (x, y)
    first_antinode_offset = (x - other_x, y - other_y)
    while try_add_antinode_location(antinode_locations, first_antinode_position, max_x, max_y):
        first_antinode_position = (first_antinode_position[0] + first_antinode_offset[0], first_antinode_position[1] + first_antinode_offset[1])

    second_antinode_position = (other_x, other_y)
    second_antinode_offset = (other_x - x, other_y - y)
    while try_add_antinode_location(antinode_locations, second_antinode_position, max_x, max_y):
        second_antinode_position = (second_antinode_position[0] + second_antinode_offset[0], second_antinode_position[1] + second_antinode_offset[1])

def try_add_antinode_location(antinode_locations, location, max_x, max_y):
    if location[0] >= 0 and location[0] <= max_x and location[1] >= 0 and location[1] <= max_y:
        antinode_locations.add(location)
        return True
    return False

print("Part 1: " + str(count_antinode_locations(create_antinodes_correctly = False)))
print("Part 2: " + str(count_antinode_locations(create_antinodes_correctly = True)))