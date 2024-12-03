import input
import re

PROBLEM_NUMBER = 3
OPERATION_PATTERN = re.compile(r"mul\((-?\d{1,3}),(-?\d{1,3})\)|do\(\)|don't\(\)")

def execute_valid_multiplications(force_mul_enabled):
    total = 0

    mul_enabled = True
    for line in input.read_lines(problem_number = PROBLEM_NUMBER):
        for match in OPERATION_PATTERN.finditer(line):
            if match.group(0) == "do()":
                mul_enabled = True
            elif match.group(0) == "don't()":
                mul_enabled = False
            elif mul_enabled or force_mul_enabled:
                left = int(match.group(1))
                right = int(match.group(2))
                total += left * right

    return total

print("Part 1: " + str(execute_valid_multiplications(force_mul_enabled = True)))
print("Part 2: " + str(execute_valid_multiplications(force_mul_enabled = False)))