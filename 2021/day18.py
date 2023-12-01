import input
import math
from copy import deepcopy

PROBLEM_NUMBER = 18

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    pairs = []
    for line in lines:
        read_pairs(line, pairs, is_main_parent_pair = True)

    if not is_part_two:
        # Find magnitude of the total sum
        last = pairs[0]
        for next in pairs[1:]:
            last = add(last, next)
        return calculate_magnitude(last)
    else:
        # Find maximum magnitude when adding two different pairs together
        max_magnitude = 0
        for pair in pairs:
            for pair2 in pairs:
                if pair is not pair2:
                    sum = add(deepcopy(pair), deepcopy(pair2))
                    max_magnitude = max(max_magnitude, calculate_magnitude(sum))
        return max_magnitude

def add(pair, pair2):
    return reduce([pair, pair2])

def reduce(pair):
    if explode([], pair, 0):
        reduce(pair)
    if split(pair):
        reduce(pair)

    return pair

def explode(parent_pairs, pair, depth):
    if depth == 4 and isinstance(pair[0], int) and isinstance(pair[1], int):
        immediate_parent_index = len(parent_pairs) - 1

        # On the left branch, look for the number that is closest to the right side and add the left value of the exploding pair to it.
        # On the right branch, look for the number that is closest to the left side and add the right value of the exploding pair to it.
        for index in [0, 1]:
            inverted_index = int(abs(1 - index))
            closest_value_found = False
            parent_pair_index = immediate_parent_index
            while not closest_value_found and parent_pair_index >= 0:
                parent = parent_pairs[parent_pair_index]
                parent_branch = parent[index]
                if isinstance(parent_branch, int):
                    parent[index] += pair[index]
                    closest_value_found = True
                else:
                    if not contains(parent_branch, pair):
                        look_left = index == 1
                        pair_closest_to_edge = find_closest_to_edge(parent_branch, look_left)
                        if isinstance(pair_closest_to_edge[inverted_index], int):
                            pair_closest_to_edge[inverted_index] += pair[index]
                            closest_value_found = True
                    parent_pair_index -= 1

        # Replace exploding pair with a zero
        exploding_pair_index = parent_pairs[immediate_parent_index].index(pair)
        parent_pairs[immediate_parent_index].remove(pair)
        parent_pairs[immediate_parent_index].insert(exploding_pair_index, 0)

        return True

    elif depth < 4:
        for child in [pair[0], pair[1]]:
            if not isinstance(child, int):
                if explode(parent_pairs + [pair], child, depth + 1):
                    return True

    return False

def split(pair):
    if not isinstance(pair, int):
        for child in [pair[0], pair[1]]:
            if isinstance(child, int) and child > 9:
                pair[pair.index(child)] = [math.floor(child / 2), math.ceil(child / 2)]
                return True
            elif split(child):
                return True
    return False

def calculate_magnitude(pair):
    return pair if isinstance(pair, int) else (calculate_magnitude(pair[0]) * 3) + (calculate_magnitude(pair[1]) * 2)

def contains(container, pair):
    return container is pair or \
        container[0] is pair or \
        container[1] is pair or \
        any(not isinstance(container[index], int) and contains(container[index], pair) for index in [0, 1])

def find_closest_to_edge(pair, look_left):
    child = pair[0] if look_left else pair[1]
    return pair if isinstance(child, int) else find_closest_to_edge(child, look_left)

def read_pairs(line, parent_pair, is_main_parent_pair = False):
    pair, index = read_pair_value(line, 0)

    while index < len(line) and line[index] == ']':
        index += 1
    if index < len(line) and line[index] == ',':
        index += 1

    pair_right, index = read_pair_value(line, index)
    pair.extend(pair_right)

    if not is_main_parent_pair:
        parent_pair.append(pair)
    else:
        parent_pair.extend(pair)

    return index

def read_pair_value(line, index):
    pair = []

    if index < len(line):
        if line[index] == '[':
            return pair, index + 1 + read_pairs(line[index + 1:], pair)
        else:
            pair.append(int(line[index]))
            return pair, index + 1

    return pair, index

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))