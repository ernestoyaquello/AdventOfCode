def get_input_path(problem_number):
    return "inputs/" + str(problem_number) + ".txt"

def read_lines(problem_number, strip = True):
    with open(get_input_path(problem_number)) as input:
        return list(map(str.strip, input.readlines())) if strip else input.readlines()

def read_numbers(problem_number):
    return list(map(int, read_lines(problem_number = problem_number)))

def read_lists(problem_number):
    return [line.split(' ') for line in read_lines(problem_number)]