import input

PROBLEM_NUMBER = 7

def sum_valid_equations(allow_concatenation):
    total = 0

    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    equations = [(int(line.split(": ")[0]), [int(n) for n in line.split(": ")[1].split()]) for line in lines]
    for result, numbers in equations:
        total += result if sum_valid_results(result, numbers, allow_concatenation, []) else 0

    return total

def sum_valid_results(desired_result, numbers, allow_concatenation, current_operators):
    # If the current result is already bigger than the one we expect, we can stop, as we know it will only get bigger
    if calculate_result(numbers, current_operators) > desired_result:
        return False

    # If we have filled in all the operators, we can check if the result is the one we expect (base case)
    if len(current_operators) == len(numbers) - 1:
        return calculate_result(numbers, current_operators) == desired_result

    # Otherwise, try filling the gaps with each one of the operators
    valid_operators = ["+", "*", "||"] if allow_concatenation else ["+", "*"]
    for operator in valid_operators:
        current_operators.append(operator)
        if sum_valid_results(desired_result, numbers, allow_concatenation, current_operators):
            return True
        current_operators.pop()

    return False

def calculate_result(numbers, operators):
    left_number = numbers[0]
    result = left_number
    for index in range(min(len(operators), len(numbers) - 1)):
        operator = operators[index]
        right_number = numbers[index + 1]
        if operator == "+":
            result += right_number
        elif operator == "*":
            result *= right_number
        elif operator == "||":
            result = int(str(result) + str(right_number))
    return result

print("Part 1: " + str(sum_valid_equations(allow_concatenation = False)))
print("Part 2: " + str(sum_valid_equations(allow_concatenation = True)))