import input

PROBLEM_NUMBER = 11
STONE_AND_STEPS_TO_COUNT = {}

def count_stones_after_iterations(number_of_iterations):
    stones = input.read_numbers(problem_number = PROBLEM_NUMBER, line_separator = " ")
    return sum(count_next_stones(stone, number_of_iterations) for stone in stones)

def count_next_stones(stone, steps):
    if (stone, steps) not in STONE_AND_STEPS_TO_COUNT:
        count = 0
        if steps == 0:
            # No more steps (base case)
            count = 1
        elif stone == 0:
            # 0 becomes 1
            count = count_next_stones(1, steps - 1)
        elif len(str(stone)) % 2 == 0:
            # Numbers with an even number of digits are split in the middle into two numbers
            left_number = int(str(stone)[0:len(str(stone)) // 2])
            right_number = int(str(stone)[len(str(stone)) // 2:len(str(stone))])
            count = count_next_stones(left_number, steps - 1) + count_next_stones(right_number, steps - 1)
        else:
            # Every other number is just multiplied by 2024
            count = count_next_stones(stone * 2024, steps - 1)
        STONE_AND_STEPS_TO_COUNT[(stone, steps)] = count

    return STONE_AND_STEPS_TO_COUNT[(stone, steps)]

print("Part 1: " + str(count_stones_after_iterations(number_of_iterations = 25)))
print("Part 2: " + str(count_stones_after_iterations(number_of_iterations = 75)))
