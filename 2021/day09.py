import input

PROBLEM_NUMBER = 9

ADJACENT_DIFFS = [ (0, -1), (0, 1), (-1, 0), (1, 0) ] # UP, DOWN, LEFT, RIGHT

def execute(is_part_two):
    cave = list(map(lambda line: list(map(int, list(line))), input.read_lines(problem_number = PROBLEM_NUMBER)))
    low_points = calculate_low_points(cave)
    return calculate_risk_level(cave, low_points) if not is_part_two else multiply_three_biggest_basins_size(cave, low_points)

def calculate_risk_level(cave, low_points):
    return sum(cave[low_point_row][low_point_column] for low_point_row, low_point_column in low_points) + len(low_points)

def multiply_three_biggest_basins_size(cave, low_points):
    basins = [calculate_basin(cave, low_point, []) for low_point in low_points]
    sorted_basins = sorted(basins, key = lambda basin: len(basin), reverse = True)
    return len(sorted_basins[0]) * len(sorted_basins[1]) * len(sorted_basins[2])

def calculate_low_points(cave):
    low_points = []

    for row in range(len(cave)):
        for column in range(len(cave[row])):
            is_low_point = True
            for (column_diff, row_diff) in ADJACENT_DIFFS:
                adjacent_point_row = row + row_diff
                adjacent_point_column = column + column_diff
                if adjacent_point_row < len(cave) and adjacent_point_row >= 0 and \
                    adjacent_point_column < len(cave[row]) and adjacent_point_column >= 0 and \
                    cave[row][column] >= cave[adjacent_point_row][adjacent_point_column]:
                        is_low_point = False
                        break
            if is_low_point:
                low_points.append((row, column))

    return low_points

def calculate_basin(cave, point, global_basin):
    basin = [ point ]
    global_basin.append(point)

    row, column = point[0], point[1]
    for (column_diff, row_diff) in ADJACENT_DIFFS:
        adjacent_point_row = row + row_diff
        adjacent_point_column = column + column_diff
        adjacent_point = (adjacent_point_row, adjacent_point_column)
        if adjacent_point_row < len(cave) and adjacent_point_row >= 0 and \
            adjacent_point_column < len(cave[row]) and adjacent_point_column >= 0 and \
            adjacent_point not in global_basin and \
            cave[adjacent_point_row][adjacent_point_column] < 9:
                basin.extend(calculate_basin(cave, adjacent_point, global_basin))

    return basin

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))