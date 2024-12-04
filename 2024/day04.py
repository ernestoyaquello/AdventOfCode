import input

PROBLEM_NUMBER = 4

# Completely unnecessary and convoluted code to get all the lines in the input (horizontal, vertical, and both diagonals)
def read_lines_collection():
    lines_collection = {}

    # Add the horizontal lines
    horizontal_lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    lines_collection["horizontal_lines"] = horizontal_lines

    # Add the vertical lines
    vertical_lines = ["".join(horizontal_line[column] for horizontal_line in horizontal_lines) for column in range(0, len(horizontal_lines[0]))]
    lines_collection["vertical_lines"] = vertical_lines

    # Create the necessary instructions to build the diagonal lines
    diagonal_lines_build_instructions = {
        "left_down_diagonal_lines":  {"row_jump": +1, "column_jump": -1, "start_positions": []},
        "right_down_diagonal_lines": {"row_jump": +1, "column_jump": +1, "start_positions": []},
    }
    row, column = len(horizontal_lines) - 1, 0
    while column < len(horizontal_lines[0]):
        diagonal_lines_build_instructions["left_down_diagonal_lines"]["start_positions"].append((row, len(horizontal_lines[0]) - column - 1))
        diagonal_lines_build_instructions["right_down_diagonal_lines"]["start_positions"].append((row, column))
        # First move up to the top row, then move horizontally to the last column
        column += 1 if row == 0 else 0
        row -= 1 if row > 0 else 0

    # Build and add the diagonal lines, which will include both left-down and right-down diagonals
    for key, build_instructions in diagonal_lines_build_instructions.items():
        diagonal_lines = []
        for row, column in build_instructions["start_positions"]:
            diagonal_line = ""
            row_offset, column_offset = 0, 0
            while (row + row_offset) >= 0 and (row + row_offset) < len(horizontal_lines) and (column + column_offset) >= 0 and (column + column_offset) < len(horizontal_lines[0]):
                diagonal_line += horizontal_lines[row + row_offset][column + column_offset]
                row_offset += build_instructions["row_jump"]
                column_offset += build_instructions["column_jump"]
            diagonal_lines.append(diagonal_line)
        lines_collection[key] = diagonal_lines

    return lines_collection

def count_xmas():
    return sum(sum(line.count("XMAS") + line.count("XMAS"[::-1]) for line in lines) for lines in read_lines_collection().values())

def count_crossed_mas():
    total = 0

    horizontal_lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    for row in range(1, len(horizontal_lines) - 1):
        for column in range(1, len(horizontal_lines[0]) - 1):
            left_down_diagonal = horizontal_lines[row - 1][column + 1] + horizontal_lines[row][column] + horizontal_lines[row + 1][column - 1]
            right_down_diagonal = horizontal_lines[row - 1][column - 1] + horizontal_lines[row][column] + horizontal_lines[row + 1][column + 1]
            if (left_down_diagonal == "MAS" or left_down_diagonal == "MAS"[::-1]) and (right_down_diagonal == "MAS" or right_down_diagonal == "MAS"[::-1]):
                total += 1

    return total

print("Part 1: " + str(count_xmas()))
print("Part 2: " + str(count_crossed_mas()))