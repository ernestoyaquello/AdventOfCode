import input

PROBLEM_NUMBER = 4

winning_board_indices = []

def execute(is_part_two):
    # Read numbers and boards
    lines = list(filter(lambda line: line != '', input.read_lines(problem_number = PROBLEM_NUMBER)))
    winning_numbers = list(map(int, lines[0].split(',')))
    boards = [list(map(str.split, lines[line:line+5])) for line in range(1, len(lines), 5)]
    boards = [[[int(number) for number in row] for row in board] for board in boards]

    # Calculate where each number is positioned in the boards to avoid having to do nested loops later
    number_positions = {}
    for board_index, board in enumerate(boards):
        for row_index, row in enumerate(board):
            for col_index, number in enumerate(row):
                if number in number_positions:
                    number_positions[number].append([board_index, row_index, col_index])
                else:
                    number_positions[number] = [[board_index, row_index, col_index]]
    
    return play_bingo(boards, number_positions, winning_numbers, lose_on_purpose = is_part_two)

def play_bingo(boards, number_positions, winning_numbers, lose_on_purpose):
    global winning_board_indices
    winning_board_indices = []

    marks = [[[False for _ in row] for row in board] for board in boards]
    last_found_winner = { 'winning_board_index': -1, 'winning_board': [], 'winning_board_marks': [], 'winning_number': -1 }
    for winning_number in winning_numbers:
        if winning_number in number_positions:
            # Mark the positions where the number is on the boards
            for position in number_positions[winning_number]:
                marks[position[0]][position[1]][position[2]] = True

            # Look for a potential winner
            winning_board_index = get_winning_board_index(marks)
            if winning_board_index != -1:
                if last_found_winner['winning_board_index'] != winning_board_index:
                    last_found_winner['winning_board_index'] = winning_board_index
                    last_found_winner['winning_board'] = boards[winning_board_index]
                    last_found_winner['winning_board_marks'] = [marks_row[:] for marks_row in marks[winning_board_index]] # Copy
                    last_found_winner['winning_number'] = winning_number
                if not lose_on_purpose:
                    break

    return calculate_solution(last_found_winner['winning_board'], last_found_winner['winning_board_marks'], last_found_winner['winning_number'])

def get_winning_board_index(marks):
    global winning_board_indices

    winning_index = -1

    for board_index, board_marks in enumerate(marks):
        if board_index in winning_board_indices:
            continue

        # Check rows for a bingo
        for row in board_marks:
            if all(row):
                winning_board_indices.append(board_index)
                winning_index = board_index if winning_index == -1 else winning_index

        # Check columns for a bingo
        columns = list(map(list, zip(*board_marks)))
        for column in columns:
            if all(column):
                winning_board_indices.append(board_index)
                winning_index = board_index if winning_index == -1 else winning_index

    return winning_index

def calculate_solution(winning_board, winning_board_marks, winning_number):
    sum_unmarked = 0

    for row_index, row in enumerate(winning_board):
        for col_index, number in enumerate(row):
            sum_unmarked += number if not winning_board_marks[row_index][col_index] else 0

    return sum_unmarked * winning_number

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))