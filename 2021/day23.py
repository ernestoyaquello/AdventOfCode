import input
import sys

PROBLEM_NUMBER = 23

min_global_cost = sys.maxsize
min_global_costs = {}

def execute(is_part_two):
    grid = get_initial_grid(is_part_two)
    amphipod_desired_positions = get_amphipod_desired_positions(is_part_two)
    amphipod_positions = get_amphipod_positions(grid)
    return find_min_cost(grid, amphipod_positions, amphipod_desired_positions)

def find_min_cost(grid, amphipod_positions, amphipod_desired_positions):
    global min_global_cost
    global min_global_costs

    # Reset global variables to start fresh
    min_global_cost = sys.maxsize
    min_global_costs = {}
    find_cheapest_path(grid, amphipod_positions, amphipod_desired_positions, current_cost = 0)

    return min_global_cost

def find_cheapest_path(grid, amphipod_positions, amphipod_desired_positions, current_cost):
    global min_global_cost
    global min_global_costs

    min_relative_cost = sys.maxsize

    # Create a hash for the current board
    grid_hash = grid[1][1:12]
    for room_row in range(2, len(grid) - 1):
        grid_hash.extend([grid[room_row][3], grid[room_row][5], grid[room_row][7], grid[room_row][9]])
    grid_hash = ''.join(grid_hash)

    # Look for the hash in the cache of saved costs to avoid doing unnecessary calculations
    if grid_hash in min_global_costs.keys():
        min_relative_cost = current_cost + min_global_costs[grid_hash]
    else:
        is_final_state = all(all(position in amphipod_desired_positions[amiphod] for position in positions) for amiphod, positions in amphipod_positions.items())
        if is_final_state:
            # We reached a final state (all the amphipods are where they should), no need to do anything else
            min_relative_cost = current_cost
        else:
            # For each amphipod on the board, iterate over its valid moves with recursion to check all possible paths
            for amiphod, positions in amphipod_positions.items():
                for (row, column) in positions:
                    position_index = amphipod_positions[amiphod].index((row, column))
                    for (new_row, new_column), move_cost in get_valid_moves(grid, amphipod_desired_positions, amiphod, row, column):
                        amphipod_positions[amiphod].pop(position_index)
                        amphipod_positions[amiphod].insert(position_index, (new_row, new_column))
                        grid[row][column], grid[new_row][new_column] = ' ', amiphod
                        current_cost += move_cost

                        if current_cost < min_global_cost:
                            min_path_cost = find_cheapest_path(grid, amphipod_positions, amphipod_desired_positions, current_cost)
                            min_relative_cost = min(min_relative_cost, min_path_cost)
                            min_global_cost = min(min_relative_cost, min_global_cost)

                        current_cost -= move_cost
                        grid[new_row][new_column], grid[row][column] = ' ', amiphod
                        amphipod_positions[amiphod].pop(position_index)
                        amphipod_positions[amiphod].insert(position_index, (row, column))

        # Now that we have calculated the path with the minimum cost starting from this state, we cache it
        min_global_costs[grid_hash] = min_relative_cost - current_cost

    return min_relative_cost

def get_valid_moves(grid, amphipod_desired_positions, amiphod, row, column):
    valid_moves = []

    is_in_final_position = (row, column) in amphipod_desired_positions[amiphod] and all(grid[room_row][column] == amiphod for room_row in range(row + 1, len(grid) - 1))
    if not is_in_final_position:
        # The amphipod is in the corridor already, so it must be able to go directly to its final room or don't move at all
        if row == 1:
            desired_room_column = amphipod_desired_positions[amiphod][0][1]
            room_coordinates = None

            # Check that the room and its entrance are clear
            for room_row in range(len(grid) - 2, row, -1):
                if grid[room_row][desired_room_column] == ' ':
                    room_coordinates = (room_row, desired_room_column)
                    break
                elif grid[room_row][desired_room_column] != amiphod:
                    break

            # If the room is accessible, check the left or right paths that lead to it to see if the amphipod can get to the room
            if room_coordinates != None:
                is_path_clear = True
                moves_to_room = 0
                horizontal_path_range = range(column - 1, room_coordinates[1] - 1, -1) if room_coordinates[1] < column else range(column + 1, room_coordinates[1] + 1)
                for new_column in horizontal_path_range:
                    if grid[row][new_column] != ' ':
                        is_path_clear = False
                        break
                    moves_to_room += 1

                if is_path_clear:
                    moves_to_room += (room_coordinates[0] - 1)
                    move_cost = get_move_cost(amiphod)
                    valid_moves.append((room_coordinates, move_cost * moves_to_room))

        # It is not in the corridor yet, so it can get out to go to many different positions within the corridor as long as the path is clear
        else:
            is_path_clear = True
            for room_row in range(row - 1, 1, -1):
                if grid[room_row][column] != ' ':
                    is_path_clear = False
                    break

            if is_path_clear:
                move_cost = get_move_cost(amiphod)
                desired_room_column = amphipod_desired_positions[amiphod][0][1]
                for horizontal_path_range in [range(column - 1, 0, -1), range(column + 1, 12)]:
                    horizontal_move_cost = move_cost * (row - 1)
                    for new_column in horizontal_path_range:
                        if grid[1][new_column] != ' ':
                            break
                        horizontal_move_cost += move_cost
                        if new_column not in [3, 5, 7, 9]:
                            valid_moves.append(((1, new_column), horizontal_move_cost))

    return valid_moves

def get_move_cost(amiphod):
    cost = 1
    if amiphod == 'B':
        cost += 9
    elif amiphod == 'C':
        cost += 99
    elif amiphod == 'D':
        cost += 999

    return cost

def get_initial_grid(is_part_two):
    grid = []

    lines = input.read_lines(problem_number = PROBLEM_NUMBER, strip = False)
    if is_part_two:
        lines[3:3] = ['  #D#C#B#A#', '  #D#B#A#C#']

    grid = [list(line.replace('\n', '').replace('.', ' ')) for line in lines]
    for row in range(len(grid)):
        for column in range(len(grid[0])):
            grid[row].extend(list(' ' * (len(grid[0]) - len(grid[row]))))

    return grid

def get_amphipod_desired_positions(is_part_two):
    amphipod_desired_positions = {
        'A': [(2, 3), (3, 3)],
        'B': [(2, 5), (3, 5)],
        'C': [(2, 7), (3, 7)],
        'D': [(2, 9), (3, 9)],
    }

    if is_part_two:
        amphipod_desired_positions['A'].extend([(4, 3), (5, 3)])
        amphipod_desired_positions['B'].extend([(4, 5), (5, 5)])
        amphipod_desired_positions['C'].extend([(4, 7), (5, 7)])
        amphipod_desired_positions['D'].extend([(4, 9), (5, 9)])

    return amphipod_desired_positions

def get_amphipod_positions(grid):
    amphipod_positions = { 'A': [], 'B': [], 'C': [], 'D': [] }

    for row in range(len(grid)):
        for column in range(len(grid[0])):
            if grid[row][column] != ' ' and grid[row][column] != '#':
                amphipod_positions[grid[row][column]].append((row, column))

    return amphipod_positions

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))