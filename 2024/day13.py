import input
import re

PROBLEM_NUMBER = 13
INPUT_PATTERN = re.compile(r"Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)")

def read_machines():
    machines = []

    machine_configs = input.read(problem_number = PROBLEM_NUMBER)
    for match in INPUT_PATTERN.finditer(machine_configs):
        machines.append({
            "A": {"x": int(match.group(1)), "y": int(match.group(2))},
            "B": {"x": int(match.group(3)), "y": int(match.group(4))},
            "prize": {"x": int(match.group(5)), "y": int(match.group(6))},
        }) 

    return machines

def calculate_cost(correct_data):
    cost = 0

    machines = read_machines()
    for machine in machines:
        if correct_data:
            machine["prize"]["x"] += 10000000000000
            machine["prize"]["y"] += 10000000000000

        # Calculate the cost of pressing the buttons to get the prize by using the system of equations that can be created
        # from the problem's description (I created the initial equations myself, but these simplified ones are ChatGPT's,
        # as I've forgotten how to do basic maths at this point).
        determinant = (machine["A"]["x"] * machine["B"]["y"]) - (machine["A"]["y"] * machine["B"]["x"])
        number_of_a_presses = ((machine["B"]["y"] * machine["prize"]["x"]) - (machine["B"]["x"] * machine["prize"]["y"])) / determinant
        number_of_b_presses = (-(machine["A"]["y"] * machine["prize"]["x"]) + (machine["A"]["x"] * machine["prize"]["y"])) / determinant
        if number_of_a_presses.is_integer() and number_of_b_presses.is_integer() and number_of_a_presses >= 0 and number_of_b_presses >= 0:
            cost += int(3 * number_of_a_presses + number_of_b_presses)

    return cost

print("Part 1: " + str(calculate_cost(correct_data = False)))
print("Part 2: " + str(calculate_cost(correct_data = True)))