import input
import re

PROBLEM_NUMBER = 3
OPERATION_PATTERN = re.compile(r"mul\((-?\d{1,3}),(-?\d{1,3})\)|do\(\)|don't\(\)")

def execute_valid_multiplications(force_enabled):
    total = 0

    enabled = True
    instructions = input.read(problem_number = PROBLEM_NUMBER)
    for match in OPERATION_PATTERN.finditer(instructions):
        if match.group(0) == "do()":
            enabled = True
        elif match.group(0) == "don't()":
            enabled = False
        elif enabled or force_enabled:
            left = int(match.group(1))
            right = int(match.group(2))
            total += left * right

    return total

print("Part 1: " + str(execute_valid_multiplications(force_enabled = True)))
print("Part 2: " + str(execute_valid_multiplications(force_enabled = False)))