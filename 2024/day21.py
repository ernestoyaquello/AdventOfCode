import input
import sys
from more_itertools import pairwise

PROBLEM_NUMBER = 21

def calculate_total_complexity(number_of_directional_keypads):
    total_complexity = 0

    data = read_data()
    depth_to_key_move_paths = {depth: data["numerical_move_paths" if depth == (number_of_directional_keypads - 1) else "directional_move_paths"] for depth in range(0, number_of_directional_keypads)}

    for code in data["codes"]:
        shortest_path_length = 0
        for origin_key, target_key in pairwise("A" + code):
            shortest_path_length += calculate_shortest_paths_length_for_key_press(depth_to_key_move_paths, origin_key, target_key, depth = number_of_directional_keypads - 1)
        total_complexity += int(code[:-1]) * shortest_path_length

    return total_complexity

def calculate_shortest_paths_length_for_key_press(depth_to_key_move_paths, origin_key, target_key, depth, cache = {}):
    cache_key = (origin_key, target_key, depth)
    if cache_key in cache:
        return cache[cache_key]

    total_shortest_path_length = sys.maxsize
    expanded_paths = depth_to_key_move_paths[depth][(origin_key, target_key)]
    if depth > 0:
        for expanded_path in expanded_paths:
            shortest_path_length = 0
            for new_origin_key, new_target_key in pairwise("A" + expanded_path):
                shortest_path_length += calculate_shortest_paths_length_for_key_press(depth_to_key_move_paths, new_origin_key, new_target_key, depth - 1, cache)
                if shortest_path_length > total_shortest_path_length:
                    break
            if shortest_path_length < total_shortest_path_length:
                total_shortest_path_length = shortest_path_length
    else:
        total_shortest_path_length = len(expanded_paths[0])

    cache[cache_key] = total_shortest_path_length
    return total_shortest_path_length

def combine_paths(code_paths):
    combined_paths = code_paths[0]
    if len(code_paths) > 1:
        combined_paths = []
        for path in code_paths[0]:
            for inner_path in combine_paths(code_paths[1:]):
                combined_paths.append(path + inner_path)
    return combined_paths

def read_data():
    codes = input.read_lines(problem_number = PROBLEM_NUMBER)
    numerical_keypad = {(0, 0): '7', (1, 0): '8', (2, 0): '9', (0, 1): '4', (1, 1): '5', (2, 1): '6', (0, 2): '1', (1, 2): '2', (2, 2): '3', (1, 3): '0', (2, 3): 'A'}
    directional_keypad = {(1, 0): '^', (2, 0): 'A', (0, 1): '<', (1, 1): 'v', (2, 1): '>'}

    # Calculate the keys that a directional keypad used to press keys on a directional keypad would need to press to move from any key to any other key and press it
    directional_move_paths = {}
    for position, key in directional_keypad.items():
        for other_position, other_key in directional_keypad.items():
            if position != other_position:
                directional_move_paths[(key, other_key)] = calculate_keypad_to_keypad_moves(position, other_position, directional_keypad, [position])
            else:
                directional_move_paths[(key, other_key)] = [[{'A': (0, 0)}]]
    for key_pair, paths in directional_move_paths.items():
        min_path_length = min(len(p) for p in paths)
        directional_move_paths[key_pair] = ["".join(list(p.keys())[0] for p in path) for path in paths if len(path) == min_path_length]
    for key_pair, paths in directional_move_paths.items():
        paths_to_sort = []
        for path in paths:
            path_cost = sum(len(directional_move_paths[(first_key, second_key)][0]) for first_key, second_key in pairwise("A" + path))
            paths_to_sort.append((path, path_cost))
        directional_move_paths[key_pair] = [path for path, _ in sorted(paths_to_sort, key = lambda p: p[1])]

    # Calculate the keys that a directional keypad used to press keys on a numerical keypad would need to press to move from any key to any other key and press it
    numerical_move_paths = {}
    for position, key in numerical_keypad.items():
        for other_position, other_key in numerical_keypad.items():
            if position != other_position:
                numerical_move_paths[(key, other_key)] = calculate_keypad_to_keypad_moves(position, other_position, numerical_keypad, [position])
            else:
                numerical_move_paths[(key, other_key)] = [[{'A': (0, 0)}]]
    for key_pair, paths in numerical_move_paths.items():
        min_path_length = min(len(p) for p in paths)
        numerical_move_paths[key_pair] = ["".join(list(p.keys())[0] for p in path) for path in paths if len(path) == min_path_length]
    for key_pair, paths in numerical_move_paths.items():
        paths_to_sort = []
        for path in paths:
            path_cost = sum(len(directional_move_paths[(first_key, second_key)][0]) for first_key, second_key in pairwise("A" + path))
            paths_to_sort.append((path, path_cost))
        numerical_move_paths[key_pair] = [path for path, _ in sorted(paths_to_sort, key = lambda p: p[1])]

    return {
        "codes": codes,
        "numerical_keypad": numerical_keypad,
        "directional_keypad": directional_keypad,
        "numerical_move_paths": numerical_move_paths,
        "directional_move_paths": directional_move_paths,
    }

def calculate_keypad_to_keypad_moves(current_position, target_position, keypad, current_path, current_moves = []):
    if current_position == target_position:
        return [current_moves + [{'A': (0, 0)}]]

    moves = []
    for key, (x_offset, y_offset) in {'<': (-1, 0), '^': (0, -1), '>': (1, 0), 'v': (0, 1)}.items():
        next_position = (current_position[0] + x_offset, current_position[1] + y_offset)
        if next_position not in current_path and next_position in keypad:
            moves.extend(calculate_keypad_to_keypad_moves(next_position, target_position, keypad, current_path + [next_position], current_moves + [{key: (x_offset, y_offset)}]))
    return moves

print("Part 1: " + str(calculate_total_complexity(number_of_directional_keypads = 3)))
print("Part 2: " + str(calculate_total_complexity(number_of_directional_keypads = 26)))