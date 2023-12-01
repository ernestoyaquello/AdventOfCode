import input

PROBLEM_NUMBER = 13

def execute(is_part_two):
    dots, folds = read_data()
    if not is_part_two:
        return len(fold(dots, folds[0]))
    else:
        for f in folds:
            dots = fold(dots, f)
        return get_dots_as_string(dots)

def read_data():
    dots, folds = [], []

    for line in input.read_lines(problem_number = PROBLEM_NUMBER):
        if ',' in line:
            x, y = line.split(',')
            dots.append((int(x), int(y)))
        elif '=' in line:
            fold_type = line.replace('fold along ', '').split('=')[0] # 'x' or 'y'
            fold_value = int(line.split('=')[1])
            folds.append((fold_type, fold_value))

    return dots, folds

def fold(dots, fold):
    # Execute folding
    fold_type, fold_value = fold
    for index, (dot_x, dot_y) in enumerate(dots):
        if fold_type == 'y' and dot_y > fold_value:
            dots[index] = (dot_x, dot_y + (2 * (fold_value - dot_y)))
        elif fold_type == 'x' and dot_x > fold_value:
            dots[index] = (dot_x + (2 * (fold_value - dot_x)), dot_y)

    # Remove duplicates
    return list(set(dots))

def get_dots_as_string(dots):
    dots_string = ''

    width = max(dot[0] for dot in dots) + 1
    height = max(dot[1] for dot in dots) + 1
    for y in range(height):
        dots_string += '\n'
        for x in range(width):
            dots_string += '#' if (x, y) in dots else ' '

    return dots_string

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))