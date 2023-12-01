import input

PROBLEM_NUMBER = 6

def execute(is_part_two):
    numbers = list(map(int, input.read_lines(problem_number = PROBLEM_NUMBER)[0].split(",")))
    return calculate_number_of_lanternfish(numbers, days = 80 if not is_part_two else 256)

def calculate_number_of_lanternfish(numbers, days):
    totals = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0 }
    for fish in numbers:
        totals[fish] += 1

    for _ in range(days):
        new_totals = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0 }
        for index in range(8, -1, -1):
            if index > 0:
                new_totals[index - 1] = totals[index]
            else:
                new_totals[6] += totals[0]
                new_totals[8] += totals[0]
        totals = new_totals

    return sum(totals.values())

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))