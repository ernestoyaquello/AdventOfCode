import input

PROBLEM_NUMBER = 11

ADJACENT_DIFFS = [
    (-1, -1), # R: Top,    C: Left
    (-1,  0), # R: Top,    C: Center
    (-1, +1), # R: Top,    C: Right
    (0,  -1), # R: Center, C: Left
    (0,  +1), # R: Center, C: Right
    (+1, -1), # R: Bottom, C: Left
    (+1,  0), # R: Bottom, C: Center
    (+1, +1), # R: Bottom, C: Right
]

def execute(is_part_two):
    grid = list(map(lambda line: list(map(int, list(line))), input.read_lines(problem_number = PROBLEM_NUMBER)))
    return execute_steps(grid, 100) if not is_part_two else find_syncing_step(grid)

def execute_steps(grid, number_of_steps):
    total_flashes = 0

    for _ in range(number_of_steps):
        total_flashes += execute_step(grid)

    return total_flashes

def find_syncing_step(grid):
    grid_size = len(grid) * len(grid[0])
    step = 0
    while True:
        flashes = execute_step(grid)
        step += 1
        if flashes == grid_size:
            return step

def execute_step(grid):
    total_flashes = 0

    coordinates_to_flash = []
    coordinates_not_to_increase = []
    coordinates_to_increase = []
    
    # For the first action of the step, we increase every octopus on the board
    for row in range(len(grid)):
        for column in range(len(grid[row])):
            coordinates_to_increase.append((row, column))

    # Flash octopuses and increase adjacents ones in a loop until things stabilise
    while len(coordinates_to_flash) > 0 or len(coordinates_to_increase) > 0:
        for row_to_flash, column_to_flash in coordinates_to_flash:
            grid[row_to_flash][column_to_flash] = 0
            total_flashes += 1
            for row_diff, column_diff in ADJACENT_DIFFS:
                row_to_increase = row_to_flash + row_diff
                column_to_increase = column_to_flash + column_diff
                if  0 <= row_to_increase < len(grid) and \
                    0 <= column_to_increase < len(grid[0]) and \
                    (row_to_increase, column_to_increase) not in coordinates_not_to_increase:
                        coordinates_to_increase.append((row_to_increase, column_to_increase))
        coordinates_to_flash.clear()

        for row_to_increase, column_to_increase in coordinates_to_increase:
            grid[row_to_increase][column_to_increase] += 1
            if grid[row_to_increase][column_to_increase] == 10:
                coordinates_to_flash.append((row_to_increase, column_to_increase))
                coordinates_not_to_increase.append((row_to_increase, column_to_increase)) # Flashed octopus will remain with zero energy
        coordinates_to_increase.clear()

    return total_flashes

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))