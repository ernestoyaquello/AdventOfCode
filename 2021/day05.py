import input

PROBLEM_NUMBER = 5

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    segments = [list(map(lambda points: list(map(int, points.split(","))), points)) for points in [line.split(" -> ") for line in lines]]
    width = max([max(segment[0][0], segment[1][0]) for segment in segments]) + 1
    height = max([max(segment[0][1], segment[1][1]) for segment in segments]) + 1
    return find_overlaps(segments, width, height, count_diagonals = is_part_two)

def find_overlaps(segments, width, height, count_diagonals):
    lines_board = [[0] * height for _ in range(width)]
    
    for segment in segments:
        point1 = segment[0]
        point2 = segment[1]

        # Vertical line (same X)
        if point1[0] == point2[0]:
            x = point1[0]
            min_y = min(point1[1], point2[1])
            max_y = max(point1[1], point2[1])
            for y in range(min_y, max_y + 1):
                lines_board[x][y] += 1

        # Horizontal line (same Y)
        elif point1[1] == point2[1]:
            y = point1[1]
            min_x = min(point1[0], point2[0])
            max_x = max(point1[0], point2[0])
            for x in range(min_x, max_x + 1):
                lines_board[x][y] += 1

        # Diagonal line (same abs(X2 - X1) and abs(Y2 - Y1) - i.e., same horizontal and vertical distance)
        elif count_diagonals and abs(point1[0] - point2[0]) == abs(point1[1] - point2[1]):
            x = point1[0]
            y = point1[1]
            x_final = point2[0]
            y_final = point2[1]
            x_increment = 1 if (x_final - x) > 0 else -1
            y_increment = 1 if (y_final - y) > 0 else -1
            for _ in range(abs(x_final - x) + 1):
                lines_board[x][y] += 1
                x += x_increment
                y += y_increment

    overlaps = 0
    for x in range(width):
        for y in range(height):
            overlaps += 1 if lines_board[x][y] > 1 else 0
    return overlaps

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))