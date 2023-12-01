import input
from collections import defaultdict

PROBLEM_NUMBER = 14

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    polymer_template = lines[0]
    generation_rules = { key: [key[0] + value, value + key[1]] for key, value in [r.split(' -> ') for r in lines[2:]] }

    pair_count = defaultdict(int)
    for index in range(0, len(polymer_template) - 1):
        pair = polymer_template[index:index+2]
        pair_count[pair] += 1

    char_count = defaultdict(int)
    for char in polymer_template:
        char_count[char] += 1

    char_count = get_char_count(generation_rules, pair_count, steps = 10 if not is_part_two else 40)

    return max(o for o in char_count.values()) - min(o for o in char_count.values())

def get_char_count(generation_rules, pair_count, steps):
    for _ in range(steps):
        new_pair_count = defaultdict(int)
        new_char_count = defaultdict(int)

        for index, pair in enumerate(pair_count.keys()):
            occurrences = pair_count[pair]
            if occurrences == 0:
                continue

            # Generate new pairs
            left = generation_rules[pair][0]
            new_pair_count[left] += occurrences

            right = generation_rules[pair][1]
            new_pair_count[right] += occurrences

            # Count characters
            if index == 0:
                new_char_count[left[0]] += occurrences
            new_char_count[left[1]] += occurrences

            new_char_count[right[1]] += occurrences

        pair_count = new_pair_count
        char_count = new_char_count

    return char_count

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))