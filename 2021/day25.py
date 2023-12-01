import input
from collections import defaultdict

PROBLEM_NUMBER = 25

def execute():
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)

    grid = []
    cucumber_positions = defaultdict(list)
    for row, line in enumerate(lines):
        grid.append([])
        for column, cell in enumerate(list(line)):
            grid[row].append(cell)
            if cell != '.':
                cucumber_positions[cell].append((row, column))

    steps = 1
    new_grid, cucumber_positions = execute_step(grid, cucumber_positions)
    while grid != new_grid:
        grid = new_grid
        new_grid, cucumber_positions = execute_step(grid, cucumber_positions)
        steps += 1

    return steps

def execute_step(grid, cucumber_positions):
    new_grid = [line.copy() for line in grid]
    new_cucumber_positions = defaultdict(list)

    for positions in [cucumber_positions['>'], cucumber_positions['v']]:
        for row, column in positions:
            cucumber = grid[row][column]
            new_row, new_column = row, column
            if cucumber == '>':
                new_column = (column + 1) % len(grid[0])
            elif cucumber == 'v':
                new_row = (row + 1) % len(grid)
            if grid[new_row][new_column] == '.':
                new_grid[row][column] = '.'
                new_grid[new_row][new_column] = grid[row][column]
                new_cucumber_positions[cucumber].append((new_row, new_column))
            else:
                new_cucumber_positions[cucumber].append((row, column))
        grid = [line.copy() for line in new_grid]

    return new_grid, new_cucumber_positions

print("Part 1: " + str(execute()))
print("Part 2: No part 2!")