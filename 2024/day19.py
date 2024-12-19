import input

PROBLEM_NUMBER = 19

def count_available_designs(count_each_combination):
    count = 0
    patterns, desired_designs = read_patters_and_desired_designs()
    for desired_design in desired_designs:
        filtered_patterns = [pattern for pattern in patterns if pattern in desired_design]
        combinations_count = count_combinations(desired_design, filtered_patterns)
        count += combinations_count if count_each_combination else (1 if combinations_count > 0 else 0)
    return count

def count_combinations(desired_design, patterns, cache = {}):
    if desired_design in cache:
        return cache[desired_design]

    combinations = 0
    for pattern in patterns:
        if desired_design.startswith(pattern):
            new_desired_design = desired_design[len(pattern):]
            if new_desired_design != "":
                filtered_patterns = [pattern for pattern in patterns if pattern in new_desired_design]
                combinations += count_combinations(new_desired_design, filtered_patterns, cache)
            else:
                combinations += 1

    cache[desired_design] = combinations
    return cache[desired_design]

def read_patters_and_desired_designs():
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    return lines[0].split(", "), lines [2:]

print("Part 1: " + str(count_available_designs(count_each_combination = False)))
print("Part 2: " + str(count_available_designs(count_each_combination = True)))