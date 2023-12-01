import input
import sys

PROBLEM_NUMBER = 15

ADJACENT_DIFFS = [
    (+1,  0), # Bottom
    ( 0, +1), # Right
    ( 0, -1), # Left
    (-1,  0), # Top
]

def execute(is_part_two):
    # Initialise variables
    grid = list(map(lambda line: list(map(int, list(line))), input.read_lines(problem_number = PROBLEM_NUMBER)))
    grid = extend_grid(grid, 5) if is_part_two else grid
    origin = (0, 0)
    destination = (len(grid) - 1, len(grid[0]) - 1)
    visited = set()
    unvisited = { origin }
    min_risks = {}
    for y in range(len(grid)):
        for x in range(len(grid[y])):
            min_risks[(y, x)] = sys.maxsize if x != 0 or y != 0 else 0

    # Apply the algorithm for each point until we arrive at the destination
    point = origin
    while point != destination:
        point = calculate_min_risks(grid, point, visited, unvisited, min_risks)

    return min_risks[destination]

def extend_grid(grid, times):
    # Copy grid
    extended_grid = grid.copy()
    for y in range(len(grid)):
        extended_grid[y] = extended_grid[y].copy()

    # Extend vertically
    for i in range(1, times):
        for y in range(len(grid)):
            new_row = extended_grid[y + len(grid) * (i - 1)].copy()
            for x in range(len(new_row)):
                new_row[x] += 1
                if new_row[x] > 9:
                    new_row[x] = 1
            extended_grid.append(new_row)

    # Extend horizontally
    for y in range(len(extended_grid)):
        extended_row = extended_grid[y].copy()
        for i in range(1, times):
            extra_row = extended_row.copy()
            for x in range(len(extended_row)):
                extra_row[x] += i
                if extra_row[x] > 9:
                    extra_row[x] = extra_row[x] % 9
            extended_grid[y].extend(extra_row)

    return extended_grid

def calculate_min_risks(grid, point, visited, unvisited, min_risks):
    visited.add(point)
    unvisited.remove(point)

    # Calculate new risks for adjacent, unvisited positions
    for row_diff, column_diff in ADJACENT_DIFFS:
        adjacent_y = point[0] + row_diff
        adjacent_x = point[1] + column_diff
        if 0 <= adjacent_y < len(grid) and 0 <= adjacent_x < len(grid[0]):
            adjacent_point = (adjacent_y, adjacent_x)
            if adjacent_point not in visited:
                candidate_risk = min_risks[point] + grid[adjacent_y][adjacent_x]
                if candidate_risk < min_risks[adjacent_point]:
                    min_risks[adjacent_point] = candidate_risk
                unvisited.add(adjacent_point)

    # Find the least risky adjacent point so we can return it as the next point to check
    best_adjacent_point = None
    for candidate_adjacent_point in unvisited:
        if best_adjacent_point == None or min_risks[candidate_adjacent_point] < min_risks[best_adjacent_point]:
            best_adjacent_point = candidate_adjacent_point

    return best_adjacent_point

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))