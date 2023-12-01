import input
import time
from collections import defaultdict

PROBLEM_NUMBER = 12

def execute(is_part_two):
    cave_connection_pairs = [line.split('-') for line in input.read_lines(problem_number = PROBLEM_NUMBER)]
    cave_connections = defaultdict(list)
    for origin, destination in cave_connection_pairs:
        cave_connections[origin].append(destination)
        cave_connections[destination].append(origin)
    return count_paths(cave_connections, 'start', defaultdict(lambda: 0, start = 1), can_revisit_once = is_part_two, has_revisited = False)

def count_paths(cave_connections, cave, small_visited, can_revisit_once, has_revisited):
    if cave == 'end':
        return 1
    else:
        paths_count = 0
        for adjacent_cave in cave_connections[cave]:
            if small_visited[adjacent_cave] == 0 or (can_revisit_once and adjacent_cave != 'start' and not has_revisited):
                small_visited[adjacent_cave] += not adjacent_cave[0].isupper()
                paths_count += count_paths(cave_connections, adjacent_cave, small_visited, can_revisit_once, has_revisited or small_visited[adjacent_cave] == 2)
                small_visited[adjacent_cave] -= not adjacent_cave[0].isupper()
        return paths_count

start_time = time.time()
print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))
print("--- %s seconds ---" % (time.time() - start_time))