import input

PROBLEM_NUMBER = 1

def execute(is_part_two):
    numbers = input.read_numbers(problem_number = PROBLEM_NUMBER)
    return get_increments(numbers) if not is_part_two else get_increments_2(numbers)

def get_increments(numbers):
    return sum(number > numbers[prev_index] for prev_index, number in enumerate(numbers[1:]))

def get_increments_2(numbers):
    return sum(sum(numbers[index+1:index+4]) > sum(numbers[index:index+3]) for index in range(0, len(numbers) - 3))

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))