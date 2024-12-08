import input

PROBLEM_NUMBER = 7

def sum_valid_equations(allow_concatenation):
    total = 0

    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    equations = [(int(line.split(": ")[0]), [int(n) for n in line.split(": ")[1].split()]) for line in lines]
    for result, numbers in equations:
        total += result if sum_valid_results(result, numbers[0], numbers[1:], allow_concatenation) else 0

    return total

def sum_valid_results(desired_result, current_result, next_numbers, allow_concatenation):
    valid_operators = ["||", "*", "+"] if allow_concatenation else ["*", "+"]
    for operator in valid_operators:
        next_number = next_numbers.pop(0)

        # Calculate the next result in the equation by applying the operator
        next_result = current_result
        if operator == "||":
            next_result = int(str(next_result) + str(next_number))
        elif operator == "*":
            next_result *= next_number
        elif operator == "+":
            next_result += next_number

        if len(next_numbers) == 0:
            # No more numbers to process, so check if the result is the desired one
            if next_result == desired_result:
                return True
        elif next_result < desired_result and sum_valid_results(desired_result, next_result, next_numbers, allow_concatenation):
            # A valid way to get to the result was found (the comparison uses "<" because it assumes no zeroes)
            return True

        next_numbers.insert(0, next_number)

    return False

print("Part 1: " + str(sum_valid_equations(allow_concatenation = False)))
print("Part 2: " + str(sum_valid_equations(allow_concatenation = True)))