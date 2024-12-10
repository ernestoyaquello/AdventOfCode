import input

PROBLEM_NUMBER = 10

def read_map_and_valid_start_positions():
    map = {}
    valid_start_positions = []

    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    for y in range(0, len(lines)):
        for x in range(0, len(lines[y])):
            position = (x, y)
            height = int(lines[y][x])
            if height < 9:
                # Find valid neighbors for this position
                valid_neighbors = []
                for adjacent_offset in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                    adjacent_position = (position[0] + adjacent_offset[0], position[1] + adjacent_offset[1])
                    if adjacent_position[0] >= 0 and adjacent_position[0] < len(lines[y]) and adjacent_position[1] >= 0 and adjacent_position[1] < len(lines):
                        adjacent_height = int(lines[adjacent_position[1]][adjacent_position[0]])
                        if (adjacent_height - height) == 1:
                            valid_neighbors.append(adjacent_position)
                # Add the position to the map
                map[position] = {
                    "height": height,
                    "valid_neighbors": valid_neighbors,
                    "unique_reachable_peak_positions": None if height < 8 else set(valid_neighbors),
                    "number_of_valid_trails": None if height < 8 else len(valid_neighbors),
                }
                # Add the position as a valid start for a trail if possible
                if height == 0 and len(valid_neighbors) > 0:
                    valid_start_positions.append(position)

    return map, valid_start_positions

# Part 1
def sum_trailhead_scores():
    map, valid_start_positions = read_map_and_valid_start_positions()
    return sum(len(find_unique_reachable_peak_positions(map, start_position)) for start_position in valid_start_positions)

def find_unique_reachable_peak_positions(map, position):
    if map[position]["unique_reachable_peak_positions"] is None:
        map[position]["unique_reachable_peak_positions"] = set()
        for neighbor in map[position]["valid_neighbors"]:
            map[position]["unique_reachable_peak_positions"].update(find_unique_reachable_peak_positions(map, neighbor))
    return map[position]["unique_reachable_peak_positions"]

# Part 2
def sum_trailhead_ratings():
    map, valid_start_positions = read_map_and_valid_start_positions()
    return sum(count_number_of_valid_trails(map, start_position) for start_position in valid_start_positions)

def count_number_of_valid_trails(map, position):
    if map[position]["number_of_valid_trails"] is None:
        map[position]["number_of_valid_trails"] = sum(count_number_of_valid_trails(map, neighbor) for neighbor in map[position]["valid_neighbors"])
    return map[position]["number_of_valid_trails"]

print("Part 1: " + str(sum_trailhead_scores()))
print("Part 2: " + str(sum_trailhead_ratings()))