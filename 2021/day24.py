PROBLEM_NUMBER = 24

register = { 'w': 0, 'x': 0, 'y': 0, 'z': 0 }

def execute(is_part_two):
    global register

    register = { 'w': 0, 'x': 0, 'y': 0, 'z': 0 }
    instructions = read_instructions(problem_number = PROBLEM_NUMBER)

    # Find the maximum values of 'z' allowed on every digit to discard invalid branches when looking for the number.
    # This calculation is very rough and incomplete, so it produces maximums that are higher than the real ones, but
    # it kinda does the trick if you have enough patience to wait for the result...
    max_z_values = { 13: 26 }
    for index in range(12, -1, -1):
        max_z_values[index] = max_z_values[index + 1] * (1 if index in [0, 1, 2, 4, 5, 6, 8] else 26)

    return find_serial_number(instructions, max_z_values, find_max = not is_part_two, current_instruction_index = 0, current_serial_number = '')

def find_serial_number(instructions, max_z_values, find_max, current_instruction_index, current_serial_number):
    global register

    # Execute instructions in a loop until an input instruction is found or until there are no more instructions.
    while current_instruction_index < len(instructions) and instructions[current_instruction_index][0] != 'inp':
        execute_instruction(instructions[current_instruction_index])
        current_instruction_index += 1

    # If there are no more instructions to execute, we might have found the serial number.
    if current_instruction_index == len(instructions):
        if len(current_serial_number) == 14 and register['z'] == 0:
            return current_serial_number
        else:
            return None

    # If the current value of 'z' is higher than the maximum allowed here, we skip this branch;
    # otherwise, we go a level deep trying all possible digits to see if we find a valid serial number.
    if register['z'] < max_z_values[len(current_serial_number)]:
        inp_instruction = instructions[current_instruction_index]
        target = inp_instruction[1]
        for number in range(1, 10) if not find_max else range(9, 0, -1):
            register_backup = register.copy()
            register[target] = number

            serial_number = find_serial_number(instructions, max_z_values, find_max, current_instruction_index + 1, current_serial_number + str(number))
            if serial_number != None:
                return serial_number

            register = register_backup

    return None

def execute_instruction(instruction):
    global register

    command = instruction[0]
    target = instruction[1]
    if command == 'inp':
        print(register)
        register[target] = int(input('Digit: '))
    else:
        a_val = register[target]
        b_val = int(instruction[2]) if instruction[2] not in register.keys() else register[instruction[2]]
        if command == 'add':
            register[target] = a_val + b_val
        elif command == 'mul':
            register[target] = int(a_val * b_val)
        elif command == 'div':
            register[target] = int(a_val / b_val)
        elif command == 'mod':
            register[target] = a_val % b_val
        elif command == 'eql':
            register[target] = 1 if a_val == b_val else 0

def read_instructions(problem_number):
    with open("inputs/" + str(problem_number) + ".txt") as input_data:
        return [clean_line.split(' ') for clean_line in [line.strip() for line in input_data.readlines()]]

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))